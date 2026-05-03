cmake_minimum_required(VERSION 3.19)
project(godot_text_to_speech LANGUAGES CXX C)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(GODOT_CPP_DIR "${CMAKE_SOURCE_DIR}/extern/godot-cpp")
set(FLITE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/flite")
set(FLITE_BUILD_SOURCE_DIR "${CMAKE_BINARY_DIR}/flite-src")

add_subdirectory(${GODOT_CPP_DIR} ${CMAKE_BINARY_DIR}/godot-cpp EXCLUDE_FROM_ALL)

if(NOT EXISTS "${FLITE_SOURCE_DIR}/configure")
    message(FATAL_ERROR "Flite submodule is missing. Run: git submodule update --init --recursive")
endif()

if(MSVC)
    message(FATAL_ERROR "Building Flite from source is supported with GCC/Clang toolchains. On Windows, use MSYS2 MinGW.")
endif()

find_program(FLITE_SHELL NAMES sh bash REQUIRED)
find_program(FLITE_MAKE NAMES mingw32-make make gmake REQUIRED)

include(ExternalProject)

if(APPLE)
    if(CMAKE_OSX_ARCHITECTURES)
        list(GET CMAKE_OSX_ARCHITECTURES 0 FLITE_TARGET_CPU)
    else()
        set(FLITE_TARGET_CPU "${CMAKE_SYSTEM_PROCESSOR}")
    endif()

    if(FLITE_TARGET_CPU MATCHES "^(arm64|aarch64)$")
        set(GODOT_MACOS_ARCH "arm64")
        set(FLITE_TARGET_CPU "aarch64")
    else()
        set(GODOT_MACOS_ARCH "x86_64")
        set(FLITE_TARGET_CPU "x86_64")
    endif()

    set(FLITE_TARGET_PLATFORM "${FLITE_TARGET_CPU}-darwin")
    set(FLITE_CONFIGURE_HOST "${FLITE_TARGET_CPU}-apple-darwin")
    set(FLITE_CONFIGURE_ARGS --host=${FLITE_CONFIGURE_HOST} --disable-shared --with-audio=none)
elseif(WIN32)
    set(FLITE_TARGET_PLATFORM "x86_64-mingw32")
    set(FLITE_CONFIGURE_ARGS --disable-shared --with-audio=none)
else()
    set(FLITE_TARGET_PLATFORM "x86_64-linux-gnu")
    set(FLITE_CONFIGURE_ARGS --disable-shared --with-audio=none)
endif()

set(FLITE_BUILD_DIR "${FLITE_BUILD_SOURCE_DIR}/build/${FLITE_TARGET_PLATFORM}")
set(FLITE_LIB_DIR "${FLITE_BUILD_DIR}/lib")
set(FLITE_LIBS
    ${FLITE_LIB_DIR}/libflite.a
    ${FLITE_LIB_DIR}/libflite_usenglish.a
    ${FLITE_LIB_DIR}/libflite_cmulex.a
    ${FLITE_LIB_DIR}/libflite_cmu_time_awb.a
    ${FLITE_LIB_DIR}/libflite_cmu_grapheme_lang.a
    ${FLITE_LIB_DIR}/libflite_cmu_grapheme_lex.a
    ${FLITE_LIB_DIR}/libflite_cmu_indic_lang.a
    ${FLITE_LIB_DIR}/libflite_cmu_indic_lex.a
)

ExternalProject_Add(flite_external
    PREFIX ${CMAKE_BINARY_DIR}/flite-external
    SOURCE_DIR ${FLITE_BUILD_SOURCE_DIR}
    DOWNLOAD_COMMAND ${CMAKE_COMMAND} -E copy_directory ${FLITE_SOURCE_DIR} ${FLITE_BUILD_SOURCE_DIR}
    UPDATE_COMMAND ${CMAKE_COMMAND} -E copy_directory ${FLITE_SOURCE_DIR} ${FLITE_BUILD_SOURCE_DIR}
    CONFIGURE_COMMAND
        ${CMAKE_COMMAND} -E env
            "CC=${CMAKE_C_COMPILER}"
            "AR=${CMAKE_AR}"
            "RANLIB=${CMAKE_RANLIB}"
            "CFLAGS=-O2 -fPIC"
            ${FLITE_SHELL} ./configure ${FLITE_CONFIGURE_ARGS}
    BUILD_COMMAND
        ${FLITE_MAKE} -j1
    BUILD_IN_SOURCE 1
    INSTALL_COMMAND ""
    BUILD_BYPRODUCTS ${FLITE_LIBS}
)

add_library(${PROJECT_NAME} SHARED
    src/text_to_speech.cpp
    src/text_to_speech.h
    src/register_types.cpp
    src/flite_wrapper.c
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${GODOT_CPP_DIR}/include
    ${GODOT_CPP_DIR}/include/core
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${FLITE_SOURCE_DIR}/include
)

if(APPLE)
    set(GODOT_PLUGIN_LIB_DIR "${CMAKE_SOURCE_DIR}/addons/text_to_speech/lib/macos")
elseif(WIN32)
    set(GODOT_PLUGIN_LIB_DIR "${CMAKE_SOURCE_DIR}/addons/text_to_speech/lib/win")
else()
    set(GODOT_PLUGIN_LIB_DIR "${CMAKE_SOURCE_DIR}/addons/text_to_speech/lib/linux")
endif()

if(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
        OUTPUT_NAME "godot_text_to_speech.macos.${GODOT_MACOS_ARCH}"
    )
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${GODOT_PLUGIN_LIB_DIR}"
    LIBRARY_OUTPUT_DIRECTORY "${GODOT_PLUGIN_LIB_DIR}"
)

add_dependencies(${PROJECT_NAME} flite_external)

if(APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE godot-cpp m)
    foreach(FLITE_LIB IN LISTS FLITE_LIBS)
        target_link_libraries(${PROJECT_NAME} PRIVATE "-Wl,-force_load,${FLITE_LIB}")
    endforeach()
elseif(WIN32)
    # Force inclusion of static libs into DLL
    target_link_libraries(${PROJECT_NAME} PRIVATE
        godot-cpp
        -Wl,--whole-archive ${FLITE_LIBS} -Wl,--no-whole-archive
        winmm
        m
    )
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        godot-cpp
        -Wl,--whole-archive ${FLITE_LIBS} -Wl,--no-whole-archive
        m
    )
endif()
