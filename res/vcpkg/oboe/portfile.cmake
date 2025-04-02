vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/oboe
    REF 1.8.0
    SHA512 b5f4cf103d1929ed56fd12b6fd32ba4146e35acae02a65cdfc18e3f83320bf4e8e1e0c63e72c6f571acbe3eea8f5cc13fe98abb24698895b02935c2a24786b13
    HEAD_REF main
    PATCHES
        fix_install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/oboe)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright) 