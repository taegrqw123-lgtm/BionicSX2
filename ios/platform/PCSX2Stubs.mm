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

// ── Category 8: DEV9 / USB / ATA / SMAP / PGIF stubs ──
// PORTED: Hardware peripherals not used on iOS (Audit Sec 1.2 RED entries)

// SMAP
void smap_async() {}
u8 smap_read8(u32) { return 0; }
u16 smap_read16(u32) { return 0; }
u32 smap_read32(u32) { return 0; }
void smap_write8(u32, u8) {}
void smap_write16(u32, u16) {}
void smap_write32(u32, u32) {}
void smap_readDMA8Mem(u32, u32) {}
void smap_writeDMA8Mem(u32, u32) {}

// FLASH
void FLASHinit() {}
u32 FLASHread32(u32) { return 0; }
void FLASHwrite32(u32, u32) {}

// DEV9 networking
void InitNet() {}
void TermNet() {}
void ReconfigureLiveNet() {}

// OHCI / USB
void ohci_ReadMemory(u32) {}
void ohci_WriteMemory(u32, u32) {}
void ohci_Async(u32) {}
void usb_start(int, const char*) {}
void usb_stop(int) {}
int usb_open(int, const char*) { return 0; }
int usb_close(int) { return 0; }
int usb_ioctl(int, int, void*) { return 0; }
void usb_desc_() {}

// PSX GPU (PS1 backward compat)
u32 psxDma2GpuR(u32, u32) { return 0; }
u32 psxDma2GpuW(u32, u32) { return 0; }
u32 psxGPUr(u32) { return 0; }
void psxGPUw(u32, u32) {}

// PGIF
void PGIFrQword(u32, u32) {}
void PGIFwQword(u32, u32) {}
u32 PGIFr(u32) { return 0; }
void PGIFw(u32, u32) {}
void pgifInit() {}

// FIFO
void ReadFifoSingleWord() {}
void ReadFIFO_VIF1() {}
void WriteFIFO_VIF0(u32) {}
void WriteFIFO_VIF1(u32) {}
void WriteFIFO_GIF(u32) {}

// SIF
void sifReset() {}
void SIF1Dma() {}
void dmaSIF1() {}
void dmaSIF2() {}
void EEsif1Interrupt() {}
void sif1Interrupt() {}
void sif2Interrupt() {}

// VIF
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

namespace AudioStream {
    std::unique_ptr<void> CreateCubebAudioStream() { return nullptr; }
    std::unique_ptr<void> CreateSDLAudioStream() { return nullptr; }
    std::vector<std::string> GetCubebDriverNames() { return {}; }
    std::vector<std::string> GetCubebOutputDevices() { return {}; }
}

namespace InputManager {
    u32 ConvertHostKeyboardStringToCode(const std::string&) { return 0; }
    std::string ConvertHostKeyboardCodeToString(u32) { return {}; }
    std::string ConvertHostKeyboardCodeToIcon(u32) { return {}; }
}

namespace DebugInterface {
    u32 parseExpression(const std::string&, u32, bool*) { return 0; }
}

void standardizeBreakpointAddress(u32&) {}

// HostSys
#include "common/HostSys.h"
bool Common::PlaySoundAsync(const char*) { return false; }
