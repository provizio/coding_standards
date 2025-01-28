cmake_minimum_required(VERSION 3.10)

message(STATUS "Executing command: conan install .. --settings=build_type=${CMAKE_BUILD_TYPE} --build=missing -c tools.system.package_manager:mode=install")
execute_process(COMMAND conan install .. --settings=build_type=${CMAKE_BUILD_TYPE} --build=missing -c tools.system.package_manager:mode=install
                        RESULT_VARIABLE return_code
                        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/build")

set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/build/${CMAKE_BUILD_TYPE}/generators/conan_toolchain.cmake")
