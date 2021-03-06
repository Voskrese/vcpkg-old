## # vcpkg_configure_cmake
##
## Configure CMake for Debug and Release builds of a project.
##
## ## Usage
## ```cmake
## vcpkg_configure_cmake(
##     SOURCE_PATH <${SOURCE_PATH}>
##     [PREFER_NINJA]
##     [DISABLE_PARALLEL_CONFIGURE]
##     [NO_CHARSET_FLAG]
##     [GENERATOR <"NMake Makefiles">]
##     [OPTIONS <-DUSE_THIS_IN_ALL_BUILDS=1>...]
##     [OPTIONS_RELEASE <-DOPTIMIZE=1>...]
##     [OPTIONS_DEBUG <-DDEBUGGABLE=1>...]
## )
## ```
##
## ## Parameters
## ### SOURCE_PATH
## Specifies the directory containing the `CMakeLists.txt`.
## By convention, this is usually set in the portfile as the variable `SOURCE_PATH`.
##
## ### PREFER_NINJA
## Indicates that, when available, Vcpkg should use Ninja to perform the build.
## This should be specified unless the port is known to not work under Ninja.
##
## ### DISABLE_PARALLEL_CONFIGURE
## Disables running the CMake configure step in parallel.
## This is needed for libraries which write back into their source directory during configure.
##
## ### NO_CHARSET_FLAG
## Disables passing `utf-8` as the default character set to `CMAKE_C_FLAGS` and `CMAKE_CXX_FLAGS`.
##
## This is needed for libraries that set their own source code's character set.
##
## ### GENERATOR
## Specifies the precise generator to use.
##
## This is useful if some project-specific buildsystem has been wrapped in a cmake script that won't perform an actual build.
## If used for this purpose, it should be set to "NMake Makefiles".
##
## ### OPTIONS
## Additional options passed to CMake during the configuration.
##
## ### OPTIONS_RELEASE
## Additional options passed to CMake during the Release configuration. These are in addition to `OPTIONS`.
##
## ### OPTIONS_DEBUG
## Additional options passed to CMake during the Debug configuration. These are in addition to `OPTIONS`.
##
## ## Notes
## This command supplies many common arguments to CMake. To see the full list, examine the source.
##
## ## Examples
##
## * [zlib](https://github.com/Microsoft/vcpkg/blob/master/ports/zlib/portfile.cmake)
## * [cpprestsdk](https://github.com/Microsoft/vcpkg/blob/master/ports/cpprestsdk/portfile.cmake)
## * [poco](https://github.com/Microsoft/vcpkg/blob/master/ports/poco/portfile.cmake)
## * [opencv](https://github.com/Microsoft/vcpkg/blob/master/ports/opencv/portfile.cmake)
function(vcpkg_configure_cmake)
    cmake_parse_arguments(_csc 
        "PREFER_NINJA;DISABLE_PARALLEL_CONFIGURE;NO_CHARSET_FLAG"
        "SOURCE_PATH;GENERATOR"
        "OPTIONS;OPTIONS_DEBUG;OPTIONS_RELEASE"
        ${ARGN}
    )

    if(NOT VCPKG_PLATFORM_TOOLSET)
        message(FATAL_ERROR "Vcpkg has been updated with VS2017 support; "
            "however, vcpkg.exe must be rebuilt by re-running bootstrap-vcpkg.bat\n")
    endif()

    if(CMAKE_HOST_WIN32)
        set(_PATHSEP ";")
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(_csc_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(_csc_HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
        endif()
    else()
        set(_PATHSEP ":")
    endif()

    set(NINJA_CAN_BE_USED ON) # Ninja as generator
    set(NINJA_HOST ON) # Ninja as parallel configurator

    if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        set(_TARGETTING_UWP 1)
    endif()

    if(_csc_HOST_ARCHITECTURE STREQUAL "x86")
        # Prebuilt ninja binaries are only provided for x64 hosts
        set(NINJA_CAN_BE_USED OFF)
        set(NINJA_HOST OFF)
    elseif(_TARGETTING_UWP)
        # Ninja and MSBuild have many differences when targetting UWP, so use MSBuild to maximize existing compatibility
        set(NINJA_CAN_BE_USED OFF)
        set(NINJA_HOST OFF)
    elseif(VCPKG_PLATFORM_TOOLSET STREQUAL "Intel")
        set(NINJA_CAN_BE_USED OFF)
        set(NINJA_HOST OFF)
    endif()

    if(_csc_GENERATOR)
        set(GENERATOR ${_csc_GENERATOR})
    elseif(_csc_PREFER_NINJA AND NINJA_CAN_BE_USED)
        set(GENERATOR "Ninja")
    elseif(VCPKG_CHAINLOAD_TOOLCHAIN_FILE OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT _TARGETTING_UWP))
        set(GENERATOR "Ninja")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
        set(GENERATOR "Visual Studio 12 2013")
        set(ARCH "Win32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
        set(GENERATOR "Visual Studio 12 2013")
        set(ARCH "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v120")
        set(GENERATOR "Visual Studio 12 2013 ARM")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(GENERATOR "Visual Studio 14 2015")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(GENERATOR "Visual Studio 14 2015 Win64")
#        set(ARCH "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v140")
        set(GENERATOR "Visual Studio 14 2015 ARM")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017 Win64")
#        set(ARCH "x64")
#        set(VS_PLATFORM_TOOLSET "Intel C++ Compiler 19.0")
#        set(NINJA_CAN_BE_USED OFF)
#        set(NINJA_HOST OFF)
#        set(PREFER_NINJA OFF)
        if(VS_PLATFORM_TOOLSET_OVERRIDE)
            set_property(TARGET ${project} PROPERTY VS_PLATFORM_TOOLSET_OVERRIDE "Intel C++ Compiler 19.0,host=x64")
        endif()
#        IF(VCMDDAndroid)
#            SET_PROPERTY(TARGET ${LIB_NAME} PROPERTY VC_MDD_ANDROID_API_LEVEL "android-21")
#        ELSE(${CMAKE_VS_PLATFORM_TOOLSET} STREQUAL "Intel C++ Compiler 19.0")
#            SET_PROPERTY(TARGET ${project} PROPERTY VS_PLATFORM_TOOLSET_OVERRIDE "Intel C++ Compiler 19.0")
#        ELSE(${CMAKE_VS_PLATFORM_TOOLSET} STREQUAL "v140_clang_3_7")
#            SET_PROPERTY(TARGET ${project} PROPERTY VS_PLATFORM_TOOLSET_OVERRIDE "v140_clang_3_7")
#        ENDIF()
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017 ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v141")
        set(GENERATOR "Visual Studio 15 2017")
        set(ARCH "ARM64")

    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "Win32")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "x64")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "ARM")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" AND VCPKG_PLATFORM_TOOLSET STREQUAL "v142")
        set(GENERATOR "Visual Studio 16 2019")
        set(ARCH "ARM64")
