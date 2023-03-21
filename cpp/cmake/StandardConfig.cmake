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

# Static analysis disabled by default
if(NOT STATIC_ANALYSIS)
  set(STATIC_ANALYSIS
        "OFF"
        CACHE STRING "Static analysis")
endif(NOT STATIC_ANALYSIS)

# Generating code coverage info is disabled by default
if(NOT ENABLE_COVERAGE)
  set(ENABLE_COVERAGE
        "OFF"
        CACHE STRING "Enable Code Coverage Checks")
endif(NOT ENABLE_COVERAGE)

# Format checks enabled by default
set(ENABLE_CHECK_FORMAT
  "ON"
  CACHE STRING "Enable Format Checks")

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
    set(CMAKE_C_COMPILER_LAUNCHER
        "${CCACHE}"
        PARENT_SCOPE)
  endif(CCACHE AND NOT CMAKE_CXX_COMPILER_LAUNCHER)

  # ASan+LSan+UBsan / MSan / TSan
  if(NOT ENABLE_TSAN AND NOT ENABLE_MSAN AND CMAKE_BUILD_TYPE STREQUAL "Debug")
    # ASan is automatically enabled in Debug builds, unless TSan or MSan is enabled
    set(ENABLE_ASAN TRUE)
  endif(NOT ENABLE_TSAN AND NOT ENABLE_MSAN AND CMAKE_BUILD_TYPE STREQUAL "Debug")
  if(ENABLE_TSAN)
    message("Enabling TSan")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -fsanitize=thread"
        PARENT_SCOPE)
    set(CMAKE_C_FLAGS
        "${CMAKE_C_FLAGS} -fsanitize=thread"
        PARENT_SCOPE)
  elseif(ENABLE_MSAN)
    message("Enabling MSan")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -fsanitize=memory"
        PARENT_SCOPE)
    set(CMAKE_C_FLAGS
        "${CMAKE_C_FLAGS} -fsanitize=memory"
        PARENT_SCOPE)
  elseif(ENABLE_ASAN)
    message("Enabling ASan, LSan and UBSan")
    set(CMAKE_CXX_FLAGS
        "${CMAKE_CXX_FLAGS} -fsanitize=address -fsanitize=leak -fsanitize=undefined"
        PARENT_SCOPE)
    set(CMAKE_C_FLAGS
        "${CMAKE_C_FLAGS} -fsanitize=address -fsanitize=leak -fsanitize=undefined"
        PARENT_SCOPE)
  endif()

  # Download clang-format and clang-tidy configs
  file(DOWNLOAD "${CODING_STANDARDS_ROOT}/cpp/.clang-format"
       "${CMAKE_SOURCE_DIR}/.clang-format" TLS_VERIFY ${TLS_VERIFY})
  file(DOWNLOAD "${CODING_STANDARDS_ROOT}/cpp/.clang-tidy"
       "${CMAKE_SOURCE_DIR}/.clang-tidy" TLS_VERIFY ${TLS_VERIFY})

  # clang-tidy (use as clang-tidy;arguments)
  set(CMAKE_CXX_CLANG_TIDY
    ""
    CACHE STRING "clang-tidy binary and config (C++)")
  set(CMAKE_C_CLANG_TIDY
    ""
    CACHE STRING "clang-tidy binary and config (C)")
  # Automatically enable clang-tidy if STATIC_ANALYSIS is turned on
  if(NOT CMAKE_CXX_CLANG_TIDY AND STATIC_ANALYSIS)
    message(STATUS "STATIC_ANALYSIS is enabled. Turning on clang-tidy.")
    set(CMAKE_CXX_CLANG_TIDY
      "clang-tidy"
      CACHE STRING "clang-tidy binary and config" FORCE)
    set(CMAKE_C_CLANG_TIDY
      "clang-tidy"
      CACHE STRING "clang-tidy binary and config" FORCE)
  endif()

  # Code Coverage (target 'code_coverage'), to be invoked after running all tests
  if(ENABLE_COVERAGE)
    if(BUILD_TESTING)
      if(CMAKE_BUILD_TYPE STREQUAL "Debug")
        if(CMAKE_C_COMPILER_ID STREQUAL "GNU")
          message("Enabling code coverage checking")
          add_compile_options(--coverage)
          add_link_options(--coverage)
          add_custom_target(code_coverage
            COMMAND lcov -c -d "${CMAKE_BINARY_DIR}" -o "${CMAKE_BINARY_DIR}/lcov.info" --exclude '/usr/include/*' --exclude '/usr/lib/*' --exclude '/usr/local/*'
            COMMAND genhtml "${CMAKE_BINARY_DIR}/lcov.info" -o "${CMAKE_BINARY_DIR}/code_coverage_report" > "${CMAKE_BINARY_DIR}/genhtml.out" 2>&1
            COMMAND cat "${CMAKE_BINARY_DIR}/genhtml.out"
            COMMAND grep "lines.*100\.0\%" "${CMAKE_BINARY_DIR}/genhtml.out") # Requires 100% coverage
        else(CMAKE_C_COMPILER_ID STREQUAL "GNU")
          message(WARNING "Can't enable code coverage checking as only GCC is supported")
        endif(CMAKE_C_COMPILER_ID STREQUAL "GNU")
      else(CMAKE_BUILD_TYPE STREQUAL "Debug")
        message(WARNING "Can't enable code coverage checking as only Debug builds are supported")
      endif(CMAKE_BUILD_TYPE STREQUAL "Debug")
    else(BUILD_TESTING)
      message(WARNING "Can't enable code coverage checking as BUILD_TESTING is off")
    endif(BUILD_TESTING)
  endif(ENABLE_COVERAGE)

  # Enable generating compile_commands.json to be used by tools
  set(CMAKE_EXPORT_COMPILE_COMMANDS
      TRUE
      PARENT_SCOPE)

  # Common C++ settings
  if(SAFETY_CRITICAL)
    set(CMAKE_CXX_STANDARD
        14                # As defined by Autosar
        PARENT_SCOPE)
    set(CMAKE_C_STANDARD
        99                # As defined by MISRA
        PARENT_SCOPE)
  else()
    set(CMAKE_CXX_STANDARD
        17
        PARENT_SCOPE)
    set(CMAKE_C_STANDARD
        11
        PARENT_SCOPE)
  endif(SAFETY_CRITICAL)
  set(CMAKE_CXX_STANDARD_REQUIRED
      ON
      PARENT_SCOPE)
  set(CMAKE_CXX_EXTENSIONS
      OFF
      PARENT_SCOPE)
  set(C_STANDARD_REQUIRED
      ON
      PARENT_SCOPE)

  if (NOT MSVC)
    # pragmas can be needed for specific optimizations in some compilers while ignored in other
    add_compile_options(-Wall -Wextra -pedantic -Werror -Wno-unknown-pragmas)
  else()
    add_compile_options(/W4 /WX /wd4068 /wd4996)
  endif()

  # Enable Conan (https://conan.io/)
  if(NOT EXISTS "${CMAKE_BINARY_DIR}/conan.cmake")
    message(STATUS "Downloading conan.cmake...")
    file(DOWNLOAD
         "https://github.com/conan-io/cmake-conan/raw/0.17.0/conan.cmake"
         "${CMAKE_BINARY_DIR}/conan.cmake" TLS_VERIFY ${TLS_VERIFY})
  endif()
  include(${CMAKE_BINARY_DIR}/conan.cmake)

  # Enable Format.cmake (https://github.com/provizio/Format.cmake), if ON
  if(ENABLE_CHECK_FORMAT)
    set(FORMAT_CMAKE_VERSION "1.7.3")
    set(FORMAT_CMAKE_PATH
        "${CMAKE_BINARY_DIR}/Format.cmake-${FORMAT_CMAKE_VERSION}")
    if(NOT EXISTS "${FORMAT_CMAKE_PATH}")
      set(FORMAT_CMAKE_DOWNLOAD_URL
          "https://github.com/provizio/Format.cmake/archive/refs/tags/v${FORMAT_CMAKE_VERSION}.tar.gz"
      )
      file(DOWNLOAD "${FORMAT_CMAKE_DOWNLOAD_URL}" "${FORMAT_CMAKE_PATH}.tar.gz"
          TLS_VERIFY ${TLS_VERIFY})
      execute_process(COMMAND tar -xf "${FORMAT_CMAKE_PATH}.tar.gz" -C
                              "${CMAKE_BINARY_DIR}")
    endif(NOT EXISTS "${FORMAT_CMAKE_PATH}")
    set(FORMAT_SKIP_CMAKE YES CACHE BOOL "" FORCE)
    add_subdirectory("${FORMAT_CMAKE_PATH}" EXCLUDE_FROM_ALL)
    # Automatically enable clang-format checks if STATIC_ANALYSIS is turned on
    if(STATIC_ANALYSIS)
      message(STATUS "STATIC_ANALYSIS is enabled. Adding check-format to ALL.")
      add_custom_target(check-format-all ALL DEPENDS check-format)
    endif()
  endif(ENABLE_CHECK_FORMAT)

endfunction(StandardConfig)
