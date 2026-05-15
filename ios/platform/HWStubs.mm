// BionicSX2 iOS — HW I/O stubs with exact type matching from PCSX2 headers
#include "PrecompiledHeader.h"
#include "CDVD/CDVD.h"
#include "DebugTools/Breakpoints.h"
#include "DebugTools/DebugInterface.h"
#include "SIO/Memcard/MemoryCardFile.h"
#include "GS/GS.h"
#include "GSDumpReplayer.h"
#include "common/HeterogeneousContainers.h"

// CDVD
void CDVDsys_ChangeSource(CDVD_SourceType) {}
void CDVDsys_SetFile(CDVD_SourceType, std::string) {}
void CopyBIOSToMemory() {}

// SIF
void EEsif0Interrupt() {}
void EEsif1Interrupt() {}
void sif0Interrupt() {}
void sif1Interrupt() {}
void sif2Interrupt() {}

// IPU
void ipu0Interrupt() {}
void ipu1Interrupt() {}
void ipuCMDProcess() {}

// GS
void gsSetVideoMode(GS_VideoMode) {}

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
void pgifInit() {}

// FW
u32 FWread32(u32) { return 0; }
void FWwrite32(u32, u32) {}
void FWIrqHandler() {}

// Cache
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

// Memcard
std::string FileMcd_GetDefaultName(u32) { return {}; }
u32 FileMcd_GetMtapPort(u32) { return 0; }
u32 FileMcd_GetMtapSlot(u32) { return 0; }
bool FileMcd_IsMultitapSlot(u32) { return false; }

// AutoEject
namespace AutoEject { bool CountDownTicks() { return false; } }

// CBreakPoints
int breakpointTriggeredCpu_ = 0;
int breakpointTriggered_ = 0;
int memChecks_ = 0;

// DebugInterface
int DebugInterface::m_pause_on_entry = 0;
bool DebugInterface::parseExpression(std::vector<std::pair<u64, u64>>&, u64&, std::string&) { return false; }

// GSCapture
namespace GSCapture {
bool BeginCapture(float, GSVector2i, float, const std::string&) { return false; }
void DeliverAudioPacket(const float*) {}
void DeliverVideoFrame(GSTexture*) {}
void EndCapture() {}
void Flush() {}
std::string GetNextCaptureFileName() { return {}; }
int GetSize() { return 0; }
bool IsCapturing() { return false; }
bool IsCapturingVideo() { return false; }
}

// GSDumpBase
namespace GSDumpBase {
void* CreateUncompressedDump(const std::string&, const std::string&, u32, u32, u32, const u32*, const freezeData&, const GSPrivRegSet*) { return nullptr; }
void* CreateXzDump(const std::string&, const std::string&, u32, u32, u32, const u32*, const freezeData&, const GSPrivRegSet*) { return nullptr; }
void* CreateZstDump(const std::string&, const std::string&, u32, u32, u32, const u32*, const freezeData&, const GSPrivRegSet*) { return nullptr; }
void VSync(int, bool, const GSPrivRegSet*) {}
}

// GSDumpReplayer
bool GSDumpReplayer::IsReplayingDump() { return false; }
bool GSDumpReplayer::IsRunner() { return false; }
void GSDumpReplayer::RenderUI() {}
