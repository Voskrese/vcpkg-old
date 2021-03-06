include(vcpkg_common_functions)

#vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

find_program(GIT NAMES git git.cmd)
set(GIT_URL "https://github.com/NLnetLabs/ldns")
set(GIT_REV devel/cmake)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/${PORT})
if(NOT EXISTS "${SOURCE_PATH}/.git")
	message(STATUS "Cloning and fetching submodules")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} clone --recurse-submodules ${GIT_URL} ${SOURCE_PATH}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME clone
	)
	message(STATUS "Checkout revision ${GIT_REV}")
	vcpkg_execute_required_process(
	  COMMAND ${GIT} checkout ${GIT_REV}
	  WORKING_DIRECTORY ${SOURCE_PATH}
	  LOGNAME checkout
	)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    NO_CHARSET_FLAG # automatic templates

    OPTIONS 
#      -DRRTYPE_AVC:BOOL=OFF
#      -DRRTYPE_NINFO:BOOL=OFF
#      -DRRTYPE_OPENPGPKEY:BOOL=OFF
#      -DRRTYPE_RKEY:BOOL=OFF
#      -DRRTYPE_TA:BOOL=OFF
#      -DSTDERR_MSGS:BOOL=ON
#      -DUSE_DANE:BOOL=ON
#      -DUSE_DANE_VERIFY:BOOL=ON
#      -DUSE_DSA:BOOL=ON
#      -DUSE_ECDSA:BOOL=ON
      -DUSE_ED25519:BOOL=OFF
      -DUSE_ED448:BOOL=OFF
#      -DUSE_GOST:BOOL=ON
#      -DUSE_SHA2:BOOL=ON
)

vcpkg_install_cmake()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