#        set(VS_PLATFORM_TOOLSET_OVERRIDE "Intel C++ Compiler 19.0")
#        set(CMAKE_GENERATOR_TOOLSET "Intel C++ Compiler 19.0" CACHE STRING "Platform Toolset" FORCE)
#        -G"Visual Studio 15 2017" -T"Intel C++ Compiler 19.0",host=x64 -Ax64
    else()
        if(NOT VCPKG_CMAKE_SYSTEM_NAME)
            set(VCPKG_CMAKE_SYSTEM_NAME Windows)
        endif()
        message(FATAL_ERROR "Unable to determine appropriate generator for: "
            "${VCPKG_CMAKE_SYSTEM_NAME}-${VCPKG_TARGET_ARCHITECTURE}-${VCPKG_PLATFORM_TOOLSET}")
    endif()

    # If we use Ninja, make sure it's on PATH
    if(GENERATOR STREQUAL "Ninja")
        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH}${_PATHSEP}${NINJA_PATH}")
        list(APPEND _csc_OPTIONS "-DCMAKE_MAKE_PROGRAM=${NINJA}")
        set(ENV{NINJA_STATUS} "[%r processes, %f/%t @ %o/s : %es ]")
        # -w dupbuild=warn
    endif()

    file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
	sleep(1)

    if(DEFINED VCPKG_CMAKE_SYSTEM_NAME)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_NAME=${VCPKG_CMAKE_SYSTEM_NAME}")
        if(_TARGETTING_UWP AND NOT DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
            set(VCPKG_CMAKE_SYSTEM_VERSION 10.0)
        endif()
    endif()

    if(DEFINED VCPKG_CMAKE_SYSTEM_VERSION)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_VERSION=${VCPKG_CMAKE_SYSTEM_VERSION}")
    endif()
    
    if(DEFINED VCPKG_CMAKE_SYSTEM_PROCESSOR)
        list(APPEND _csc_OPTIONS "-DCMAKE_SYSTEM_PROCESSOR=${VCPKG_CMAKE_SYSTEM_PROCESSOR}")
    endif()
    
    list(APPEND _csc_OPTIONS "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}")

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=OFF -DLIBRARY_TYPE=shared -DCMAKE_EXPORT_COMPILE_COMMANDS=ON)
#        list(APPEND _csc_OPTIONS -DBUILD_STATIC_LIBS=OFF -DBUILD_STATIC=OFF -DBUILD_SHARED=ON -DLIBRARY_TYPE=shared -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -DBUILD_BOTH_STATIC_SHARED_LIB=ON)
#        list(APPEND _csc_OPTIONS -DBUILD_BOTH_STATIC_SHARED_LIB=ON -DBUILD_SHARED_LIBS=ON -DBUILD_SHARED=ON -DBUILD_STATIC_LIBS=OFF -DBUILD_STATIC_CRT_LIBS=OFF -DBUILD_STATIC=OFF )
    elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
