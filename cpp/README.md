# C++ Coding Standards

This directory contains scripts and configs to be used by C++ projects.

## Using with CMake

In the root CMakeLists.txt of your project add these lines after the `project`
statement in order to import the configs and configure your CMake project:

```CMake
# Standard Config
file(DOWNLOAD
     "https://raw.githubusercontent.com/provizio/coding_standards/master/cpp/cmake/StandardConfig.cmake"
     "${CMAKE_BINARY_DIR}/StandardConfig.cmake" TLS_VERIFY ON)
include(${CMAKE_BINARY_DIR}/StandardConfig.cmake)
StandardConfig(<SAFETY_CRITICAL / NON_SAFETY_CRITICAL>) # Choose the configuration type
```

## Language Standard

C++17 (language extensions not allowed) for NON_SAFETY_CRITICAL and C++14 for
SAFETY_CRITICAL projects (as AUTOSAR / MISRA standards for C++17 are not
yet available).

## Warnings / Errors Config

High level of compiler warnings checking with warnings treated as errors is
used: `-Wall -Wextra -pedantic -Werror`.

## Code Style

Unfortunately, there is no common naming style in C++ world, so we follow what
gets the closest to be a standard: Standard Library and
[Boost](https://www.boost.org/). It's very simple: everything is `lower_case`
except macros.

The formatting style is based on `clang-format`-defined Microsoft style.

### clang-format

[.clang-format](.clang-format) file defines the
[clang-format](https://clang.llvm.org/docs/ClangFormat.html) configuration.

Including `StandardConfig.cmake` adds these CMake targets:

- `format` Shows which files are affected by clang-format
- `check-format` Errors if files are affected by clang-format (for CI integration)
- `fix-format` Applies clang-format to all affected files

### clang-tidy

[.clang-tidy](.clang-tidy) file defines the
[clang-tidy](https://clang.llvm.org/extra/clang-tidy/) configuration.

clang-tidy analysis can be turned on by providing
`-DCMAKE_CXX_CLANG_TIDY=clang-tidy` CMake argument.
clang-tidy is capable of automatically fixing some of the detected issues: use
`-DCMAKE_CXX_CLANG_TIDY=clang-tidy;--fix` to enable this mode.

## Conan

Including `StandardConfig.cmake` does not include conan cmake integration since conan2 tries to decouple itself from build tools.  
Setup:  

  1. In the root CMakeLists.txt of your project add these lines BEFORE the `project`
statement in order to configure conan:

     ```CMake
      # Conan
      file(DOWNLOAD
          "https://raw.githubusercontent.com/provizio/coding_standards/master/cpp/cmake/Conan.cmake"
          "${CMAKE_BINARY_DIR}/Conan.cmake" TLS_VERIFY ON)
      include(${CMAKE_BINARY_DIR}/Conan.cmake)
     ```

  2. Create conanfile in root directory, example  
      1. conanfile.py - Python version is more powerful and flexible

          ```Python
            import os

            from conan import ConanFile
            from conan.tools.cmake import cmake_layout
            from conan.tools.files import copy


            class ProvizioExample(ConanFile):
                settings = "os", "compiler", "build_type", "arch"
                generators = "CMakeDeps", "CMakeToolchain"

                def configure(self):
                    self.options["boost*"].without_test = True

                def requirements(self):
                    self.requires("boost/1.74.0")
                    self.requires("ms-gsl/4.1.0")

                def layout(self):
                    cmake_layout(self)
          ```
      2. conanfile.txt - txt version is lighter and cleaner

          ```text
            [requires]
            boost/1.74.0
            ms-gsl/4.1.0

            [generators]
            CMakeDeps
            CMakeToolchain

            [layout]
            cmake_layout
          ```

  2. Make your CMake projects (libraries and executables) depend on them in standard 'modern cmake style', example:

     ```CMake
      find_package(Boost REQUIRED)
      find_package(Microsoft.GSL REQUIRED)
      target_link_libraries(${LIB_NAME}
          boost::boost
          Microsoft.GSL::GSL
      )
     ```

Conan has to be [installed](https://pypi.org/project/conan/) in the system.

## Unit Testing

[CTest](https://cmake.org/cmake/help/latest/manual/ctest.1.html) is enabled by
default. Add tests normally with [add_test](https://cmake.org/cmake/help/latest/command/add_test.html).

### Frameworks

Recommended unit testing frameworks:

- C++: [Boost.Test](https://www.boost.org/doc/libs/1_79_0/libs/test/doc/html/index.html)
  or [Google Test](https://github.com/google/googletest) (both available in Conan).
- C: [Unity Test](https://github.com/provizio/Unity/tree/provizio)
  or [CLove-Unit](https://github.com/fdefelici/clove-unit) (CLove-Unit is
  available in Conan).

### Code Coverage Analysis

1. Enable code coverage support by setting CMake variable `ENABLE_COVERAGE=ON`
  (f.e. by editing CMake Cache or specifying it when invoking CMake with
  `-DENABLE_COVERAGE=ON`).
2. Build the project and run unit tests.
3. Build CMake target `code_coverage`. It succeeds in case 100% code coverage
  is achieved and fails otherwise. It also prints its results and generates a
  human-readable HTML report at `<cmake build directory>/code_coverage_report/`.
  For suppressing not-testable code sections, use
  [lcov exclusion markers](https://manpages.debian.org/unstable/lcov/geninfo.1.en.html).
  Every exclusion must be commented to explain why it's required.
