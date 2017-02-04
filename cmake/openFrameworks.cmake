cmake_minimum_required(VERSION 3.0)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

#// Options ////////////////////////////////////////////////////////////////////

set(OF_STATIC OFF CACHE BOOL "Link openFrameworks libraries statically")

#// Setup //////////////////////////////////////////////////////////////////////

set(OF_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})

if (NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif ()

#// Platform-specific commands /////////////////////////////////////////////////

set(OF_LINKER_FLAGS "")

set(OF_DEFINITIONS "")
list(APPEND OF_DEFINITIONS
    -DGCC_HAS_REGEX
    -DOF_USING_GTK
    -DOF_USING_MPG123
    -D_REENTRANT
)
set(OF_COMPILER_FLAGS "")
list(APPEND OF_COMPILER_FLAGS
    -fPIC
    -fPIE
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

#// Local dependencies /////////////////////////////////////////////////////

set(OPENFRAMEWORKS_INCLUDE_DIRS
    "${OF_ROOT_DIR}/include"
)

set(OF_LIB_DIR "${OF_ROOT_DIR}/lib")

if (OF_STATIC)
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(OPENFRAMEWORKS_LIBS "${OF_LIB_DIR}/libopenFrameworksDebug.a")
    else ()
        set(OPENFRAMEWORKS_LIBS "${OF_LIB_DIR}/libopenFrameworks.a")
    endif ()
    if (NOT OPENFRAMEWORKS_LIBS)
        message(FATAL_ERROR "No static openFrameworks libraries found in ${OF_LIB_DIR} folder.")
    endif ()
else ()
    if (CMAKE_BUILD_TYPE STREQUAL "Debug")
        set(OPENFRAMEWORKS_LIBS "${OF_LIB_DIR}/libopenFrameworksDebug.so")
    else ()
        set(OPENFRAMEWORKS_LIBS "${OF_LIB_DIR}/libopenFrameworks.so")
    endif ()
    if (NOT OPENFRAMEWORKS_LIBS)
        message(FATAL_ERROR "No shared openFrameworks libraries found in ${OF_LIB_DIR} folder.")
    endif ()
endif ()

list(APPEND OPENFRAMEWORKS_LIBRARIES ${OPENFRAMEWORKS_LIBS})

#// System dependencies ////////////////////////////////////////////////////

#// boost
find_package(Boost COMPONENTS filesystem system REQUIRED)
list(APPEND OPENFRAMEWORKS_LIBRARIES ${Boost_LIBRARIES})
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR})
#////////

#// GStreamer
find_package(GStreamer
    COMPONENTS gstreamer-app gstreamer-video
    REQUIRED
)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS
    ${GSTREAMER_INCLUDE_DIRS}
    ${GSTREAMER_BASE_INCLUDE_DIRS}
    ${GSTREAMER_APP_INCLUDE_DIRS}
    ${GSTREAMER_VIDEO_INCLUDE_DIRS}
)
#////////

#// rtaudio
pkg_check_modules(RTAUDIO REQUIRED rtaudio)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${RTAUDIO_INCLUDE_DIRS})
#////////

#// OpenAL
find_package(OpenAL REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${OPENAL_INCLUDE_DIR})
#////////

#// Cairo
find_package(Cairo REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${CAIRO_INCLUDE_DIRS})
#////////

#// Freetype
find_package(Freetype REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${FREETYPE_INCLUDE_DIRS})
#////////

#// gtk
pkg_check_modules(GTK3 REQUIRED gtk+-3.0)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${GTK3_INCLUDE_DIRS})
#////////

#// freeimage
find_file (FREEIMAGE_INCLUDE FreeImage.h)
if (FREEIMAGE_INCLUDE STREQUAL "FREEIMAGE_INCLUDE-NOTFOUND")
    message(FATAL_ERROR "cannot find freeimage")
