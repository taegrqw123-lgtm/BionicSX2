// PORTED FROM: PCSX2 macOS — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 0-A, 0-B, 0-F
// STATUS: NEW — Linker stubs for iOS platform

#import <Foundation/Foundation.h>
#include "PrecompiledHeader.h"
#include "common/Assertions.h"
#include "common/WindowInfo.h"
#include "common/Error.h"
#include "common/ProgressCallback.h"
#include "common/SettingsInterface.h"
#include "SPU2/defs.h"
#include <mutex>
#include <string>
#include <string_view>
#include <vector>
#include <functional>
#include <optional>

// ── Category 1: x86/JIT stubs ──
// PORTED: x86-specific JIT init stubbed for ARM64 iOS (Audit Sec 2.3-F)
void VifUnpackSSE_Init() {}
void vtlb_DynBackpatchLoadStore(uptr, u32, u32, u32, u8, u8, u8, bool, bool, bool) {}

// ── Category 5: ImGui stubs ──
// PORTED: ImGui overlay not needed for iOS BIOS-level rendering (Audit Sec 13.4)
namespace ImGuiManager {
    void SetImGuiKeyMapping(const std::string&) {}
    bool IsFullscreen() { return false; }
    float GetScale() { return 1.0f; }
    void RenderOverlay() {}
    void RenderDebug() {}
}

// ── Category 6: FullscreenUI stubs ──
// PORTED: FullscreenUI not needed for iOS initial bringup (Audit Sec 2.3-F)
namespace FullscreenUI {
    bool IsFullscreen() { return false; }
    bool IsSavingOrLoading() { return false; }
    void OpenFileOrURL(const std::string&) {}
    void OpenOrFocus() {}
    void OpenGameList() {}
    void OpenSettings() {}
    void OpenAchievements() {}
    void OpenCheats() {}
    void OpenPauseMenu() {}
    void OpenLoadSaveState() {}
    void OpenControllerSettings() {}
    void OpenMemoryCardSettings() {}
    void OpenGraphicsSettings() {}
    void OpenAudioSettings() {}
    void OpenSystemSettings() {}
    void CheckForSettingsChanges() {}
    void LoadingSavedState() {}
    void CancelLoadingSavedState() {}
    void OnVMStarted() {}
    void OnVMDestroyed() {}
    void OnGameChanged(const std::string&, const std::string&, const std::string&) {}
    void RequestResizeHostDisplay(s32, s32) {}
    void LoadingGame(const std::string&) {}
    bool Initialize() { return true; }
    void Shutdown() {}
}

// ── Additional HW I/O stubs ──
bool ParamsRead = false;
u32 R3000SymbolGuardian = 0;
void readCache8(u32, bool) {}
void writeCache8(u32, u8) {}
void writeCache16(u32, u16) {}
void writeCache32(u32, u32) {}
void writeCache64(u32, u64) {}
void writeCache128(u32, u64) {}
u8  readCache8(u32 addr) { return 0; }
u8  ipuRead8(u32) { return 0; }
u16 ipuRead16(u32) { return 0; }
u32 ipuRead32(u32) { return 0; }
u64 ipuRead64(u32) { return 0; }
void ipuWrite8(u32, u8) {}
void ipuWrite16(u32, u16) {}
void ipuWrite32(u32, u32) {}
void ipuWrite64(u32, u64) {}
u32 mdecRead0(u32) { return 0; }
u32 mdecRead1(u32) { return 0; }
void mdecWrite0(u32) {}
void mdecWrite1(u32) {}
u32 gifBookRw(u32) { return 0; }

// ── PSX GPU / VIF stubs ──
u32 psxDma2GpuR(u32, u32) { return 0; }
u32 psxDma2GpuW(u32, u32) { return 0; }
u32 psxGPUr(u32) { return 0; }
void psxGPUw(u32, u32) {}
void dVifRelease(int) {}
void dVifReset(int) {}

// ── Category 9: Misc required stubs ──
// PORTED: Various macOS-specific functions stubbed for iOS (Audit Sec 13.7)

#include "common/CocoaTools.h"
std::optional<std::string> CocoaTools::GetNonTranslocatedBundlePath() {
    return [[[NSBundle mainBundle] bundlePath] UTF8String];
}

namespace DarwinMisc {
    struct CPUClass { std::string name; u32 physical; u32 logical; };
    std::vector<CPUClass> GetCPUClasses() {
        return {{"Default", 4, 4}};
    }
}

namespace GameDatabase {
    std::string findGame(const std::string& serial) { return {}; }
}

bool SaveState_SaveScreenshot(const std::string&, const std::string&) { return false; }
bool DownloadState(const std::string&, u32) { return false; }
bool UnzipFromDisk(const std::string&, const std::string&) { return false; }
bool SaveState_ZipToDisk(const std::string&, const std::string&) { return false; }
void ReportLoadErrorOSD(const std::string&) {}
void ReportSaveErrorOSD(const std::string&) {}

