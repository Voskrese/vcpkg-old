# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   CMAKE_CURRENT_LIST_DIR    = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)

#string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" KEYSTONE_BUILD_STATIC)
#string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" KEYSTONE_BUILD_SHARED)
#vcpkg_configure_cmake(
#    SOURCE_PATH ${SOURCE_PATH}
#    PREFER_NINJA
#    OPTIONS
#        -DKEYSTONE_BUILD_STATIC=${KEYSTONE_BUILD_STATIC}
#        -DKEYSTONE_BUILD_SHARED=${KEYSTONE_BUILD_SHARED}
#)
#string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CURL_STATICLIB)
#vcpkg_check_linkage(ONLY_STATIC_LIBRARY) ## = ## VCPKG_LIBRARY_LINKAGE=static ## = ## BUILD_STATIC_LIBS=ON
#vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_DYNAMIC_CRT)
#vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
#vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY ONLY_DYNAMIC_CRT)
###

#создаем пустой репозитор
#git init .
#добавляем в него все файлы
#git add .
#создаем бранч\коммит\точку
#git commit -m "patch"

#редактируем файлы
#и создаем патч на основе коммит
#git diff > ..\..\..\..\ports\pocl\patch.patch

#git init . && git add . && git commit -m "patch"
#git diff > ..\..\..\..\ports\pocl\001_pocl_patch.patch

#configure_file(${SOURCE_PATH}/config.h.in ${SOURCE_PATH}/config.h COPYONLY)

#configure_file(config.h.in config.h)
#configure_file(${CMAKE_CURRENT_LIST_DIR}/config.h.in ${SOURCE_PATH})

include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/pocl/pocl/archive/v1.3.zip"
    FILENAME "pocl.zip"
    SHA512 29e955c3d62ac1e0ba6c5084b0f99432edf463b8345e3175b474931ed4652e1b7875500f1d3ea3fc2b4e43274312c87414d20775e7a6f5f958997ae8e5d305ac
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
#    PATCHES
#      001_pocl_fixes.patch
#      001_pocl_patch.patch
)

#if(NOT EXISTS "${SOURCE_PATH}/.git")
#	message(STATUS "Cloning and fetching submodules")
#	set(error_code 1)
#	set(number_of_tries 0)
#	while(error_code AND number_of_tries LESS 3)
#	  execute_process(
#	  COMMAND ${GIT} clone --recurse-submodules --progress ${GIT_URL} ${SOURCE_PATH}
#	  WORKING_DIRECTORY ${SOURCE_PATH}
#	  RESULT_VARIABLE error_code
#	)
#	math(EXPR number_of_tries "${number_of_tries} + 1")
#	endwhile()
#	if(number_of_tries GREATER 1)
#		message(STATUS "Had to git clone more than once:	${number_of_tries} times.")
#	endif()
#	if(error_code)
#		message(FATAL_ERROR "Failed to clone repository: '${GIT_URL}'")
#	endif()
#	message(STATUS "Checkout revision ${GIT_REV}")
#	vcpkg_execute_required_process(
#	  COMMAND ${GIT} checkout ${GIT_REV}
#	  WORKING_DIRECTORY ${SOURCE_PATH}
#	  LOGNAME checkout
#	)
#endif()


#vcpkg_from_bitbucket(
#set(OPENEXR_VERSION 2.3.0)
#set(OPENEXR_HASH 268ae64b40d21d662f405fba97c307dad1456b7d996a447aadafd41b640ca736d4851d9544b4741a94e7b7c335fe6e9d3b16180e710671abfc0c8b2740b147b2)
#vcpkg_from_github(
#  OUT_SOURCE_PATH SOURCE_PATH
#  REPO openexr/openexr
#  REF v${OPENEXR_VERSION}
#  SHA512 ${OPENEXR_HASH}
#  HEAD_REF master
#  PATCHES
#    fix_clang_not_setting_modern_cplusplus.patch
#    fix_install_ilmimf.patch
#)


vcpkg_find_acquire_program(CLANG)
get_filename_component(LLVM_BINDIR "${CLANG}" DIRECTORY)
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
set(SH_EXE_PATH "${GIT_EXE_PATH}/../usr/bin")

set(ENV{LLVM_ROOT} ${LLVM_BINDIR})

#-DLLVM_CONFIG_PATH=D:\\sdk\\llvm-5.0.0\\bin\\llvm-config.exe
#set({LLVM_ROOT_DIR} "${LLVM_ROOT}/..")

#set(ENV{LLVM_LIBDIR} ${LLVM_ROOT_DIR}/lib/clang/9.0.0)
#set(ENV{LLVM_LDFLAGS} -LIBPATH:${LLVM_LIBDIR})


###LLVM_CONFIG=/usr/local/opt/llvm/bin/llvm-config pip install numba
#LLVM_PREFIX E:\tools\LLVM-4
#LLVM_LDFLAGS -LIBPATH:E:\tools\LLVM-4\lib
#LLVM_BINDIR E:\tools\LLVM-4\bin
#LLVM_LIBDIR E:\tools\LLVM-4\lib
#LLVM_INCLUDEDIR E:\tools\LLVM-4/include
#LLVM_SRC_ROOT C:/conda64/conda-bld/llvmdev_1521553314209/work
#LLVM_OBJ_ROOT E:\tools\LLVM-4
#LLVM_ALL_TARGETS X86
#LLVM_HOST_TARGET x86_64-pc-windows-msvc

