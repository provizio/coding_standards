cmake_minimum_required(VERSION 3.10)

# Enable CTest
include(CTest)
enable_testing()

# Release by default
if(NOT CMAKE_BUILD_TYPE)
  message(STATUS "Setting build type to 'Release' as none was specified.")
  set(CMAKE_BUILD_TYPE
      "Release"
      CACHE STRING "Choose the type of build." FORCE)
endif(NOT CMAKE_BUILD_TYPE)

function(StandardConfig config_type)
  set(CODING_STANDARDS_ROOT
      "https://raw.githubusercontent.com/provizio/coding_standards/master")
  set(TLS_VERIFY ON)

  # Check the configuration
  if(config_type STREQUAL "SAFETY_CRITICAL")
    set(SAFETY_CRITICAL TRUE)
  elseif(config_type STREQUAL "NON_SAFETY_CRITICAL")
    set(SAFETY_CRITICAL FALSE)
  else()
    message(
      FATAL_ERROR
        "Invalid value of config_type: ${config_type}. Supported values are SAFETY_CRITICAL and NON_SAFETY_CRITICAL"
    )
  endif(config_type STREQUAL "SAFETY_CRITICAL")

  # ccache
  find_program(CCACHE ccache)
  if(CCACHE AND NOT CMAKE_CXX_COMPILER_LAUNCHER)
    message("ccache found!")
    set(CMAKE_CXX_COMPILER_LAUNCHER
        "${CCACHE}"
        PARENT_SCOPE)
  endif(CCACHE AND NOT CMAKE_CXX_COMPILER_LAUNCHER)

  # ASan / TSan
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(ENABLE_ASAN TRUE)
  endif(CMAKE_BUILD_TYPE STREQUAL "Debug")
  if(ENABLE_ASAN)
    message("Enabling ASan")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -fsanitize=address -fsanitize=leak"
        PARENT_SCOPE)
  elseif(ENABLE_TSAN)
    message("Enabling TSan")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -fsanitize=thread"
        PARENT_SCOPE)
  endif()

  # clang-tidy (use as clang-tidy;arguments)
  set(CMAKE_CXX_CLANG_TIDY
      ""
      CACHE STRING "clang-tidy binary and config")

  # Enable generating compile_commands.json to be used by tools
  set(CMAKE_EXPORT_COMPILE_COMMANDS
      TRUE
      PARENT_SCOPE)

  # Common C++ settings
  if(SAFETY_CRITICAL)
    set(CMAKE_CXX_STANDARD
        14
        PARENT_SCOPE)
  else()
    set(CMAKE_CXX_STANDARD
        17
        PARENT_SCOPE)
  endif(SAFETY_CRITICAL)
  set(CMAKE_CXX_STANDARD_REQUIRED
      ON
      PARENT_SCOPE)
  set(CMAKE_CXX_EXTENSIONS
      OFF
      PARENT_SCOPE)
  add_compile_options(-Wall -Wextra -pedantic -Werror)

  # Enable Conan (https://conan.io/)
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake...")
    file(DOWNLOAD
         "https://github.com/conan-io/cmake-conan/raw/0.17.0/conan.cmake"
         "${CMAKE_BINARY_DIR}/conan.cmake" TLS_VERIFY ${TLS_VERIFY})
  endif()
  include(${CMAKE_BINARY_DIR}/conan.cmake)

  # Enable Format.cmake (https://github.com/TheLartians/Format.cmake)
  set(FORMAT_CMAKE_VERSION "1.7.1")
  set(FORMAT_CMAKE_PATH
      "${CMAKE_BINARY_DIR}/Format.cmake-${FORMAT_CMAKE_VERSION}")
  if(NOT EXISTS "${FORMAT_CMAKE_PATH}")
    set(FORMAT_CMAKE_DOWNLOAD_URL
        "https://github.com/TheLartians/Format.cmake/archive/refs/tags/v${FORMAT_CMAKE_VERSION}.tar.gz"
    )
    file(DOWNLOAD "${FORMAT_CMAKE_DOWNLOAD_URL}" "${FORMAT_CMAKE_PATH}.tar.gz"
         TLS_VERIFY ${TLS_VERIFY})
    execute_process(COMMAND tar -xf "${FORMAT_CMAKE_PATH}.tar.gz" -C
                            "${CMAKE_BINARY_DIR}")
  endif(NOT EXISTS "${FORMAT_CMAKE_PATH}")
  set(FORMAT_SKIP_CMAKE YES CACHE BOOL "" FORCE)
  add_subdirectory("${FORMAT_CMAKE_PATH}" EXCLUDE_FROM_ALL)

  # Download clang-format and clang-tidy
  file(DOWNLOAD "${CODING_STANDARDS_ROOT}/cpp/.clang-format"
       "${CMAKE_SOURCE_DIR}/.clang-format" TLS_VERIFY ${TLS_VERIFY})
  file(DOWNLOAD "${CODING_STANDARDS_ROOT}/cpp/.clang-tidy"
       "${CMAKE_SOURCE_DIR}/.clang-tidy" TLS_VERIFY ${TLS_VERIFY})

endfunction(StandardConfig)