#        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=OFF)
#        list(APPEND _csc_OPTIONS -DBUILD_STATIC_BIN=ON -DBUILD_BOTH_STATIC_SHARED_LIB=ON -DBUILD_STATIC_CRT_LIBS=ON -DBUILD_STATIC=ON -DENABLE_STATIC=ON -DBUILD_SHARED=OFF )
        list(APPEND _csc_OPTIONS -DBUILD_SHARED_LIBS=OFF -DBUILD_STATIC_LIBS=ON -DLIBRARY_TYPE=static -DCMAKE_EXPORT_COMPILE_COMMANDS=ON)
    else()
        message(FATAL_ERROR
            "Invalid setting for VCPKG_LIBRARY_LINKAGE: \"${VCPKG_LIBRARY_LINKAGE}\". "
            "It must be \"static\" or \"dynamic\"")
    endif()

    if((NOT DEFINED VCPKG_CXX_FLAGS_DEBUG AND NOT DEFINED VCPKG_C_FLAGS_DEBUG) OR
        (DEFINED VCPKG_CXX_FLAGS_DEBUG AND DEFINED VCPKG_C_FLAGS_DEBUG))
#        set(
    else()
        message(FATAL_ERROR "You must set both the VCPKG_CXX_FLAGS_DEBUG and VCPKG_C_FLAGS_DEBUG")
    endif()
    if((NOT DEFINED VCPKG_CXX_FLAGS_RELEASE AND NOT DEFINED VCPKG_C_FLAGS_RELEASE) OR
        (DEFINED VCPKG_CXX_FLAGS_RELEASE AND DEFINED VCPKG_C_FLAGS_RELEASE))
#        set(
    else()
        message(FATAL_ERROR "You must set both the VCPKG_CXX_FLAGS_RELEASE and VCPKG_C_FLAGS_RELEASE")
    endif()
    if((NOT DEFINED VCPKG_CXX_FLAGS AND NOT DEFINED VCPKG_C_FLAGS) OR
        (DEFINED VCPKG_CXX_FLAGS AND DEFINED VCPKG_C_FLAGS))
