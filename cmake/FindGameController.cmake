# PORTED FROM: PCSX2 macOS CMake — BionicSX2 iOS Port
# AUDIT REFERENCE: Section 8.3
# STATUS: NEW — Find module for GameController.framework

# Audit Sec 8.3: GameController.framework for GCController input

find_library(GameController_LIBRARY GameController)
find_path(GameController_INCLUDE_DIR GameController/GameController.h)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GameController DEFAULT_MSG
    GameController_LIBRARY GameController_INCLUDE_DIR)

mark_as_advanced(GameController_LIBRARY GameController_INCLUDE_DIR)

if(GameController_FOUND AND NOT TARGET GameController::GameController)
    add_library(GameController::GameController UNKNOWN IMPORTED)
    set_target_properties(GameController::GameController PROPERTIES
        IMPORTED_LOCATION "${GameController_LIBRARY}"
        INTERFACE_INCLUDE_DIRECTORIES "${GameController_INCLUDE_DIR}")
endif()