namespace InputRecording {
    void DoRecording() {}
    void DoPlayback() {}
    void Stop() {}
    bool IsActive() { return false; }
    bool IsRecording() { return false; }
    bool IsPlaying() { return false; }
    void StartRecording(const std::string&) {}
    void StartPlayback(const std::string&) {}
    std::string GetFilename() { return {}; }
}

namespace CBreakPoints {
    void ClearAll() {}
    void AddBreakPoint(u32, bool) {}
    void RemoveBreakPoint(u32) {}
    bool IsBreakPoint(u32) { return false; }
    void AddMemoryCheck(u32, u32, u32, int) {}
    void RemoveMemoryCheck(u32) {}
    void SetPauseOnExecution(bool) {}
    bool GetPauseOnExecution() { return false; }
    static std::mutex s_mutex;
}

namespace SymbolGuardian {
    void Initialize() {}
    void Shutdown() {}
}

namespace SymbolImporter {
    void Initialize() {}
    void Shutdown() {}
}

namespace GSDumpReplayer {
    bool IsReplaying() { return false; }
    void StartReplay(const std::string&) {}
}

struct BiosInformation { std::string version; std::string zone; };
BiosInformation CurrentBiosInformation = {};

void ReadOSDConfigParames() {}
std::string ShiftJIS_ConvertString(const std::string& str) { return str; }
std::vector<std::string> GetMetalAdapterList() { return {}; }

// ── Audio / CDVD / IPU / SIF / etc. Stubs ──

// CDVD
void CDVDsys_ChangeSource(CDVD_SourceType) {}
void CDVDsys_SetFile(CDVD_SourceType, const std::string&) {}
void CopyBIOSToMemory() {}

// SIF
void EEsif0Interrupt() {}
void sif0Interrupt() {}
void sif1Interrupt() {}
void sif2Interrupt() {}

// IPU
void ipu0Interrupt() {}
void ipu1Interrupt() {}
void ipuCMDProcess() {}

// GS
void gsSetVideoMode(int) {}

// CDVD IRQ
void cdrInterrupt() {}
void cdvdActionInterrupt() {}

// DEV9
void DEV9irqHandler() {}
void DEV9async(u32) {}
u8 DEV9read8(u32) { return 0; }
u16 DEV9read16(u32) { return 0; }
u32 DEV9read32(u32) { return 0; }
void DEV9readDMA8Mem(u32*, int) {}
void DEV9write8(u32, u8) {}
void DEV9write16(u32, u16) {}
void DEV9write32(u32, u32) {}
void DEV9writeDMA8Mem(u32*, int) {}

// USB
void USBirqHandler() {}
void USBasync(u32) {}
u8 USBread8(u32) { return 0; }
u16 USBread16(u32) { return 0; }
u32 USBread32(u32) { return 0; }
void USBwrite8(u32, u8) {}
void USBwrite16(u32, u16) {}
void USBwrite32(u32, u32) {}

// PGIF
void PGIFrQword(u32, void*) {}
void PGIFwQword(u32, void*) {}
u32 PGIFr(u32) { return 0; }
void PGIFw(u32, u32) {}

// FW
u32 FWread32(u32) { return 0; }
void FWwrite32(u32, u32) {}
void FWIrqHandler() {}

// Cache (readCache* are defined in Cache.cpp, only writeCache stubs needed here)
void writeCache8(u32, u8, bool) {}
void writeCache16(u32, u16, bool) {}
void writeCache32(u32, u32, bool) {}
void writeCache64(u32, u64, bool) {}
void writeCache128(u32, u128, bool) {}

// FIFO
void ReadFIFO_VIF1(u128*) {}
void WriteFIFO_VIF0(const u128*) {}
void WriteFIFO_VIF1(const u128*) {}
void WriteFIFO_GIF(const u128*) {}

// PCSX2 globals that aren't defined in compiled source files
bool eecount_on_last_vdec = false;

// PCSX2 globals
s32 configParams1 = 0;
s32 configParams2 = 0;
u8* g_RealGSMem = nullptr;

namespace InputManager {
    u32 ConvertHostKeyboardStringToCode(const std::string&) { return 0; }
    std::string ConvertHostKeyboardCodeToString(u32) { return {}; }
    std::string ConvertHostKeyboardCodeToIcon(u32) { return {}; }
}

namespace DebugInterface {
    u32 parseExpression(const std::string&, u32, bool*) { return 0; }
}

void standardizeBreakpointAddress(u32&) {}

// EnableFMV flag — needed by Counters.cpp and IPU code
bool EnableFMV = false;

// PCSX2 global variables (defined in various .cpp files not compiled for iOS)
bool AllowParams1 = false;
bool AllowParams2 = false;
bool NoOSD = false;
bool FMVstarted = false;
u32 PSXCLK = 36864000;

// HostSys
#include "common/HostSys.h"
bool Common::PlaySoundAsync(const char*) { return false; }
