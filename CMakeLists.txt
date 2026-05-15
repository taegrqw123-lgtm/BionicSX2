# PORTED FROM: PCSX2 root CMakeLists.txt — BionicSX2 iOS Port
# AUDIT REFERENCE: Section 10.1, 10.2, 1.4, 1.5, 13.5
# STATUS: YELLOW — iOS-specific build configuration

# Audit Sec 13.5: Minimum CMake version for iOS support
# PORTED FROM: PCSX2 root CMakeLists.txt — BionicSX2 iOS Port
# AUDIT REFERENCE: Phase 7 — CMake Integration for iOS Target
# STATUS: YELLOW — iOS-specific build configuration

cmake_minimum_required(VERSION 3.20)
project(BionicSX2 VERSION 0.1.0 LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# ── iOS Guard ──
if(NOT CMAKE_SYSTEM_NAME STREQUAL "iOS")
    message(FATAL_ERROR "BionicSX2 targets iOS only. Use cmake/ios.toolchain.cmake")
endif()

# ── iOS-specific CMake Integration (Phase 7) ──

set(IOS_DEPS "${CMAKE_SOURCE_DIR}/ios-deps/install")

# Disable everything that doesn't exist on iOS
set(ENABLE_QT       OFF CACHE BOOL "" FORCE)
set(ENABLE_OPENGL   OFF CACHE BOOL "" FORCE)
set(ENABLE_VULKAN   OFF CACHE BOOL "" FORCE)
set(USE_SDL         OFF CACHE BOOL "" FORCE)
set(BUILD_TESTS     OFF CACHE BOOL "" FORCE)

# nVif: belt-and-suspenders at CMake level too (Audit Sec 2.3-F)
add_compile_definitions(PCSX2_TARGET_IOS=1)

# vixl: disable mmap JIT buffer
add_compile_definitions(VIXL_CODE_BUFFER_MMAP=0)

# Architecture: arm64 only (Audit Sec 1.2)
set(CMAKE_OSX_ARCHITECTURES "arm64" CACHE STRING "" FORCE)
set(CMAKE_OSX_DEPLOYMENT_TARGET "15.0" CACHE STRING "" FORCE)

# Find iOS dependencies from ios-deps/install
list(PREPEND CMAKE_PREFIX_PATH "${IOS_DEPS}")

find_package(ZLIB     REQUIRED QUIET)
find_package(PNG      QUIET)
find_package(Freetype QUIET)

find_library(FOUNDATION_FW       Foundation      REQUIRED)
find_library(AUDIOTOOLBOX_FW    AudioToolbox    REQUIRED)
find_library(AVFOUNDATION_FW    AVFoundation    REQUIRED)
find_library(COREAUDIO_FW       CoreAudio       REQUIRED)
find_library(COREFOUNDATION_FW  CoreFoundation  REQUIRED)
find_library(UIKIT_FW           UIKit           REQUIRED)
find_library(METAL_FW           Metal           REQUIRED)
find_library(QUARTZCORE_FW      QuartzCore      REQUIRED)
find_library(GAMECONTROLLER_FW  GameController  REQUIRED)
find_library(SECURITY_FW        Security        REQUIRED)

# ── Source groups ──

# Pcsx2Config (defines EmuConfig global variable)
set(PCSX2_CONFIG_SOURCES
    src/Pcsx2Config.cpp
    src/SourceLog.cpp
    src/GS/GSPerfMon.cpp
    # GS core sources added below
    src/GS/GSDrawingContext.cpp
    src/GS/GSDrawingEnvironment.cpp
    src/GS/GSRingHeap.cpp
    src/GS/GSBlock.cpp
    src/GS/GSXXH.cpp
    src/GS/GSUtil.cpp
    src/GS/GSTables.cpp
)
# MultiISA.cpp excluded (needs cpuinfo which is x86-centric)

# Audit Sec 2.1: EE Core — GREEN
set(EE_CORE_SOURCES
    src/R5900.cpp
    src/R5900OpcodeImpl.cpp
    src/R5900OpcodeTables.cpp
    src/MMI.cpp
    src/COP2.cpp
    src/Interpreter.cpp
    src/Memory.cpp
    src/COP0.cpp
    src/COP2.cpp
    src/Counters.cpp
    src/Dmac.cpp
    src/FPU.cpp
    src/Gif.cpp
    src/Gif_Unit.cpp
    src/Hw.cpp
    src/HwRead.cpp
    src/HwWrite.cpp
    src/SPR.cpp
    src/Vif.cpp
    src/Vif_Codes.cpp
    src/Vif_Transfer.cpp
    src/Vif_Unpack.cpp
    src/Vif0_Dma.cpp
    src/Vif1_Dma.cpp
    src/Vif1_MFIFO.cpp
    src/vtlb.cpp
    src/Vif_HashBucket.h
)

# Audit Sec 2.2: VU Units — GREEN (interpreter paths)
set(VU_SOURCES
    src/VU0.cpp
    src/VU0micro.cpp
    src/VU0microInterp.cpp
    src/VU1micro.cpp
    src/VU1microInterp.cpp
    src/VUmicro.cpp
    src/VUmicroMem.cpp
    src/VUflags.cpp
    src/VUops.cpp
)

# Audit Sec 2.3: IOP — GREEN
set(IOP_SOURCES
    src/R3000A.cpp
    src/R3000AInterpreter.cpp
    src/R3000AOpcodeTables.cpp
    src/IopBios.cpp
    src/IopCounters.cpp
    src/IopDma.cpp
    src/IopGte.cpp
    src/IopHw.cpp
    src/IopMem.cpp
    src/IopIrq.cpp
    src/ps2/Iop/IopHwRead.cpp
    src/ps2/Iop/IopHwWrite.cpp
    src/ps2/Iop/PsxBios.cpp
)

# Audit Sec 2.4: GS Core — GREEN
set(GS_CORE_SOURCES
    src/GS/GS.cpp
    src/MTGS.cpp
    src/GS/Renderers/Common/GSDevice.cpp
    src/GS/Renderers/Common/GSRenderer.cpp
    src/GS/Renderers/Common/GSTexture.cpp
    src/GS/Renderers/Common/GSVertexTrace.cpp
    src/GS/Renderers/HW/GSRendererHW.cpp
    src/GS/Renderers/HW/GSTextureCache.cpp
    src/GS/Renderers/HW/GSHwHack.cpp
    src/GS/Renderers/HW/GSTextureReplacements.cpp
    src/GS/GSState.cpp
    src/GS/GSLocalMemoryMultiISA.cpp
    src/GS/Renderers/Common/GSDirtyRect.cpp
    src/GS/GSRingHeap.cpp
    src/GS/GSBlock.cpp
    src/GS/GSClut.cpp
    src/GS/GSUtil.cpp
    src/GS/GSTables.cpp
    src/GS/GSXXH.cpp
    src/GS/GSDrawingContext.cpp
    src/GS/GSDrawingEnvironment.cpp
    src/GS/GSLocalMemory.cpp
    src/GS/GSVector.cpp
    src/GS/Renderers/Null/GSRendererNull.cpp
)

# Audit Sec 2.5: SPU2 — GREEN
set(SPU2_SOURCES
    src/SPU2/spu2.cpp
    src/SPU2/spu2sys.cpp
    src/SPU2/spu2freeze.cpp
    src/SIO/Sio.cpp
    src/SIO/Sio0.cpp
    src/SIO/Sio2.cpp
    src/SPU2/ADSR.cpp
    src/SPU2/Dma.cpp
    src/SPU2/Mixer.cpp
    src/SPU2/ReadInput.cpp
    src/SPU2/RegTable.cpp
    src/SPU2/Reverb.cpp
    src/SPU2/ReverbResample.cpp
)

# Shared memory management (Audit Sec 0-D, 6.2)
set(IOS_MEMORY_SOURCES
    ios/platform/HostSys_iOS.mm
    src/common/Linux/LnxHostSys.cpp
    ios/platform/PageFaultHandler.cpp
)

# Common library sources needed at link time
set(COMMON_LIB_SOURCES
    src/common/FileSystem.cpp
    src/common/Error.cpp
    src/common/Console.cpp
    src/common/HostSys.cpp
    src/common/Assertions.cpp
    src/common/StringUtil.cpp
    src/common/SmallString.cpp
    src/common/SettingsWrapper.cpp
    src/common/Timer.cpp
    src/common/ProgressCallback.cpp
    src/common/PrecompiledHeader.cpp
    src/common/MD5Digest.cpp
    src/common/DynamicLibrary.cpp
    src/common/Perf.cpp
    src/common/AlignedMalloc.cpp
    src/common/CrashHandler.cpp
    src/common/WindowInfo.cpp
    src/common/ReadbackSpinManager.cpp
    src/common/Semaphore.cpp
    src/common/MemorySettingsInterface.cpp
    src/common/MemoryInterface.cpp
)

# ccc library (needed by SymbolGuardian/SymbolImporter)
set(CCC_SOURCES
    src/3rdparty/ccc/src/ccc/ast.cpp
    src/3rdparty/ccc/src/ccc/elf.cpp
    src/3rdparty/ccc/src/ccc/elf_symtab.cpp
    src/3rdparty/ccc/src/ccc/importer_flags.cpp
    src/3rdparty/ccc/src/ccc/mdebug_analysis.cpp
    src/3rdparty/ccc/src/ccc/mdebug_importer.cpp
    src/3rdparty/ccc/src/ccc/mdebug_section.cpp
    src/3rdparty/ccc/src/ccc/mdebug_symbols.cpp
    src/3rdparty/ccc/src/ccc/sndll.cpp
    src/3rdparty/ccc/src/ccc/stabs.cpp
    src/3rdparty/ccc/src/ccc/stabs_to_ast.cpp
    src/3rdparty/ccc/src/ccc/symbol_database.cpp
    src/3rdparty/ccc/src/ccc/symbol_file.cpp
    src/3rdparty/ccc/src/ccc/symbol_table.cpp
    src/3rdparty/ccc/src/ccc/util.cpp
)

# fmt library sources
set(FMT_SOURCES
    src/3rdparty/fmt/src/format.cc
)

# Host abstraction sources (AudioStream.cpp excluded — factory methods stubbed)

# Threading (Audit Sec 5.3)
set(IOS_THREADING_SOURCES
    ios/platform/Threading_iOS.cpp
)

# iOS Platform (Audit Sec 4.3, 9.2, 6.4)
set(IOS_PLATFORM_SOURCES
    ios/platform/iOSVMManager.mm
    ios/platform/Host_iOS.mm
    ios/platform/CocoaTools.mm
    ios/platform/AudioStream_iOS.mm
    ios/platform/Filesystem_iOS.mm
    ios/platform/PCSX2Stubs.mm
    ios/platform/AudioStreamStubs.mm
    ios/platform/HWStubs.mm
    ios/platform/BreakPointStubs.cpp
    ios/platform/VMManagerStubs.cpp
)

# UIKit frontend (Audit Sec 11.2 H3)
set(IOS_UI_SOURCES
    ios/platform/main.mm
    ios/platform/MetalViewController.mm
)

# Metal Renderer stub (Audit Sec 4.1-4.3 — full port deferred)
set(METAL_SOURCES
    metal/MetalRendererStub.mm
)

# ── Main executable target ──
add_executable(BionicSX2
    ${PCSX2_CONFIG_SOURCES}
    ${EE_CORE_SOURCES}
    ${VU_SOURCES}
    ${IOP_SOURCES}
    ${GS_CORE_SOURCES}
    ${SPU2_SOURCES}
    ${IOS_MEMORY_SOURCES}
    ${COMMON_LIB_SOURCES}
    ${HOST_SOURCES}
    ${FMT_SOURCES}
    ${CCC_SOURCES}
    ${IOS_THREADING_SOURCES}
    ${IOS_PLATFORM_SOURCES}
    ${IOS_UI_SOURCES}
    ${METAL_SOURCES}
)

# ── Include directories ──
target_include_directories(BionicSX2 PRIVATE
    ${CMAKE_SOURCE_DIR}/src
    ${CMAKE_SOURCE_DIR}/ios/platform
    ${CMAKE_SOURCE_DIR}/metal
    ${CMAKE_SOURCE_DIR}/src/common
    ${CMAKE_SOURCE_DIR}/src/3rdparty
    ${CMAKE_SOURCE_DIR}/src/3rdparty/fmt/include
    ${CMAKE_SOURCE_DIR}/src/3rdparty/fast_float/include
    ${CMAKE_SOURCE_DIR}/src/3rdparty/ccc/src
    ${CMAKE_SOURCE_DIR}/src/3rdparty/imgui
    ${CMAKE_SOURCE_DIR}/src/3rdparty/imgui/include
    ${CMAKE_SOURCE_DIR}/src/3rdparty
    ${CMAKE_SOURCE_DIR}/src/3rdparty/include
    ${CMAKE_SOURCE_DIR}/src/3rdparty/freesurround/include
    ${CMAKE_SOURCE_DIR}/src/3rdparty/soundtouch/soundtouch
    ${CMAKE_SOURCE_DIR}/src/3rdparty/cpuinfo/include
    ${CMAKE_SOURCE_DIR}/src/3rdparty/vixl/include
    "${IOS_DEPS}/include"
)

# ── Linked frameworks (Audit Sec 10.3) ──
target_link_libraries(BionicSX2 PRIVATE
    ZLIB::ZLIB
    ${FOUNDATION_FW}
    ${AUDIOTOOLBOX_FW}
    ${AVFOUNDATION_FW}
    ${COREAUDIO_FW}
    ${COREFOUNDATION_FW}
    ${UIKIT_FW}
    ${METAL_FW}
    ${QUARTZCORE_FW}
    ${GAMECONTROLLER_FW}
    ${SECURITY_FW}
    "-framework MetalKit"
    "-framework CoreGraphics"
    "-lc++"
    "-liconv"
    "-lbsm"
)

# ── Compile options ──
target_compile_options(BionicSX2 PRIVATE -fobjc-arc -fobjc-weak)

# ── Metal shader compilation ──
if(CMAKE_XCODE_ATTRIBUTE_METAL_LIBRARY_OUTPUT_DIRECTORY)
    set_target_properties(BionicSX2 PROPERTIES
        METAL_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/metal")
endif()

# ── Output properties ──
set_target_properties(BionicSX2 PROPERTIES
    OUTPUT_NAME "BionicSX2"
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/ios/Info.plist"
    XCODE_ATTRIBUTE_PRODUCT_BUNDLE_IDENTIFIER "com.bionicsx2.app"
)

message(STATUS "BionicSX2 iOS Build Configuration:")
message(STATUS "  EE Core: ${EE_CORE_SOURCES}")
message(STATUS "  VU: ${VU_SOURCES}")
message(STATUS "  IOP: ${IOP_SOURCES}")
message(STATUS "  GS Core: ${GS_CORE_SOURCES}")
message(STATUS "  SPU2: ${SPU2_SOURCES}")
message(STATUS "  Platform: ${IOS_PLATFORM_SOURCES}")
message(STATUS "  Metal: ${METAL_SOURCES}")
message(STATUS "  nVif JIT: DISABLED (interpreter path)")