#set(LLVM_INCLUDE_DIRS "${LLVM_ROOT}/include")
#set(LLVM_LIBRARY_DIRS "${LLVM_ROOT}/lib")

#set(ENV{LLVM-CONFIG} "${LLVM_ROOT}/bin/llvm-config")

set(ENV{PATH} "$ENV{PATH};${LLVM_BINDIR};${SH_EXE_PATH}")

#vcpkg_find_acquire_program(PYTHON3)
#vcpkg_find_acquire_program(QT5)
#vcpkg_find_acquire_program(TEXLIVE)
#vcpkg_find_acquire_program(XGETTEXT)
#vcpkg_find_acquire_program(DOXYGEN)
#vcpkg_find_acquire_program(DOXYGEN)
#vcpkg_find_acquire_program(PERL)
#vcpkg_find_acquire_program(FLEX)
#vcpkg_find_acquire_program(BISON)
#get_filename_component(FLEX_DIR "${FLEX}" DIRECTORY)
#get_filename_component(BISON_DIR "${BISON}" DIRECTORY)
#get_filename_component(DOXYGEN_DIR "${DOXYGEN}" DIRECTORY)
#get_filename_component(PERL_DIR "${PERL}" DIRECTORY)
#get_filename_component(QT5_DIR "${QT5}" DIRECTORY)
#get_filename_component(PYTHON3_DIR "${PYTHON3}" DIRECTORY)
#get_filename_component(DOXYGEN_DIR "${DOXYGEN}" DIRECTORY)
#get_filename_component(XGETTEXT_DIR "${XGETTEXT}" DIRECTORY)
#get_filename_component(TEXLIVE_DIR "${TEXLIVE}" DIRECTORY)
#set(ENV{PATH} ";$ENV{PATH};${QT5_DIR};${PYTHON3_DIR};${DOXYGEN_DIR};${XGETTEXT_DIR};${TEXLIVE_DIR};${FLEX_DIR};${BISON_DIR};${DOXYGEN_DIR};${PERL_DIR}")
#vcpkg_find_acquire_program(YASM)
#get_filename_component(YASM_EXE_PATH ${YASM} DIRECTORY)
#set(ENV{PATH} "$ENV{PATH};${YASM_EXE_PATH}")



#file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    NO_CHARSET_FLAG # automatic templates

    OPTIONS 
#      -DWITH_LLVM_CONFIG=${LLVM_ROOT}/llvm-config #LLVM binaries suffix
	  -DLLVM_CONFIG_PATH=${LLVM_ROOT}/llvm-config

)

vcpkg_install_cmake()

### https://mesonbuild.com/Configuring-a-build-directory.html
#vcpkg_configure_meson(
#    SOURCE_PATH ${SOURCE_PATH}
#    OPTIONS
#      --backend=ninja
#)

#vcpkg_install_meson()

###
#msbuild build-package.proj /t:Clean;BeforeBuild
#msbuild build.proj /t:Build
#msbuild build-package.proj /t:PreparePackage;Package

#vcpkg_install_msbuild(
#    SOURCE_PATH ${SOURCE_PATH}
#    PROJECT_SUBPATH "ide/vs2017/mimalloc.vcxproj"
#    TARGET restore
#    SKIP_CLEAN
#    RELEASE_CONFIGURATION Release_x86${MPG123_CONFIGURATION_SUFFIX}
#    DEBUG_CONFIGURATION Debug_x86${MPG123_CONFIGURATION_SUFFIX}
#    LICENSE_SUBPATH LICENSE
#    ALLOW_ROOT_INCLUDES ON
#    USE_VCPKG_INTEGRATION
#)

#file(GLOB_RECURSE TMP_FILES "${SOURCE_PATH}/include/*.hin" "${SOURCE_PATH}/include/*.orig" "${SOURCE_PATH}/include/*.in")
#file(REMOVE_RECURSE ${TMP_FILES})

#remove_srcs_file("${SOURCE_PATH}/include/*.hin" "${SOURCE_PATH}/include/*.orig" "${SOURCE_PATH}/include/*.in")

#file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/include)
#file(RENAME ${CURRENT_PACKAGES_DIR}/include/include ${CURRENT_PACKAGES_DIR}/include/openldap)

#file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include" PGSQL_INCLUDE_DIR)
#file(COPY ${CURRENT_PACKAGES_DIR}/wpilib/lib/ DESTINATION ${CURRENT_PACKAGES_DIR}/bin FILES_MATCHING PATTERN "*.dll")
#file(COPY ${SOURCE_PATH}/greatest.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

#vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/${PORT}")
#vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/nlohmann_json TARGET_PATH share/nlohmann_json)
#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
#file(RENAME ${CURRENT_PACKAGES_DIR}/lib/${LIB_NAME}.dll ${CURRENT_PACKAGES_DIR}/bin/${LIB_NAME}.dll
#file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/pocl RENAME copyright)

#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/debug)
#file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/debug/include)

#file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
#file(RENAME ${CURRENT_PACKAGES_DIR}/debug/bin ${CURRENT_PACKAGES_DIR}/tools/${PORT})

#vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME pocl)



set(VCPKG_POLICY_EMPTY_PACKAGE enabled) # automatic templates
vcpkg_copy_pdbs() # automatic templates
configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
###