endif ()
get_filename_component(FREEIMAGE_INCLUDE_DIRS ${FREEIMAGE_INCLUDE} DIRECTORY)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${FREEIMAGE_INCLUDE_DIRS})
#////////

#// mpg123
find_package(MPG123 REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${MPG123_INCLUDE_DIRS})
#////////

#// pugixml
find_file(PUGIXML_INCLUDE pugixml.hpp)
if (PUGIXML_INCLUDE STREQUAL "PUGIXML_INCLUDE-NOTFOUND")
    message(FATAL_ERROR "pugixml not found")
endif ()
get_filename_component(PUGIXML_INCLUDE_DIR ${PUGIXML_INCLUDE} DIRECTORY)
find_library(PUGIXML_LIBRARY pugixml)
if (PUGIXML_LIBRARY STREQUAL "PUGIXML_LIBRARY-NOTFOUND")
    message(FATAL_ERROR "pugixml not found")
endif ()
list(APPEND OPENFRAMEWORKS_LIBRARIES ${PUGIXML_LIBRARY})
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${PUGIXML_INCLUDE_DIR})
#////////

#// glfw3
pkg_check_modules(GLFW3 REQUIRED glfw3)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${GLFW3_INCLUDE_DIRS})
#////////

#// glew
find_package(GLEW REQUIRED)
list(APPEND OPENFRAMEWORKS_LIBRARIES ${GLEW_LIBRARIES})
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${GLEW_INCLUDE_DIRS})
#////////

#// glut
find_package(GLUT REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${GLUT_INCLUDE_DIR})
#////////

#// udev
find_package(UDev REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${UDEV_INCLUDE_DIR})
#////////

#// curl
find_package(CURL REQUIRED)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${CURL_INCLUDE_DIRS})
#////////

#// uriparser
pkg_check_modules(URIPARSER REQUIRED liburiparser)
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${URIPARSER_INCLUDE_DIRS})
#////////

#// OpenGL
find_package(OpenGL REQUIRED)
list(APPEND OPENFRAMEWORKS_LIBRARIES ${OPENGL_LIBRARIES})
list(APPEND OPENFRAMEWORKS_INCLUDE_DIRS ${OPENGL_INCLUDE_DIR})
#////////

#// Include directories ///////////////////////////////////////////////////////

include_directories(${OPENFRAMEWORKS_INCLUDE_DIRS})

#// Compiler flags ////////////////////////////////////////////////////////////

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
foreach (FLAG ${OF_DEFINITIONS})
    add_definitions(${FLAG})
endforeach ()

if(OF_STATIC)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -static-libstdc++")
    set(CMAKE_LINKER_MODULE_FLAGS "${CMAKE_LINKER_MODULE_FLAGS} -static-libstdc++")
    set(CMAKE_LINKER_SHARED_FLAGS "${CMAKE_LINKER_SHARED_FLAGS} -static-libstdc++")
    set(CMAKE_LINKER_STATIC_FLAGS "${CMAKE_LINKER_STATIC_FLAGS} -static-libstdc++")
endif()

#// ofxAddons //////////////////////////////////////////////////////////////////

