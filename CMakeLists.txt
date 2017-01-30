# TODO examples that crash: 
# gl/gpuParticleSystemExample
# TODO examples that could not be really tested:
# everything with a webcam/videoinput (don't have one)
# sound/audioInputExample
## no microphone connected, requires jack server as well
# TODO examples I'm not sure work as expected
# graphics/fontShapesExample (only happens with some special chars)
## [ error ] ofTessellator: performTessellation(): mesh polygon tessellation failed, winding mode 0
# graphics/polylineBlobsExample: type error see: 
# devApps/ofPolyline_opencv_tester
## https://github.com/openframeworks/openFrameworks/issues/5376
# input_output/dragDropExample
## cant drag images onto application (linux/xfce issue?)
# input_output/pugiXmlExample
## loading and or saving does not work
# sound/soundPlayerFFTExample
## [warning] ofSoundPlayer: ofSoundUpdate() not implemented on this platform
## but still works as expected (i think?)
# TODO missing libraries: svgtiny (depends on libxml2) (see apothecray)
# TODO ofxSvg is not working, missing svgtiny (see above)
# TODO poco is phased out into ofxPoco still requireds poco static libs
## strings/regularExpressionExample is using "Poco/RegularExpression.h"
# TODO enable user selectable opengles support / egl

project(openFrameworks)
cmake_minimum_required(VERSION 3.0)
cmake_policy(VERSION 3.0)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake/modules")
set(OF_CMAKE_FILES "${CMAKE_CURRENT_LIST_DIR}/cmake/cmakelists")
find_package(PkgConfig REQUIRED)

#// Options ///////////////////////////////////////////////////////////////////

#set(OF_STATIC OFF CACHE BOOL "Link openFrameworks libraries statically")
#set(OF_AUDIO  ON  CACHE BOOL "Compile audio features of openFrameworks")
#set(OF_VIDEO  ON  CACHE BOOL "Compile video features of openFrameworks")
#set(OF_GTK    ON  CACHE BOOL "Compile with GTK3 (may conficts with Qt).")

#// Build types ///////////////////////////////////////////////////////////////

if (NOT CMAKE_BUILD_TYPE)
   set(CMAKE_BUILD_TYPE "Release")
endif ()
set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release")


#// Platform detection ////////////////////////////////////////////////////////

#// openFrameworks root path
set(OF_ROOT ${CMAKE_CURRENT_LIST_DIR})

#// Host OS
set(HOST_OS ${CMAKE_HOST_SYSTEM_NAME})
message(STATUS "HOST_OS=${HOST_OS}")
if (NOT HOST_OS STREQUAL "Linux")
    message(WARNING "Your OS (${HOST_OS}) is not supported. Only Linux is supported.")
endif ()

#// Host architecture
include(TargetArch)
# unknown ppc ppc64 ia64 x86_64 i386 arm (4-/8+) armv5 armv6 armv7
target_architecture(HOST_ARCH)
if (NOT HOST_ARCH STREQUAL "x86_64")
    message(WARNING "Your architecture (${HOST_ARCH}) is not supported. Only x86_64 is supported.")
endif ()

#// Platform OS
set(PLATFORM_OS ${CMAKE_SYSTEM_NAME})
if (NOT PLATFORM_OS STREQUAL "Linux")
    message(WARNING "Target OS (${PLATFORM_OS}) is not supported. Only Linux is supported.")
endif ()

#// Platform architecture
set(PLATFORM_ARCH ${HOST_ARCH})
if (NOT PLATFORM_ARCH STREQUAL "x86_64")
    message(WARNING "Target architecture (${PLATFORM_ARCH}) is not supported. Only x86_64 is supported.")
endif ()

#// library subpath
set(PLATFORM_LIB_SUBPATH "linux64")

