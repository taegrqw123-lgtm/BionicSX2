// BionicSX2 iOS — Comprehensive HW I/O stubs for link resolution
// Provides stub implementations for all device I/O functions referenced by HwRead/HwWrite

#include "PrecompiledHeader.h"

// ── CDVD stubs ──
void CDVDsys_ChangeSource(int) {}
void CDVDsys_SetFile(int, const std::string&) {}
void CopyBIOSToMemory() {}

// ── SIF stubs ──
void EEsif0Interrupt() {}
void EEsif1Interrupt() {}
void sif0Interrupt() {}
void sif1Interrupt() {}
void sif2Interrupt() {}

// ── IPU stubs ──
void ipu0Interrupt() {}
void ipu1Interrupt() {}
void ipuCMDProcess() {}

// ── GS stubs ──
void gsSetVideoMode(int) {}

// ── CDVD IRQ stubs ──
void cdrInterrupt() {}
void cdvdActionInterrupt() {}

// ── DEV9 stubs ──
void DEV9irqHandler() {}
void DEV9async(unsigned int) {}
unsigned char DEV9read8(unsigned int) { return 0; }
unsigned short DEV9read16(unsigned int) { return 0; }
unsigned int DEV9read32(unsigned int) { return 0; }
void DEV9readDMA8Mem(unsigned int*, int) {}
void DEV9write8(unsigned int, unsigned char) {}
void DEV9write16(unsigned int, unsigned short) {}
void DEV9write32(unsigned int, unsigned int) {}
void DEV9writeDMA8Mem(unsigned int*, int) {}

// ── USB stubs ──
void USBirqHandler() {}
void USBasync(unsigned int) {}
unsigned char USBread8(unsigned int) { return 0; }
unsigned short USBread16(unsigned int) { return 0; }
unsigned int USBread32(unsigned int) { return 0; }
void USBwrite8(unsigned int, unsigned char) {}
void USBwrite16(unsigned int, unsigned short) {}
void USBwrite32(unsigned int, unsigned int) {}

// ── PGIF stubs ──
void PGIFrQword(unsigned int, void*) {}
void PGIFwQword(unsigned int, void*) {}
unsigned int PGIFr(unsigned int) { return 0; }
void PGIFw(unsigned int, unsigned int) {}
void pgifInit() {}

// ── FW stubs ──
unsigned int FWread32(unsigned int) { return 0; }
void FWwrite32(unsigned int, unsigned int) {}
void FWIrqHandler() {}

// ── Cache stubs ──
void writeCache8(unsigned int, unsigned char, bool) {}
void writeCache16(unsigned int, unsigned short, bool) {}
void writeCache32(unsigned int, unsigned int, bool) {}
void writeCache64(unsigned int, unsigned long long, bool) {}
void writeCache128(unsigned int, unsigned long long, unsigned long long) {}

// ── FIFO stubs ──
void ReadFIFO_VIF1(unsigned long long*) {}
void WriteFIFO_VIF0(const unsigned long long*) {}
void WriteFIFO_VIF1(const unsigned long long*) {}
void WriteFIFO_GIF(const unsigned long long*) {}

// ── Memcard stubs ──
std::string FileMcd_GetDefaultName(unsigned int) { return {}; }
unsigned int FileMcd_GetMtapPort(unsigned int) { return 0; }
unsigned int FileMcd_GetMtapSlot(unsigned int) { return 0; }
bool FileMcd_IsMultitapSlot(unsigned int) { return false; }

// ── GSCapture stubs ──
namespace GSCapture {
bool BeginCapture(float, int, float, const std::string&) { return false; }
void DeliverAudioPacket(const float*) {}
void DeliverVideoFrame(class GSTexture*) {}
void EndCapture() {}
void Flush() {}
std::string GetNextCaptureFileName() { return {}; }
int GetSize() { return 0; }
bool IsCapturing() { return false; }
bool IsCapturingVideo() { return false; }
}

// ── GSDump stubs ──
namespace GSDumpBase {
void* CreateUncompressedDump(const std::string&, const std::string&,
    unsigned int, unsigned int, unsigned int, const unsigned int*,
    const void*, const void*) { return nullptr; }
}

// ── AutoEject stubs ──
namespace AutoEject { bool CountDownTicks() { return false; } }

// ── CBreakPoints stubs ──
unsigned int breakpointTriggeredCpu_ = 0;
unsigned int breakpointTriggered_ = 0;
unsigned int memChecks_ = 0;
namespace CBreakPoints {
void AddBreakPoint(int, unsigned int, bool, bool, bool) {}
void CheckSkipFirst(int, unsigned int) {}
void ClearSkipFirst(int) {}
int GetBreakPointCondition(int, unsigned int) { return 0; }
std::vector<unsigned long long> GetMemChecks(int) { return {}; }
bool IsAddressBreakPoint(int, unsigned int) { return false; }
}

// ── DebugInterface stubs ──
namespace DebugInterface {
unsigned int m_pause_on_entry = 0;
bool parseExpression(std::vector<std::pair<unsigned long long, unsigned long long>>&,
    unsigned long long&, std::string&) { return false; }
}

// ── FullscreenUI stubs ──
namespace FullscreenUI {
void Render() {}
std::vector<std::string> GetAvailableLanguageList() { return {}; }
bool Initialize() { return true; }
void Shutdown() {}
bool IsFullscreen() { return false; }
void OpenGameList() {}
void OpenSettings() {}
}