function(ofxaddon OFXADDON)

    set(OFXADDON_DIR ${OFXADDON})

    if(OFXADDON STREQUAL ofxAccelerometer)
        message(FATAL_ERROR "${OFXADDON} is not supported yet.")


    elseif(OFXADDON STREQUAL ofxAndroid)
        message(FATAL_ERROR "${OFXADDON} is not supported yet.")


    elseif(OFXADDON STREQUAL ofxAssimpModelLoader)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxAssimpModelLoader")
        set(OFXSOURCES
            "${OFXADDON_DIR}/src/ofxAssimpAnimation.cpp"
            "${OFXADDON_DIR}/src/ofxAssimpMeshHelper.cpp"
            "${OFXADDON_DIR}/src/ofxAssimpModelLoader.cpp"
            "${OFXADDON_DIR}/src/ofxAssimpTexture.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")
        pkg_check_modules(ASSIMP REQUIRED assimp)
        include_directories(${ASSIMP_INCLUDE_DIRS})
        link_directories(${ASSIMP_LIBRARY_DIRS})
        set(OPENFRAMEWORKS_LIBRARIES
          ${OPENFRAMEWORKS_LIBRARIES} ${ASSIMP_LIBRARIES} PARENT_SCOPE)


    elseif(OFXADDON STREQUAL ofxEmscripten)
        message(FATAL_ERROR "${OFXADDON} is not supported yet.")


    elseif(OFXADDON STREQUAL ofxGui)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxGui")
        set(OFXSOURCES
            "${OFXADDON_DIR}/src/ofxBaseGui.cpp"
            "${OFXADDON_DIR}/src/ofxButton.cpp"
            "${OFXADDON_DIR}/src/ofxGuiGroup.cpp"
            "${OFXADDON_DIR}/src/ofxLabel.cpp"
            "${OFXADDON_DIR}/src/ofxPanel.cpp"
            "${OFXADDON_DIR}/src/ofxSlider.cpp"
            "${OFXADDON_DIR}/src/ofxSliderGroup.cpp"
            "${OFXADDON_DIR}/src/ofxToggle.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")


    elseif(OFXADDON STREQUAL ofxiOS)
        message(FATAL_ERROR "${OFXADDON} is not supported yet.")


    elseif(OFXADDON STREQUAL ofxKinect)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxKinect")
        set(OFXSOURCES
            "${OFXADDON_DIR}/libs/libfreenect/src/audio.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/cameras.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/core.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/flags.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/loader.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/registration.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/tilt.c"
            "${OFXADDON_DIR}/libs/libfreenect/src/usb_libusb10.c"
            "${OFXADDON_DIR}/src/extra/ofxKinectExtras.cpp"
            "${OFXADDON_DIR}/src/ofxKinect.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")
        include_directories("${OFXADDON_DIR}/src/extra")
        include_directories("${OFXADDON_DIR}/libs/libfreenect/src")
        include_directories("${OFXADDON_DIR}/libs/libfreenect/include")
        find_package(LibUSB REQUIRED)
        add_definitions(${LIBUSB_1_DEFINITIONS})
        include_directories(${LIBUSB_1_INCLUDE_DIRS})
        set(OPENFRAMEWORKS_LIBRARIES
          ${OPENFRAMEWORKS_LIBRARIES} ${LIBUSB_1_LIBRARIES} PARENT_SCOPE)


    elseif(OFXADDON STREQUAL ofxNetwork)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxNetwork")
        set(OFXSOURCES
            "${OFXADDON_DIR}/src/ofxTCPClient.cpp"
            "${OFXADDON_DIR}/src/ofxTCPManager.cpp"
            "${OFXADDON_DIR}/src/ofxTCPServer.cpp"
            "${OFXADDON_DIR}/src/ofxUDPManager.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")


    elseif(OFXADDON STREQUAL ofxOpenCv)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxOpenCv")
        set(OFXSOURCES
            "${OFXADDON_DIR}/src/ofxCvColorImage.cpp"
            "${OFXADDON_DIR}/src/ofxCvContourFinder.cpp"
            "${OFXADDON_DIR}/src/ofxCvFloatImage.cpp"
            "${OFXADDON_DIR}/src/ofxCvGrayscaleImage.cpp"
            "${OFXADDON_DIR}/src/ofxCvHaarFinder.cpp"
            "${OFXADDON_DIR}/src/ofxCvImage.cpp"
            "${OFXADDON_DIR}/src/ofxCvShortImage.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")
        pkg_check_modules(OPENCV REQUIRED opencv)
        include_directories(${OPENCV_INCLUDE_DIRS})
        link_directories(${OPENCV_LIBRARY_DIRS})
        foreach(LIBRARY ${OPENCV_LIBRARIES})
          if(NOT ${LIBRARY} MATCHES opencv_ts AND
             NOT ${LIBRARY} MATCHES opengl32  AND
             NOT ${LIBRARY} MATCHES glu32)
               find_library(FOUND_${LIBRARY} ${LIBRARY})
               set(OFXADDON_LIBRARIES ${OFXADDON_LIBRARIES} ${FOUND_${LIBRARY}})
          endif()
        endforeach()
        find_package(TBB)
        if(TBB_FOUND AND CMAKE_SYSTEM MATCHES Linux)
            include_directories(${TBB_INCLUDE_DIRS})
            list(APPEND OFXADDON_LIBRARIES ${TBB_LIBRARIES})
        endif()
        set(OPENFRAMEWORKS_LIBRARIES
          ${OPENFRAMEWORKS_LIBRARIES} ${OFXADDON_LIBRARIES} PARENT_SCOPE)


    elseif(OFXADDON STREQUAL ofxOsc)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxOsc")
        set(OFXSOURCES
            "${OFXADDON_DIR}/libs/oscpack/src/ip/IpEndpointName.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/osc/OscOutboundPacketStream.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/osc/OscPrintReceivedElements.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/osc/OscReceivedElements.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/osc/OscTypes.cpp"
            "${OFXADDON_DIR}/src/ofxOscBundle.cpp"
            "${OFXADDON_DIR}/src/ofxOscMessage.cpp"
            "${OFXADDON_DIR}/src/ofxOscParameterSync.cpp"
            "${OFXADDON_DIR}/src/ofxOscReceiver.cpp"
            "${OFXADDON_DIR}/src/ofxOscSender.cpp"
        )
        if(CMAKE_SYSTEM MATCHES Linux)
            list(APPEND OFXSOURCES
            "${OFXADDON_DIR}/libs/oscpack/src/ip/posix/NetworkingUtils.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/ip/posix/UdpSocket.cpp"
            )
        elseif(CMAKE_SYSTEM MATCHES Darwin)
            list(APPEND OFXSOURCES
            "${OFXADDON_DIR}/libs/oscpack/src/ip/posix/NetworkingUtils.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/ip/posix/UdpSocket.cpp"
            )
        elseif(CMAKE_SYSTEM MATCHES Windows)
            list(APPEND OFXSOURCES
            "${OFXADDON_DIR}/libs/oscpack/src/ip/win32/NetworkingUtils.cpp"
            "${OFXADDON_DIR}/libs/oscpack/src/ip/win32/UdpSocket.cpp"
            )
        endif()
        include_directories("${OFXADDON_DIR}/src")
        include_directories("${OFXADDON_DIR}/libs/oscpack/src")
        include_directories("${OFXADDON_DIR}/libs/oscpack/src/ip")
        include_directories("${OFXADDON_DIR}/libs/oscpack/src/osc")


    elseif(OFXADDON STREQUAL ofxSvg)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxSvg")
        set(OFXSOURCES
            "${OFXADDON_DIR}/libs/svgTiny/src/src_colors.cpp"
            "${OFXADDON_DIR}/libs/svgTiny/src/svgtiny.cpp"
            "${OFXADDON_DIR}/libs/svgTiny/src/svgtiny_gradient.cpp"
            "${OFXADDON_DIR}/libs/svgTiny/src/svgtiny_list.cpp"
            "${OFXADDON_DIR}/src/ofxSvg.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")
        include_directories("${OFXADDON_DIR}/libs/svgTiny/src")


    elseif(OFXADDON STREQUAL ofxThreadedImageLoader)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxThreadedImageLoader")
        set(OFXSOURCES "${OFXADDON_DIR}/src/ofxThreadedImageLoader.cpp")
        include_directories("${OFXADDON_DIR}/src")


    elseif(OFXADDON STREQUAL ofxUnitTests)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxUnitTests")
        include_directories("${OFXADDON_DIR}/src")


    elseif(OFXADDON STREQUAL ofxVectorGraphics)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxVectorGraphics")
        set(OFXSOURCES
            "${OFXADDON_DIR}/libs/CreEPS.cpp"
            "${OFXADDON_DIR}/src/ofxVectorGraphics.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")
        include_directories("${OFXADDON_DIR}/libs")


    elseif(OFXADDON STREQUAL ofxXmlSettings)
        set(OFXADDON_DIR "${OF_ROOT_DIR}/addons/ofxXmlSettings")
        set(OFXSOURCES
            "${OFXADDON_DIR}/libs/tinyxml.cpp"
            "${OFXADDON_DIR}/libs/tinyxmlerror.cpp"
            "${OFXADDON_DIR}/libs/tinyxmlparser.cpp"
            "${OFXADDON_DIR}/src/ofxXmlSettings.cpp"
        )
        include_directories("${OFXADDON_DIR}/src")
        include_directories("${OFXADDON_DIR}/libs")

    else()

        if(NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/${OFXADDON_DIR}/")
            string(FIND ${CMAKE_CURRENT_LIST_DIR} ${OFXADDON_DIR} POS REVERSE)
            if(POS GREATER 0)
                string(LENGTH ${OFXADDON_DIR} LEN)
                math(EXPR LEN2 "${LEN}+${POS}")
                string(SUBSTRING ${CMAKE_CURRENT_LIST_DIR} 0 ${LEN2} OFXADDON_DIR)
            else()
                message(FATAL_ERROR "ofxaddon(${OFXADDON_DIR}): the folder doesn't exist.")
            endif()
        endif()

        if(NOT (EXISTS "${CMAKE_CURRENT_LIST_DIR}/${OFXADDON_DIR}/src/" OR EXISTS "${OFXADDON_DIR}/src/"))
            message(WARNING "ofxaddon(${OFXADDON_DIR}): the addon doesn't have src subfolder.")
        endif()

        file(GLOB_RECURSE OFXSOURCES
            "${OFXADDON_DIR}/src/*.c"
            "${OFXADDON_DIR}/src/*.cc"
            "${OFXADDON_DIR}/src/*.cpp"
            "${OFXADDON_DIR}/libs/*.c"
            "${OFXADDON_DIR}/libs/*.cc"
            "${OFXADDON_DIR}/libs/*.cpp"
        )

        FILE(GLOB_RECURSE OFXLIBSINCLUDEDIRS LIST_DIRECTORIES true "${OFXADDON_DIR}/libs/*")

        foreach(OFXLIBHEADER_PATH ${OFXLIBSINCLUDEDIRS})
          if(IS_DIRECTORY "${OFXLIBHEADER_PATH}")
            string(FIND "${OFXLIBHEADER_PATH}" "include" POS REVERSE)
            string(LENGTH "${OFXLIBHEADER_PATH}" LEN)
            math(EXPR POS2 "${LEN}-7")
            if(POS EQUAL POS2)
              set(OFXLIBHEADER_PATHS ${OFXLIBHEADER_PATHS} "${OFXLIBHEADER_PATH}")
            endif()
          endif()
        endforeach()

        if (OFXLIBHEADER_PATHS)
          include_directories("${OFXLIBHEADER_PATHS}")
        endif()
        include_directories("${OFXADDON_DIR}/src")
        include_directories("${OFXADDON_DIR}/libs")

    endif()

    if(OFXSOURCES)
        set(OFXADDONS_SOURCES ${OFXADDONS_SOURCES} ${OFXSOURCES} PARENT_SCOPE)
    endif()

endfunction(ofxaddon)

if (EXISTS "${CMAKE_SOURCE_DIR}/addons.make")
    file(STRINGS "${CMAKE_SOURCE_DIR}/addons.make" OFX_ADDONS_MAKE)
    foreach (ADDON ${OFX_ADDONS_MAKE})
        ofxaddon(${ADDON})
    endforeach ()
endif ()

#// Messages ///////////////////////////////////////////////////////////////////

message(STATUS "OF_STATIC: " ${OF_STATIC})