#// print the variables
message(STATUS "PLATFORM_ARCH=${PLATFORM_ARCH}")
message(STATUS "PLATFORM_OS=${PLATFORM_OS}")
message(STATUS "PLATFORM_VARIANT=${PLATFORM_VARIANT}")
message(STATUS "PLATFORM_LIB_SUBPATH=${PLATFORM_LIB_SUBPATH}")

#// Compiler flags ////////////////////////////////////////////////////////////

set(OF_LINKER_FLAGS "")

set(OF_COMPILER_FLAGS "")
list(APPEND OF_COMPILER_FLAGS
    -DGCC_HAS_REGEX
    -DOF_USING_GTK
    -DOF_USING_MPG123
    -fPIC
    -fPIE
    -D_REENTRANT
    -pthread
)

set(OF_COMPILER_FLAGS_C "")
list(APPEND OF_COMPILER_FLAGS_C
    -std=c11
)

set(OF_COMPILER_FLAGS_CXX "")
list(APPEND OF_COMPILER_FLAGS_CXX
    -std=c++11
)

set(OF_COMPILER_FLAGS_RELEASE "")
list(APPEND OF_COMPILER_FLAGS_RELEASE
    -DNDEBUG
    -O3
)

set(OF_COMPILER_FLAGS_DEBUG "")
list(APPEND OF_COMPILER_FLAGS_DEBUG
    -DDEBUG
    -Og
    -g3
)

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    if (CMAKE_CXX_COMPILER_VERSION VERSION_LESS "4.9.0")
        message(FATAL_ERROR "Your compiler version (${CMAKE_CXX_COMPILER_VERSION}) is too old. Minimum required version is 4.9.0.")
    endif ()
else ()
    message(FATAL_ERROR "Your compiler (${CMAKE_CXX_COMPILER_ID}) is not supported, only the GCC compiler suite is supported.")
endif ()

#// Paths /////////////////////////////////////////////////////////////////////

#// create path definitions
set(OF_ADDONS_PATH "${OF_ROOT}/addons")
set(OF_EXPORT_PATH "${OF_ROOT}/export")
set(OF_EXAMPLES_PATH "${OF_ROOT}/examples")
set(OF_APPS_PATH "${OF_ROOT}/apps")
set(OF_LIBS_PATH "${OF_ROOT}/libs")

set(OF_LIBS_OPENFRAMEWORKS_PATH "${OF_LIBS_PATH}/openFrameworks")
set(OF_LIBS_OF_COMPILED_PATH "${OF_LIBS_OPENFRAMEWORKS_PATH}Compiled")
set(OF_LIBS_OF_COMPILED_PROJECT_PATH "${OF_LIBS_OF_COMPILED_PATH}/project")
set(OF_SHARED_MAKEFILES_PATH "${OF_LIBS_OF_COMPILED_PROJECT_PATH}/makefileCommon")

set(OF_PLATFORM_MAKEFILES "${OF_LIBS_OF_COMPILED_PROJECT_PATH}/${PLATFORM_LIB_SUBPATH}")

set(OF_CORE_LIB_PATH "${OF_LIBS_OF_COMPILED_PATH}/lib/${PLATFORM_LIB_SUBPATH}")

#// print the variables
message(STATUS "================ paths ======================================")
message(STATUS "OF_ADDONS_PATH=${OF_ADDONS_PATH}")
message(STATUS "OF_EXPORT_PATH=${OF_EXPORT_PATH}")
message(STATUS "OF_EXAMPLES_PATH=${OF_EXAMPLES_PATH}")
message(STATUS "OF_APPS_PATH=${OF_APPS_PATH}")
message(STATUS "OF_LIBS_PATH=${OF_LIBS_PATH}")
message(STATUS "OF_OPENFRAMEWORKS_PATH=${OF_LIBS_OPENFRAMEWORKS_PATH}")
message(STATUS "OF_LIBS_OF_COMPILED_PATH=${OF_LIBS_OF_COMPILED_PATH}")
message(STATUS "OF_LIBS_OF_COMPILED_PROJECT_PATH=${OF_LIBS_OF_COMPILED_PROJECT_PATH}")
message(STATUS "OF_SHARED_MAKEFILES_PATH=${OF_SHARED_MAKEFILES_PATH}")
message(STATUS "OF_PLATFORM_MAKEFILES=${OF_PLATFORM_MAKEFILES}")
message(STATUS "OF_CORE_LIB_PATH=${OF_CORE_LIB_PATH}")

