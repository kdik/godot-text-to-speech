cmake_minimum_required(VERSION 3.19)
project(godot_text_to_speech LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(GODOT_CPP_DIR "${CMAKE_SOURCE_DIR}/extern/godot-cpp")

if(NOT EXISTS ${GODOT_CPP_DIR})
    message(FATAL_ERROR "GODOT_CPP_DIR (${GODOT_CPP_DIR}) does not exist. Edit CMakeLists.txt to point to your godot-cpp.")
endif()

add_subdirectory(${GODOT_CPP_DIR} ${CMAKE_BINARY_DIR}/godot-cpp EXCLUDE_FROM_ALL)

add_library(${PROJECT_NAME} SHARED
    src/text_to_speech.cpp
    src/text_to_speech.h
    src/register_types.cpp
    flite/flite_wrapper.c
)

target_include_directories(${PROJECT_NAME} PRIVATE
    ${GODOT_CPP_DIR}/include
    ${GODOT_CPP_DIR}/include/core
    ${CMAKE_CURRENT_SOURCE_DIR}/flite
    ${CMAKE_CURRENT_SOURCE_DIR}/include/flite
)


if(WIN32)
set(FLITE_LIB_DIR ${CMAKE_SOURCE_DIR}/lib/win)
elseif(UNIX)
set(FLITE_LIB_DIR ${CMAKE_SOURCE_DIR}/lib/linux)
endif()

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

if(WIN32)
    # Force inclusion of static libs into DLL
    target_link_libraries(${PROJECT_NAME} PRIVATE
        godot-cpp
        -Wl,--whole-archive ${FLITE_LIBS} -Wl,--no-whole-archive
        winmm   # must come AFTER flite libs
        m
    )
elseif(UNIX)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        godot-cpp
        -Wl,--whole-archive ${FLITE_LIBS} -Wl,--no-whole-archive
        m
    )
endif()

