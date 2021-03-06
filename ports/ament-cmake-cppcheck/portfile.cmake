include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/ament/ament_lint/archive/6394b098b77173b3dd76bb6fd99ddc6979686331.zip"
    FILENAME "6394b098b77173b3dd76bb6fd99ddc6979686331.zip"
    SHA512 3499c1e7da2c826661b53ca0f82c6b606d1e52093c8de56e4ff9cdf6b767d4e3abac0a1b1b53b941b7d491299995eace0a32c0f635d7b403e5e26042d52c9a81
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
)

vcpkg_find_acquire_program(PYTHON3)
get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PYTHON3_DIR}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/ament_cmake_cppcheck
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    NO_CHARSET_FLAG # automatic templates

    OPTIONS 
      -DAMENT_CMAKE_ENVIRONMENT_GENERATION=OFF
      -DAMENT_CMAKE_ENVIRONMENT_PACKAGE_GENERATION=ON
      -DAMENT_CMAKE_ENVIRONMENT_PARENT_PREFIX_PATH_GENERATION=ON
      -DAMENT_CMAKE_SYMLINK_INSTALL=OFF
      -DAMENT_CMAKE_UNINSTALL_TARGET=OFF
      -DBUILD_TESTING=OFF
)

vcpkg_install_cmake()

set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
