vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libsdl-org/SDL_mixer
    REF 7804621c533dddfe970e97c94c4ea72d48ed7f48
    SHA512 5b15bf81b868968a09f82b160e371355e40a29c95a3e79c3cffa49ab5cc7c3212034d12301c21c8a44aef5c981a7a8fec3cb76e9dfe55619159a613b8dec6557
    HEAD_REF SDL-1.2
    PATCHES
        mpg123_ssize_t.patch
)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    file(COPY "${CMAKE_CURRENT_LIST_DIR}/SDL_mixer_2017.sln" DESTINATION "${SOURCE_PATH}/VisualC/")
    
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(LIB_TYPE StaticLibrary)
    else()
        set(LIB_TYPE DynamicLibrary)
    endif()
    
    if(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
        set(CRT_TYPE_DBG MultiThreadedDebugDLL)
        set(CRT_TYPE_REL MultiThreadedDLL)
    else()
        set(CRT_TYPE_DBG MultiThreadedDebug)
        set(CRT_TYPE_REL MultiThreaded)
    endif()
    
    configure_file("${CURRENT_PORT_DIR}/SDL_mixer.vcxproj.in" "${SOURCE_PATH}/VisualC/SDL_mixer.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/native_midi.vcxproj.in" "${SOURCE_PATH}/VisualC/native_midi/native_midi.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/timidity.vcxproj.in" "${SOURCE_PATH}/VisualC/timidity/timidity.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/playmus.vcxproj.in" "${SOURCE_PATH}/VisualC/playmus/playmus.vcxproj" @ONLY)
    configure_file("${CURRENT_PORT_DIR}/playwave.vcxproj.in" "${SOURCE_PATH}/VisualC/playwave/playwave.vcxproj" @ONLY)
    
    # This text file gets copied as a library, and included as one in the package 
    file(REMOVE "${SOURCE_PATH}/external/libmikmod/COPYING.LIB")

    # Remove unused external dlls
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libFLAC-8.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libmikmod-2.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libmpg123-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libogg-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libvorbis-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x86/libvorbisfile-3.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libFLAC-8.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libmikmod-2.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libmpg123-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libogg-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libvorbis-0.dll")
    file(REMOVE "${SOURCE_PATH}/VisualC/external/lib/x64/libvorbisfile-3.dll")
    
    vcpkg_install_msbuild(
        SOURCE_PATH "${SOURCE_PATH}"
        PROJECT_SUBPATH VisualC/SDL_mixer_2017.sln
        #INCLUDES_SUBPATH include
        LICENSE_SUBPATH COPYING
        #ALLOW_ROOT_INCLUDES
    )
    file(COPY "${SOURCE_PATH}/SDL_mixer.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/SDL")
else()
    if(VCPKG_TARGET_IS_LINUX)
        message("libgles2-mesa-dev must be installed before sdl1 can build. Install it with \"apt install libgles2-mesa-dev\".")
    endif()

    find_program(WHICH_COMMAND NAMES which)
    if(NOT WHICH_COMMAND)
        set(polyfill_scripts "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-bin")
        file(REMOVE_RECURSE "${polyfill_scripts}")
        file(MAKE_DIRECTORY "${polyfill_scripts}")
        vcpkg_host_path_list(APPEND ENV{PATH} "${polyfill_scripts}")
        # sdl's autoreconf.sh needs `which`, but our msys root doesn't have it.
        file(WRITE "${polyfill_scripts}/which" "#!/bin/sh\nif test -f \"/usr/bin/\$1\"; then echo \"/usr/bin/\$1\"; else false; fi\n")
        file(CHMOD "${polyfill_scripts}/which" PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE)
    endif()

    vcpkg_configure_make(
        SOURCE_PATH "${SOURCE_PATH}"
    )
    
    vcpkg_install_make()
    vcpkg_fixup_pkgconfig()
    
    file(REMOVE_RECURSE
        "${CURRENT_PACKAGES_DIR}/debug/share"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/man3"
    )

    file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
endif()
