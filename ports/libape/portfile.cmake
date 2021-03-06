include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/evpobr/libape/archive/d37597d7f3acf5fffc43f7d03f031ed665be35c3.zip"
    FILENAME "d37597d7f3acf5fffc43f7d03f031ed665be35c3.zip"
    SHA512 86966eb27c263c18045329c7b320f57b821bf70040197f5eadbfa2017f6683f0e0223f02ddee0a678bd9bcc68a00616be1b660cda34c3bb455af2fb25a0abdd4
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    NO_CHARSET_FLAG # automatic templates
#    GENERATOR "NMake Makefiles" # automatic templates
#    DISABLE_PARALLEL_CONFIGURE
    OPTIONS_DEBUG # automatic templates
      -DDISABLE_INSTALL_HEADERS=ON # automatic templates
      -DINSTALL_HEADERS_TOOLS=OFF
      -DINSTALL_HEADERS=OFF
    OPTIONS_RELEASE 
      -DINSTALL_HEADERS=ON # automatic templates
#      -D =OFF
    OPTIONS 
      -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/LICENSE.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
