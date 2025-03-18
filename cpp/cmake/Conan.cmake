cmake_minimum_required(VERSION 3.10)

# Release by default
if(NOT CMAKE_BUILD_TYPE)
    message(STATUS "Setting build type to 'Release' as none was specified.")
    set(CMAKE_BUILD_TYPE
        "Release"
        CACHE STRING "Choose the type of build." FORCE)
endif(NOT CMAKE_BUILD_TYPE)

set(CONAN_PROFILE_NAME "default" CACHE STRING "Conan profile being used to build")

message(STATUS "Executing conan install...")
execute_process(
    COMMAND conan install
        --settings:all=build_type=${CMAKE_BUILD_TYPE}
        --profile:all=${CONAN_PROFILE_NAME}
        --output-folder "${CMAKE_BINARY_DIR}"
        --conf "tools.system.package_manager:mode=install"
        --conf "tools.cmake.cmake_layout:build_folder=."
        --conf "tools.cmake.cmaketoolchain:generator=${CMAKE_GENERATOR}"
        --build missing
        "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE CONAN_RETURN_CODE
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")

if(CONAN_RETURN_CODE AND NOT CONAN_RETURN_CODE EQUAL "0")
    message(FATAL_ERROR "conan install failed: ${CONAN_RETURN_CODE}")
endif(CONAN_RETURN_CODE AND NOT CONAN_RETURN_CODE EQUAL "0")

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_BINARY_DIR}/${CMAKE_BUILD_TYPE}/generators/conan_toolchain.cmake")
