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
