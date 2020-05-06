include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO clvn/zidl
	REF df29a8dd9397bcbef679f74baf9e64bbffe5e562
    SHA512 1aa2759a88456eb910e7c0fe2c90385ea7365cbbf564e550b49cfd29ccc016d8982b2f309d82cc4811d909f630f2a0165cc9341875b2287ab31f7fa7042883fe
    HEAD_REF master)

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

# need re2c and lemon
set(ENV{PATH} "$ENV{PATH};${CURRENT_INSTALLED_DIR}/tools")

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/zidl.sln
    OPTIONS_DEBUG /p:OutDir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/
    OPTIONS_RELEASE /p:OutDir=${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/
	PLATFORM ${BUILD_ARCH}
)

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/zidl.exe DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
# file(INSTALL ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/zidl.exe DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/zidl RENAME copyright)