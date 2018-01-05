
# Default CPack generators
set(CPACK_GENERATOR TGZ STGZ)

# Detect OS type, OS variant and target architecture
if(UNIX)
  if(APPLE)
    set(OS_TYPE macos)
  else()
    set(OS_TYPE linux)
    # Determine distribution
    execute_process(COMMAND lsb_release -si
        OUTPUT_VARIABLE LINUX_DISTRO
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
  endif()
  # Determine architecture
  execute_process(COMMAND uname -m
    OUTPUT_VARIABLE MACHINE_ARCH
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Set OS type and ARCH suffix
  set(OS_TYPE_ARCH_SUFFIX ${OS_TYPE}-${MACHINE_ARCH})
elseif(WIN32)
  set(OS_TYPE win)
  # Determine architecture
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(MACHINE_ARCH 64)
  else()
    set(MACHINE_ARCH "")
  endif()
  # Set OS type and ARCH suffix
  set(OS_TYPE_ARCH_SUFFIX ${OS_TYPE}${MACHINE_ARCH})
endif()

include(InstallRequiredSystemLibraries)
# Package release version
set(PACKAGE_RELEASE_VERSION 1)
set(CPACK_INSTALL_CMAKE_PROJECTS "${CPACK_INSTALL_CMAKE_PROJECTS};.;libbot;ALL;/")


set(CPACK_PACKAGE_DIRECTORY ${CMAKE_BINARY_DIR}/packages)
# Caveat: CMAKE_INSTALL_PREFIX and CPACK_PACKAGING_INSTALL_PREFIX have to match because python
# scripts generated at compile time hardcode paths.
set(CPACK_PACKAGING_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Set of libraries, tools, and algorithms that are designed to facilitate robotics research")
set(CPACK_PACKAGE_VENDOR "Kitware Inc.")
set(CPACK_PACKAGE_DESCRIPTION_FILE "${CMAKE_CURRENT_SOURCE_DIR}/README")
set(CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE")
set(CPACK_PACKAGE_VERSION_MAJOR "1")
set(CPACK_PACKAGE_VERSION_MINOR "0")
set(CPACK_PACKAGE_VERSION_PATCH "0")
set(CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH})
set(CPACK_PACKAGE_NAME "${PROJECT_NAME}")
set(CPACK_PACKAGE_FILE_NAME ${CPACK_PACKAGE_NAME}_${CPACK_PACKAGE_VERSION}-${PACKAGE_RELEASE_VERSION}_${OS_TYPE_ARCH_SUFFIX})
set(CPACK_STRIP_FILES TRUE)
set(CPACK_SOURCE_STRIP_FILES FALSE)

# Debian specific
set(CPACK_DEBIAN_PACKAGE_RELEASE ${PACKAGE_RELEASE_VERSION})
set(CPACK_DEBIAN_PACKAGE_DEPENDS "lcm (>=1.3.95), libgl1-mesa-dev, libglu1-mesa, freeglut3, libc6, libglib2.0-0, libpcre3, libgtk2.0-0, libx11-6, libpng16-16, zlib1g, libjpeg-turbo8, libxext6, libstdc++6, libffi6, libpangocairo-1.0-0, libxfixes3, libatk1.0-0, libcairo2, libgdk-pixbuf2.0-0, libpangoft2-1.0-0, libpango-1.0-0, libfontconfig1, libxi6, libxxf86vm1, libxrender1, libxinerama1, libxrandr2, libxcursor1, libxcomposite1, libxdamage1, libxcb1, libfreetype6, libpixman-1-0, libpng12-0, libxcb-shm0, libxcb-render0, libselinux1, libharfbuzz0b, libthai0, libexpat1, libxau6, libxdmcp6, libgraphite2-3, libdatrie1, openjdk-8-jre-headless, python-minimal, libpython2.7, python-gtk2, python-gobject, python-numpy, python-scipy")


	
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Francois Budin <francois.budin@kitware.com")
include(CPack)