#        set(
    else()
        message(FATAL_ERROR "You must set both the VCPKG_CXX_FLAGS and VCPKG_C_FLAGS")
    endif()

    set(VCPKG_SET_CHARSET_FLAG ON)
    if(_csc_NO_CHARSET_FLAG)
        set(VCPKG_SET_CHARSET_FLAG OFF)
    endif()

    if(NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
        if(NOT DEFINED VCPKG_CMAKE_SYSTEM_NAME OR _TARGETTING_UWP)
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/windows.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/linux.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Android")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/android.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/osx.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
            set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE "${SCRIPTS}/toolchains/freebsd.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MinGW")
            list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${SCRIPTS}/toolchains/mingw.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MSYS")
            list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${SCRIPTS}/toolchains/msys64.cmake")
        elseif(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "MipsEL")
            list(APPEND _csc_OPTIONS "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${SCRIPTS}/toolchains/mips32r2.cmake")
        endif()
    endif()


    list(APPEND _csc_OPTIONS
#        "-DCMAKE_SYSTEM_PROCESSOR=AMD64"
#        "-DCMAKE_SYSTEM_VERSION=10.0.17134"
#        "-DCMAKE_VS_DEVENV_COMMAND=C:/VS2017/Common7/IDE/devenv.com"
#        "-DCMAKE_VS_INTEL_Fortran_PROJECT_VERSION=11.0"
#        "-DCMAKE_VS_MSBUILD_COMMAND=C:/VS2017/MSBuild/15.0/Bin/MSBuild.exe"
#        "-DCMAKE_VS_PLATFORM_NAME=x64"
#        "-DCMAKE_VS_PLATFORM_TOOLSET=Intel C++ Compiler 19.0"
#        "-DCMAKE_VS_WINDOWS_TARGET_PLATFORM_VERSION=10.0.17134.0"
        "-DVCPKG_CHAINLOAD_TOOLCHAIN_FILE=${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}"
        "-DVCPKG_TARGET_TRIPLET=${TARGET_TRIPLET}"
        "-DVCPKG_SET_CHARSET_FLAG=${VCPKG_SET_CHARSET_FLAG}"
        "-DVCPKG_PLATFORM_TOOLSET=${VCPKG_PLATFORM_TOOLSET}"
        "-DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_PACKAGE_REGISTRY=ON"
        "-DCMAKE_FIND_PACKAGE_NO_SYSTEM_PACKAGE_REGISTRY=ON"
        "-DCMAKE_INSTALL_SYSTEM_RUNTIME_LIBS_SKIP=TRUE"
        "-DCMAKE_VERBOSE_MAKEFILE=ON"
        "-DVCPKG_APPLOCAL_DEPS=OFF"
        "-DCMAKE_TOOLCHAIN_FILE=${SCRIPTS}/buildsystems/vcpkg.cmake"
        "-DCMAKE_ERROR_ON_ABSOLUTE_INSTALL_DESTINATION=ON"
        "-DVCPKG_CXX_FLAGS=${VCPKG_CXX_FLAGS}"
        "-DVCPKG_CXX_FLAGS_RELEASE=${VCPKG_CXX_FLAGS_RELEASE}"
        "-DVCPKG_CXX_FLAGS_DEBUG=${VCPKG_CXX_FLAGS_DEBUG}"
        "-DVCPKG_C_FLAGS=${VCPKG_C_FLAGS}"
        "-DVCPKG_C_FLAGS_RELEASE=${VCPKG_C_FLAGS_RELEASE}"
        "-DVCPKG_C_FLAGS_DEBUG=${VCPKG_C_FLAGS_DEBUG}"
        "-DVCPKG_CRT_LINKAGE=${VCPKG_CRT_LINKAGE}"
        "-DVCPKG_LINKER_FLAGS=${VCPKG_LINKER_FLAGS}"
        "-DVCPKG_TARGET_ARCHITECTURE=${VCPKG_TARGET_ARCHITECTURE}"
        "-DCMAKE_INSTALL_LIBDIR:STRING=lib"
        "-DCMAKE_INSTALL_BINDIR:STRING=bin"
        "-DVCPKG_FORTRAN_COMPILER=${VCPKG_FORTRAN_COMPILER}" 
        "-DVCPKG_FORTRAN_ENABLED=${VCPKG_FORTRAN_ENABLED}" 
    )

    if(DEFINED ARCH)
        list(APPEND _csc_OPTIONS
            "-A${ARCH}"
        )
    endif()

    if(DEFINED VS_PLATFORM_TOOLSET)
        list(APPEND _csc_OPTIONS
            "-T${VS_PLATFORM_TOOLSET}"
        )
