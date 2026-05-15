# PORTED FROM: PCSX2 macOS CMake — BionicSX2 iOS Port
# AUDIT REFERENCE: Section 4.3
# STATUS: NEW — Find module for UIKit.framework

# Audit Sec 4.3: UIKit replaces AppKit on iOS

find_library(UIKit_LIBRARY UIKit)
find_path(UIKit_INCLUDE_DIR UIKit/UIKit.h)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(UIKit DEFAULT_MSG
    UIKit_LIBRARY UIKit_INCLUDE_DIR)

mark_as_advanced(UIKit_LIBRARY UIKit_INCLUDE_DIR)

if(UIKit_FOUND AND NOT TARGET UIKit::UIKit)
    add_library(UIKit::UIKit UNKNOWN IMPORTED)
    set_target_properties(UIKit::UIKit PROPERTIES
        IMPORTED_LOCATION "${UIKit_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${UIKit_INCLUDE_DIR}")
endif()