#// Includes //////////////////////////////////////////////////////////////////

set(OF_INCLUDE_DIRS
    "${OF_LIBS_OPENFRAMEWORKS_PATH}"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/3d"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/app"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/communication"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/events"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/gl"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/graphics"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/math"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/sound"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/types"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/utils"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video"
)

file (GLOB_RECURSE OF_HEADERS
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/*.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/*.inl"
)

list(REMOVE_ITEM OF_HEADERS
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofAVFoundationGrabber.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofAVFoundationPlayer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofAVFoundationVideoPlayer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQTKitMovieRenderer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQTKitGrabber.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQTKitPlayer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQtUtils.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQuickTimeGrabber.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQuickTimePlayer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofDirectShowPlayer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofDirectShowGrabber.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/sound/ofFmodSoundPlayer.h"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/app/ofAppEGLWindow.h"
)

file(GLOB_RECURSE OF_SOURCES
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/*.cpp"
)

list(REMOVE_ITEM OF_SOURCES
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQtUtils.cpp"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQuickTimeGrabber.cpp"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofQuickTimePlayer.cpp"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofDirectShowPlayer.cpp"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/video/ofDirectShowGrabber.cpp"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/sound/ofFmodSoundPlayer.cpp"
    "${OF_LIBS_OPENFRAMEWORKS_PATH}/app/ofAppEGLWindow.cpp"
)

include_directories(${OF_INCLUDE_DIRS})

#// Dependencies //////////////////////////////////////////////////////////////

set(OF_EXTERNAL_LIBRARIES "")
set(OF_EXTERNAL_LIBRARY_DIRECTORIES "")
set(OF_EXTERNAL_INCLUDE_DIRECTORIES "")
set(OF_EXTERNAL_DEPENDENCIES "")

#// Local dependencies --------------------------------------------------------
include(ExternalProject)

#// tess2
set(OF_LIBS_TESS2_VERSION "v1.0.1")
set(OF_LIBS_TESS2_PREFIX "${CMAKE_BINARY_DIR}/tess2")
ExternalProject_Add(tess2B
    URL "https://github.com/memononen/libtess2/archive/${OF_LIBS_TESS2_VERSION}.tar.gz"
#    GIT_REPOSITORY https://github.com/memononen/libtess2.git
#    GIT_TAG ${OF_LIBS_TESS2_VERSION}
    PREFIX "${OF_LIBS_TESS2_PREFIX}"
    INSTALL_DIR "${OF_LIBS_TESS2_PREFIX}/install"
    CMAKE_ARGS
        "-DCMAKE_INSTALL_PREFIX=${OF_LIBS_TESS2_PREFIX}/install"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
                    "${OF_CMAKE_FILES}/tess2_CMakeLists.txt"
                    "${OF_LIBS_TESS2_PREFIX}/src/tess2B/CMakeLists.txt"
)
ExternalProject_Get_Property(tess2B INSTALL_DIR)
list(APPEND OF_EXTERNAL_LIBRARY_DIRECTORIES "${INSTALL_DIR}/lib")
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include")
install(DIRECTORY "${INSTALL_DIR}/include/" DESTINATION include)
list(APPEND OF_EXTERNAL_LIBRARIES tess2)
list(APPEND OF_EXTERNAL_DEPENDENCIES tess2B)
unset(INSTALL_DIR)
#////////

#// utf8cpp
set(OF_LIBS_UTF8_VERSION "v2.3.5")
set(OF_LIBS_UTF8_PREFIX "${CMAKE_BINARY_DIR}/utf8")
ExternalProject_Add(utf8B
    URL "https://github.com/nemtrif/utfcpp/archive/${OF_LIBS_UTF8_VERSION}.tar.gz"
#    GIT_REPOSITORY https://github.com/nemtrif/utfcpp.git
#    GIT_TAG ${OF_LIBS_UTF8_VERSION}
    PREFIX "${OF_LIBS_UTF8_PREFIX}"
    INSTALL_DIR "${OF_LIBS_UTF8_PREFIX}/install"
    CMAKE_ARGS
        "-DCMAKE_INSTALL_PREFIX=${OF_LIBS_UTF8_PREFIX}/install"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
                    "${OF_CMAKE_FILES}/utf8_CMakeLists.txt"
                    "${OF_LIBS_UTF8_PREFIX}/src/utf8B/CMakeLists.txt"
)
ExternalProject_Get_Property(utf8B INSTALL_DIR)
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include")
install(DIRECTORY "${INSTALL_DIR}/include/" DESTINATION include)
list(APPEND OF_EXTERNAL_DEPENDENCIES utf8B)
unset(INSTALL_DIR)
#////////

#// kissfft
set(OF_LIBS_KISSFFT_VERSION "v130")
set(OF_LIBS_KISSFFT_VERSION_COMMIT "b354a59534b0a77c43c67deb1eb1bc39eb99b487")
set(OF_LIBS_KISSFFT_PREFIX "${CMAKE_BINARY_DIR}/kissfft")
ExternalProject_Add(kissfftB
    URL "https://sourceforge.net/code-snapshots/hg/k/ki/kissfft/code/kissfft-code-${OF_LIBS_KISSFFT_VERSION_COMMIT}.zip"
#    HG_REPOSITORY http://hg.code.sf.net/p/kissfft/code
#    HG_TAG ${OF_LIBS_KISSFFT_VERSION}
    PREFIX "${OF_LIBS_KISSFFT_PREFIX}"
    INSTALL_DIR "${OF_LIBS_KISSFFT_PREFIX}/install"
    CMAKE_ARGS
        "-DCMAKE_INSTALL_PREFIX=${OF_LIBS_KISSFFT_PREFIX}/install"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
                    "${OF_CMAKE_FILES}/kissfft_CMakeLists.txt"
                    "${OF_LIBS_KISSFFT_PREFIX}/src/kissfftB/CMakeLists.txt"
)
ExternalProject_Get_Property(kissfftB INSTALL_DIR)
list(APPEND OF_EXTERNAL_LIBRARY_DIRECTORIES "${INSTALL_DIR}/lib")
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include")
install(DIRECTORY "${INSTALL_DIR}/include/" DESTINATION include)
list(APPEND OF_EXTERNAL_LIBRARIES kissfft)
list(APPEND OF_EXTERNAL_DEPENDENCIES kissfftB)
unset(INSTALL_DIR)
#////////

#// json
set(OF_LIBS_JSON_VERSION "v2.1.0")
set(OF_LIBS_JSON_PREFIX "${CMAKE_BINARY_DIR}/json")
ExternalProject_Add(jsonB
    URL "https://github.com/nlohmann/json/archive/${OF_LIBS_JSON_VERSION}.tar.gz"
#    GIT_REPOSITORY https://github.com/nlohmann/json.git
#    GIT_TAG ${OF_LIBS_JSON_VERSION}
    PREFIX "${OF_LIBS_JSON_PREFIX}"
    INSTALL_DIR "${OF_LIBS_JSON_PREFIX}/install"
    CMAKE_ARGS
        "-DCMAKE_INSTALL_PREFIX=${OF_LIBS_JSON_PREFIX}/install"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
    PATCH_COMMAND ${CMAKE_COMMAND} -E copy
                    "${OF_CMAKE_FILES}/json_CMakeLists.txt"
                    "${OF_LIBS_JSON_PREFIX}/src/jsonB/CMakeLists.txt"
)
ExternalProject_Get_Property(jsonB INSTALL_DIR)
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include")
install(DIRECTORY "${INSTALL_DIR}/include/" DESTINATION include)
list(APPEND OF_EXTERNAL_DEPENDENCIES jsonB)
unset(INSTALL_DIR)
#////////

#// glm
set(OF_LIBS_GLM_VERSION "0.9.8.4")
set(OF_LIBS_GLM_PREFIX "${CMAKE_BINARY_DIR}/glm")
ExternalProject_Add(glmB
    URL "https://github.com/g-truc/glm/archive/${OF_LIBS_GLM_VERSION}.tar.gz"
#    GIT_REPOSITORY https://github.com/g-truc/glm.git
#    GIT_TAG ${OF_LIBS_GLM_VERSION}
    PREFIX "${OF_LIBS_GLM_PREFIX}"
    INSTALL_DIR "${OF_LIBS_GLM_PREFIX}/install"
    CMAKE_ARGS
        "-DCMAKE_INSTALL_PREFIX=${OF_LIBS_GLM_PREFIX}/install"
        "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
)
ExternalProject_Get_Property(glmB INSTALL_DIR)
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES "${INSTALL_DIR}/include")
install(DIRECTORY "${INSTALL_DIR}/include/" DESTINATION include)
unset(INSTALL_DIR)
#////////

#// svgtiny
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#  TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#   TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#    TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#     TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#  TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#   TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#    TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#     TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
# TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#  TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#   TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#    TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO TODO
#////////

#// System dependencies -------------------------------------------------------

#// boost
find_package(Boost COMPONENTS filesystem system REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${Boost_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${OPENAL_INCLUDE_DIR})
#////////

#// GStreamer
find_package(GStreamer
    COMPONENTS gstreamer-app gstreamer-video
    REQUIRED
)
list(APPEND OF_EXTERNAL_LIBRARIES
    ${GSTREAMER_LIBRARIES}
    ${GSTREAMER_BASE_LIBRARIES}
    ${GSTREAMER_APP_LIBRARIES}
    ${GSTREAMER_VIDEO_LIBRARIES}
)
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES
    ${GSTREAMER_INCLUDE_DIRS}
    ${GSTREAMER_BASE_INCLUDE_DIRS}
    ${GSTREAMER_APP_INCLUDE_DIRS}
    ${GSTREAMER_VIDEO_INCLUDE_DIRS}
)
#////////

#// rtaudio
pkg_check_modules(RTAUDIO rtaudio)
if (NOT RTAUDIO_FOUND)
    find_file(RTAUDIO_INCLUDE RtAudio.h)
    if (RTAUDIO_INCLUDE STREQUAL "RTAUDIO_INCLUDE-NOTFOUND")
        message(FATAL_ERROR "rtaudio not found")
    endif ()
    get_filename_component(RTAUDIO_INCLUDE ${RTAUDIO_INCLUDE} DIRECTORY)
    find_library(RTAUDIO_LIBRARY rtaudio)
    if (RTAUDIO_LIBRARY STREQUAL "RTAUDIO_LIBRARY-NOTFOUND")
        message(FATAL_ERROR "rtaudio not found")
    endif ()
    list(APPEND OF_EXTERNAL_LIBRARIES ${RTAUDIO_LIBRARY})
    list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${RTAUDIO_INCLUDE})
else ()
    list(APPEND OF_EXTERNAL_LIBRARIES ${RTAUDIO_LIBRARIES})
    list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${RTAUDIO_INCLUDE_DIRS})
    list(APPEND OF_COMPILER_FLAGS ${RTAUDIO_CFLAGS_OTHER})
    list(APPEND OF_LINKER_FLAGS ${RTAUDIO_LDFLAGS_OTHER})
endif ()
#////////

#// OpenAL
find_package(OpenAL REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${OPENAL_LIBRARY})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${OPENAL_INCLUDE_DIR})
#////////

#// Cairo
find_package(Cairo REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${CAIRO_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${CAIRO_INCLUDE_DIRS})
#////////

#// Freetype
find_package(Freetype REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${FREETYPE_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${FREETYPE_INCLUDE_DIRS})
#////////

#// gtk
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
list(APPEND OF_EXTERNAL_LIBRARIES ${GTK3_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${GTK3_INCLUDE_DIRS})
list(APPEND OF_COMPILER_FLAGS ${GTK3_CFLAGS_OTHER})
list(APPEND OF_LINKER_FLAGS ${GTK3_LDFLAGS_OTHER})
#////////

#// freeimage
find_file(FREEIMAGE_INCLUDE FreeImage.h)
if (FREEIMAGE_INCLUDE STREQUAL "FREEIMAGE_INCLUDE-NOTFOUND")
    message(FATAL_ERROR "freeimage not found")
endif ()
get_filename_component(FREEIMAGE_INCLUDE ${FREEIMAGE_INCLUDE} DIRECTORY)
find_library(FREEIMAGE_LIBRARY freeimage)
if (FREEIMAGE_LIBRARY STREQUAL "FREEIMAGE_LIBRARY-NOTFOUND")
    message(FATAL_ERROR "freeimage not found")
endif ()
list(APPEND OF_EXTERNAL_LIBRARIES ${FREEIMAGE_LIBRARY})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${FREEIMAGE_INCLUDE})
#////////

#// mpg123
find_package(MPG123 REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${MPG123_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${MPG123_INCLUDE_DIRS})
#////////

#// pugixml
find_file(PUGIXML_INCLUDE pugixml.hpp)
if (PUGIXML_INCLUDE STREQUAL "PUGIXML_INCLUDE-NOTFOUND")
    message(FATAL_ERROR "pugixml not found")
endif ()
get_filename_component(PUGIXML_INCLUDE ${PUGIXML_INCLUDE} DIRECTORY)
find_library(PUGIXML_LIBRARY pugixml)
if (PUGIXML_LIBRARY STREQUAL "PUGIXML_LIBRARY-NOTFOUND")
    message(FATAL_ERROR "pugixml not found")
endif ()
list(APPEND OF_EXTERNAL_LIBRARIES ${PUGIXML_LIBRARY})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${PUGIXML_INCLUDE})
#////////

#// glfw3
pkg_check_modules(GLFW3 REQUIRED glfw3)
list(APPEND OF_EXTERNAL_LIBRARIES ${GLFW3_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${GLFW3_INCLUDE_DIRS})
list(APPEND OF_COMPILER_FLAGS ${GLFW3_CFLAGS_OTHER})
list(APPEND OF_LINKER_FLAGS ${GLFW3_LDFLAGS_OTHER})
#////////

#// glew
find_package(GLEW REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${GLEW_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${GLEW_INCLUDE_DIRS})
#////////

#// glut
find_package(GLUT REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${GLUT_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${GLUT_INCLUDE_DIR})
#////////

#// udev
find_package(UDev REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${UDEV_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${UDEV_INCLUDE_DIR})
#////////

#// curl
find_package(CURL REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${CURL_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIRES ${CURL_INCLUDE_DIRS})
#////////

#// uriparser
pkg_check_modules(URIPARSER REQUIRED liburiparser)
list(APPEND OF_EXTERNAL_LIBRARIES ${URIPARSER_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIES ${URIPARSER_INCLUDE_DIRS})
list(APPEND OF_COMPILER_FLAGS ${URIPARSER_CFLAGS_OTHER})
list(APPEND OF_LINKER_FLAGS ${URIPARSER_LDFLAGS_OTHER})
#////////

#// OpenGL
find_package(OpenGL REQUIRED)
list(APPEND OF_EXTERNAL_LIBRARIES ${OPENGL_LIBRARIES})
list(APPEND OF_EXTERNAL_INCLUDE_DIRECTORIRES ${OPENGL_INCLUDE_DIR})
#////////

#// Targets ///////////////////////////////////////////////////////////////////

list(APPEND OF_COMPILER_FLAGS_C ${OF_COMPILER_FLAGS})
list(APPEND OF_COMPILER_FLAGS_CXX ${OF_COMPILER_FLAGS})

foreach (FLAG ${OF_COMPILER_FLAGS_C})
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${FLAG}")
endforeach ()
foreach (FLAG ${OF_COMPILER_FLAGS_CXX})
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAG}")
endforeach ()
foreach (FLAG ${OF_LINKER_FLAGS})
    set(CMAKE_LINKER_EXE_FLAGS "${CMAKE_LINKER_EXE_FLAGS} ${FLAG}")
    set(CMAKE_LINKER_MODULE_FLAGS "${CMAKE_LINKER_MODULE_FLAGS} ${FLAG}")
    set(CMAKE_LINKER_SHARED_FLAGS "${CMAKE_LINKER_SHARED_FLAGS} ${FLAG}")
    set(CMAKE_LINKER_STATIC_FLAGS "${CMAKE_LINKER_STATIC_FLAGS} ${FLAG}")
endforeach ()
foreach (FLAG ${OF_COMPILER_FLAGS_DEBUG})
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} ${FLAG}")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} ${FLAG}")
endforeach ()
foreach (FLAG ${OF_COMPILER_FLAGS_RELEASE})
    set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} ${FLAG}")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} ${FLAG}")
endforeach ()

link_directories(${OF_EXTERNAL_LIBRARY_DIRECTORIES})
include_directories(${OF_EXTERNAL_INCLUDE_DIRECTORIES})

# this is the "object library" target: compiles the sources only once
add_library(openFrameworks OBJECT ${OF_SOURCES})
add_dependencies(openFrameworks ${OF_EXTERNAL_DEPENDENCIES})
# shared libraries need PIC
set_property(TARGET openFrameworks PROPERTY POSITION_INDEPENDENT_CODE 1)
# actual shared and static libraries built from the same object files
add_library(openFrameworks_shared SHARED $<TARGET_OBJECTS:openFrameworks>)
add_library(openFrameworks_static STATIC $<TARGET_OBJECTS:openFrameworks>)

set_property(TARGET openFrameworks_shared PROPERTY POSITION_INDEPENDENT_CODE 1)
set_property(TARGET openFrameworks_static PROPERTY POSITION_INDEPENDENT_CODE 1)

add_dependencies(openFrameworks_static openFrameworks)
add_dependencies(openFrameworks_shared openFrameworks)

set_target_properties(openFrameworks_static
        PROPERTIES OUTPUT_NAME openFrameworks
        DEBUG_OUTPUT_NAME openFrameworksDebug)
set_target_properties(openFrameworks_shared
        PROPERTIES OUTPUT_NAME openFrameworks
        DEBUG_OUTPUT_NAME openFrameworksDebug)

target_link_libraries(openFrameworks_static ${OF_EXTERNAL_LIBRARIES})
target_link_libraries(openFrameworks_shared ${OF_EXTERNAL_LIBRARIES})

#// Installation //////////////////////////////////////////////////////////////

install(TARGETS openFrameworks_static DESTINATION lib)
install(TARGETS openFrameworks_shared DESTINATION lib)
install(FILES ${OF_HEADERS} DESTINATION include)
install(FILES ${OF_ROOT}/cmake/openFrameworks.cmake DESTINATION .)
install(DIRECTORY ${OF_ROOT}/cmake/modules/ DESTINATION cmake)
install(DIRECTORY ${OF_ADDONS_PATH}/ DESTINATION addons)


