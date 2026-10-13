# Distributed under the OSI-approved BSD 3-Clause License.
# See accompanying file LICENSE-BSD for details.

#[================================================================================[.rst:
FindMeson
---------

Find the Meson executable.

.. code-block:: cmake

  find_package(Meson [<version>] [...])

Imported Targets
^^^^^^^^^^^^^^^^

This module defines the following Imported Targets (only created when CMAKE_ROLE is ``PROJECT``):

``Meson::Meson``
  Target encapsulating the ``meson`` executable usage requirements.

Result Variables
^^^^^^^^^^^^^^^^

``Meson_FOUND``
  Boolean indicating whether the ``meson`` executable.

``Meson_EXECUTABLE``
  The full path to the ``meson`` executable.

``Meson_VERSION``
  The version of the ``meson`` executable found.

``Meson_VERSION_MAJOR``
  The major version of the ``meson`` executable found.

``Meson_VERSION_MINOR``
  The minor version of the ``meson`` executable found.

``Meson_VERSION_PATCH``
  The patch version of the ``meson`` executable found.

Hints
^^^^^

``Meson_ROOT_DIR``, ``ENV{Meson_ROOT_DIR}``
  The root directory of a Meson installation where the executable is located.
  This can be used to specify a custom Meson installation path.

#]================================================================================]

if (CMAKE_HOST_WIN32)
    set(_Meson_PATH_SUFFIXES Scripts)
else()
    set(_Meson_PATH_SUFFIXES bin)
endif()

set(_Meson_SEARCH_HINTS
    ${Meson_ROOT_DIR}
    ENV Meson_ROOT_DIR)

set(_Meson_SEARCH_PATHS "")

set(_Meson_FAILURE_REASON "")

find_program(Meson_EXECUTABLE
    NAMES meson
    PATH_SUFFIXES ${_Meson_PATH_SUFFIXES}
    HINTS ${_Meson_SEARCH_HINTS}
    PATHS ${_Meson_SEARCH_PATHS}
    DOC "The full path to the ``meson`` executable.")

if (Meson_EXECUTABLE)
    execute_process(
        COMMAND ${Meson_EXECUTABLE} --version
        RESULT_VARIABLE _Meson_VERSION_RESULT
        OUTPUT_VARIABLE _Meson_VERSION_OUTPUT OUTPUT_STRIP_TRAILING_WHITESPACE
        ERROR_VARIABLE  _Meson_VERSION_ERROR  ERROR_STRIP_TRAILING_WHITESPACE)

    if (_Meson_VERSION_RESULT EQUAL 0)
        string(REGEX MATCH "([0-9]+)\\.([0-9]+)\\.([0-9]+)" Meson_VERSION ${_Meson_VERSION_OUTPUT})
        set(Meson_VERSION_MAJOR "${CMAKE_MATCH_1}")
        set(Meson_VERSION_MINOR "${CMAKE_MATCH_2}")
        set(Meson_VERSION_PATCH "${CMAKE_MATCH_3}")
    else()
        string(APPEND _Meson_FAILURE_REASON
        "The command\n"
        "    \"${Meson_EXECUTABLE}\" --version\n"
        "failed with fatal errors.\n"
        "    result:\n${_Meson_VERSION_RESULT}\n"
        "    stdout:\n${_Meson_VERSION_OUTPUT}\n"
        "    stderr:\n${_Meson_VERSION_ERROR}")
    endif()
endif()

# Handle REQUIRED and QUIET arguments
# this will also set Meson_FOUND to true if Meson_EXECUTABLE exists
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Meson
    REQUIRED_VARS
        Meson_EXECUTABLE
        Meson_VERSION
    VERSION_VAR
        Meson_VERSION
    FOUND_VAR
        Meson_FOUND
    FAIL_MESSAGE
        "${_Meson_FAILURE_REASON}"
    HANDLE_VERSION_RANGE)

if (Meson_FOUND)
    get_property(_Meson_CMAKE_ROLE GLOBAL PROPERTY CMAKE_ROLE)
    if (_Meson_CMAKE_ROLE STREQUAL "PROJECT")
        if (NOT TARGET Meson::Meson)
            add_executable(Meson::Meson IMPORTED)
            set_target_properties(Meson::Meson PROPERTIES
                IMPORTED_LOCATION
                    "${Meson_EXECUTABLE}")
        endif()
    endif()
    unset(_Meson_CMAKE_ROLE)
endif()

unset(_Meson_PATH_SUFFIXES)
unset(_Meson_SEARCH_HINTS)
unset(_Meson_SEARCH_PATHS)
unset(_Meson_FAILURE_REASON)