#        set(NINJA_CAN_BE_USED OFF) # Ninja as generator
#    else()
#        set(NINJA_CAN_BE_USED ON) # Ninja as generator        
    endif()

    # Sets configuration variables for macOS builds
    foreach(config_var  INSTALL_NAME_DIR OSX_DEPLOYMENT_TARGET OSX_SYSROOT)
        if(DEFINED VCPKG_${config_var})
            list(APPEND _csc_OPTIONS "-DCMAKE_${config_var}=${VCPKG_${config_var}}")
        endif()
    endforeach()
    
    if(DEFINED CMAKE_IGNORE_PATH)
        list(APPEND _csc_OPTIONS "-DCMAKE_IGNORE_PATH=${CMAKE_IGNORE_PATH}")
    endif()
	
    set(rel_command
        ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} "${_csc_OPTIONS}" "${_csc_OPTIONS_RELEASE}"
        -G ${GENERATOR}
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_IGNORE_PATH=${CURRENT_INSTALLED_DIR}/debug
#        -DCMAKE_SYSTEM_IGNORE_PATH=${CURRENT_INSTALLED_DIR}/debug
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR})
    set(dbg_command
        ${CMAKE_COMMAND} ${_csc_SOURCE_PATH} "${_csc_OPTIONS}" "${_csc_OPTIONS_DEBUG}"
        -G ${GENERATOR}
        -DCMAKE_BUILD_TYPE=Debug
        -DCMAKE_INSTALL_PREFIX=${CURRENT_PACKAGES_DIR}/debug)

    if(NINJA_HOST AND CMAKE_HOST_WIN32 AND NOT _csc_DISABLE_PARALLEL_CONFIGURE)

        vcpkg_find_acquire_program(NINJA)
        get_filename_component(NINJA_PATH ${NINJA} DIRECTORY)
        set(ENV{PATH} "$ENV{PATH}${_PATHSEP}${NINJA_PATH}")
#        set(ENV{NINJA_STATUS} "[%u/%r/%f] ")
        set(ENV{NO-DEV} True)

        #parallelize the configure step
        set(_contents
            "rule CreateProcess\n  command = $process\n\n"
        )

        macro(_build_cmakecache whereat build_type)
            set(${build_type}_line "build ${whereat}/CMakeCache.txt: CreateProcess\n  process = cmd /c \"cd ${whereat} &&")
            foreach(arg ${${build_type}_command})
                set(${build_type}_line "${${build_type}_line} \"${arg}\"")
            endforeach()
            set(_contents "${_contents}${${build_type}_line}\"\n\n")
        endmacro()

        if(NOT DEFINED VCPKG_BUILD_TYPE)
            _build_cmakecache(".." "rel")
            _build_cmakecache("../../${TARGET_TRIPLET}-dbg" "dbg")
        elseif(VCPKG_BUILD_TYPE STREQUAL "release")
            _build_cmakecache(".." "rel")
        elseif(VCPKG_BUILD_TYPE STREQUAL "debug")
            _build_cmakecache("../../${TARGET_TRIPLET}-dbg" "dbg")
        endif()

        file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure)
        file(WRITE ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure/build.ninja "${_contents}")

        message(STATUS "Configuring ${TARGET_TRIPLET}")
        vcpkg_execute_required_process(
            COMMAND ninja -v
            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure
            LOGNAME config-${TARGET_TRIPLET}
        )
    else()
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
            message(STATUS "Configuring ${TARGET_TRIPLET}-dbg")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg)
            vcpkg_execute_required_process(
                COMMAND ${dbg_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg
                LOGNAME config-${TARGET_TRIPLET}-dbg
            )
        endif()
		
#            if(NOT EXISTS NINJA_STATUS)
#            set(ENV{NINJA_STATUS} "[%u/%r/%f] ")
#            set(ENV{NINJA_STATUS} "[%s/%t] ")
#            execute_process(
#                COMMAND ${CMAKE_COMMAND} -E env NINJA_STATUS="[%u/%r/%f] "
		
#        if(NOT EXISTS NINJA_STATUS)
#        set(ENV{NINJA_STATUS} "[%p] ")
#        execute_process(
#            COMMAND ${CMAKE_COMMAND} -E env CLICOLOR_FORCE=1
#            COMMAND ${CMAKE_COMMAND} -E env NINJA_STATUS="[%p] "
#            COMMAND ninja -v
#            WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/vcpkg-parallel-configure
#            RESULT_VARIABLE config-${TARGET_TRIPLET}
#        )
#        endif()

        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
            message(STATUS "Configuring ${TARGET_TRIPLET}-rel")
            file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel)
            vcpkg_execute_required_process(
                COMMAND ${rel_command}
                WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel
                LOGNAME config-${TARGET_TRIPLET}-rel
            )
        endif()
    endif()

    set(_VCPKG_CMAKE_GENERATOR "${GENERATOR}" PARENT_SCOPE)
endfunction()
