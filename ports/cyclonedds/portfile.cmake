include(vcpkg_common_functions)

find_program(GIT NAMES git git.cmd)
set(GIT_URL "https://github.com/eclipse-cyclonedds/cyclonedds")
set(GIT_REV master)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
      COMMAND ${GIT} clone --recurse-submodules -q --depth=20 --branch=${GIT_REV} ${GIT_URL} ${SOURCE_PATH}
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME clone
    )
    message(STATUS "Fetching submodules")
    vcpkg_execute_required_process(
      COMMAND ${GIT} submodule update --init --recursive
      WORKING_DIRECTORY ${SOURCE_PATH}
      LOGNAME submodules
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    NO_CHARSET_FLAG # automatic templates

    OPTIONS 
      -DANALYZE_BUILD=OFF
      -DBUILD_CONFTOOL=ON
      -DBUILD_DOCS=OFF
      -DBUILD_IDLC=ON
      -DBUILD_TESTING=OFF
      -DDDSC_ENABLE_OPENSSL=ON
      -DENABLE_SSL=ON
      -DWERROR=OFF
      -DWITH_DNS=ON
      -DWITH_FREERTOS=OFF
      -DWITH_LWIP=OFF
)

vcpkg_install_cmake()

file(REMOVE ${CURRENT_INSTALLED_DIR}/include/getopt.h ${CURRENT_INSTALLED_DIR}/debug/include/getopt.h)

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
