// BionicSX2 iOS — HW I/O stubs
#include "PrecompiledHeader.h"
#include <string>
#include <vector>

// Forward declarations for types that would require heavy header inclusion
enum class CDVD_SourceType : unsigned char;
enum class GS_VideoMode : int;
class GSTexture;
#include "GS/GSVector.h"
#include "common/SingleRegisterTypes.h"
// BreakPointCpu forward declaration
enum class BreakPointCpu : unsigned char;
struct MemCheck { unsigned long long start; unsigned long long end; unsigned int cond; unsigned int result; }; // simplified

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

// CBreakPoints (static member definitions in BreakPointStubs.cpp)
namespace CBreakPoints {
void AddBreakPoint(BreakPointCpu, unsigned int, bool, bool, bool) {}
void CheckSkipFirst(BreakPointCpu, unsigned int) {}
void ClearSkipFirst(BreakPointCpu) {}
BreakPointCpu GetBreakPointCondition(BreakPointCpu, unsigned int) { return BreakPointCpu(0); }
std::vector<MemCheck> GetMemChecks(BreakPointCpu) { return {}; }
bool IsAddressBreakPoint(BreakPointCpu, unsigned int) { return false; }
}

// DebugInterface
namespace DebugInterface {
    int m_pause_on_entry = 0;
    bool parseExpression(std::vector<std::pair<u64, u64>>&, u64&, std::string&) { return false; }
}

// GSCapture
namespace GSCapture {
bool BeginCapture(float, GSVector2i, float, std::string) { return false; }
void DeliverAudioPacket(const float*) {}
void DeliverVideoFrame(GSTexture*) {}
void EndCapture() {}
void Flush() {}
std::string GetNextCaptureFileName() { return {}; }
int GetSize() { return 0; }
bool IsCapturing() { return false; }
bool IsCapturingVideo() { return false; }
}

// GSDumpBase stubs
#include "GS/GSDump.h"
std::unique_ptr<GSDumpBase> GSDumpBase::CreateUncompressedDump(const std::string&, const std::string&, u32, u32, u32, const u32*, const freezeData&, const GSPrivRegSet*) { return nullptr; }
std::unique_ptr<GSDumpBase> GSDumpBase::CreateXzDump(const std::string&, const std::string&, u32, u32, u32, const u32*, const freezeData&, const GSPrivRegSet*) { return nullptr; }
std::unique_ptr<GSDumpBase> GSDumpBase::CreateZstDump(const std::string&, const std::string&, u32, u32, u32, const u32*, const freezeData&, const GSPrivRegSet*) { return nullptr; }
bool GSDumpBase::VSync(int, bool, const GSPrivRegSet*) { return false; }
void GSDumpBase::ReadFIFO(u32) {}
void GSDumpBase::Transfer(int, const u8*, size_t) {}

// GSDumpReplayer
namespace GSDumpReplayer {
bool IsReplayingDump() { return false; }
bool IsRunner() { return false; }
void RenderUI() {}
}

// FullscreenUI
namespace FullscreenUI {
void Render() {}
}

// GSPng
#include "GS/GSPng.h"
bool GSPng::Save(GSPng::Format, const std::string&, const u8*, int, int, int, int, bool) { return false; }

// Texture decompression
void DecompressBlockBC1(unsigned int, unsigned int, unsigned int, const unsigned char*, unsigned char*) {}
void DecompressBlockBC2(unsigned int, unsigned int, unsigned int, const unsigned char*, unsigned char*) {}
void DecompressBlockBC3(unsigned int, unsigned int, unsigned int, const unsigned char*, unsigned char*) {}

// GSTextureReplacements
namespace GSTextureReplacements {
void* GetLoader(std::string_view) { return nullptr; }
bool SavePNGImage(const std::string&, unsigned int, unsigned int, const unsigned char*, unsigned int) { return false; }
}



// Host (functions declared in GS.h)
std::optional<WindowInfo> Host::AcquireRenderWindow(bool) { return std::nullopt; }
void Host::BeginPresentFrame() {}
void Host::ReleaseRenderWindow() {}

// ImGui
namespace ImGui {
void* GetCurrentContext() { return nullptr; }
bool Begin(const char*, bool*, int) { return false; }
void End() {}
void* GetPlatformIO() { return nullptr; }
}

// ImGuiManager
namespace ImGuiManager {
bool Initialize() { return false; }
void NewFrame() {}
void ReloadFonts() {}
void RenderOSD() {}
void RequestScaleUpdate() {}
void Shutdown(bool) {}
void SkipFrame() {}
void WindowResized() {}
}

// MemcardBusy
namespace MemcardBusy {
void Decrement() {}
}

// VMManager, VU_Thread, Sio stubs in VMManagerStubs.cpp

// CDVD stubs
void cdvdGetDiscInfo(std::string*, std::string*, std::string*, u32*, int) {}
bool cdvdSectorReady() { return false; }
void cdrReadInterrupt() {}
void cdvdReadInterrupt() {}
void cdvdRead(u8) {}
void cdvdReset() {}
bool cdvdVsync() { return false; }
void cdvdWrite(u8, u8) {}
void cdrRead0() {}
void cdrRead1() {}
void cdrRead2() {}
void cdrRead3() {}
void cdrReset() {}
void cdrWrite0(u8) {}
void cdrWrite1(u8) {}
void cdrWrite2(u8) {}
void cdrWrite3(u8) {}

// GS stubs
void gsIrq() {}
void gsPostVsyncStart() {}
u8  gsRead8(u32) { return 0; }
u16 gsRead16(u32) { return 0; }
u32 gsRead32(u32) { return 0; }
u64 gsRead64(u32) { return 0; }
void gsReset() {}
void gsWrite8(u32, u8) {}
void gsWrite16(u32, u16) {}
void gsWrite32(u32, u32) {}
void gsWrite64_generic(u32, u64) {}
void gsWrite64_page_00(u32, u64) {}
void gsWrite64_page_01(u32, u64) {}
void gsWrite128_generic(u32, r128) {}
void gsWrite128_page_00(u32, r128) {}
void gsWrite128_page_01(u32, r128) {}

// DMA/IPU stubs
void dmaIPU0() {}
void dmaIPU1() {}
void dmaSIF0() {}
void dmaSIF1() {}
void dmaSIF2() {}
void SIF0Dma() {}
void SIF1Dma() {}
void sifReset() {}
void psxDma0(u32, u32, u32) {}
void psxDma1(u32, u32, u32) {}
void psxDma2(u32, u32, u32) {}
void psxDma3(u32, u32, u32) {}

// IOP stubs
void USBreset() {}
void mdecInit() {}
void mdecRead0() {}
void mdecRead1() {}
void ipuReset() {}
void psxGPUr(int) { return; }
void psxGPUw(int, u32) {}

// fastjmp stubs
#include "common/FastJmp.h"
void fastjmp_jmp(fastjmp_buf) {}
void fastjmp_set(fastjmp_buf) {}

// RGBA8Image stubs
struct RGBA8Image {
    RGBA8Image() = default;
    RGBA8Image(RGBA8Image&&) = default;
    bool SaveToFile(const char*, u8) const { return false; }
};

// bc7decomp
namespace bc7decomp {
void unpack_bc7(const void*, void*) {}
}

// Other stubs
void hwRead16_page_0F_INTC_HACK(u32) {}
void hwRead32_page_0F_INTC_HACK(u32) {}
void __clear_cache(void*, void*) {}
void writebackCache() {}
std::string ShiftJIS_ConvertString(const char*) { return {}; }
std::string ShiftJIS_ConvertString(const char*, int) { return {}; }
bool SaveStateBase::FreezeTag(const char*) { return false; }
void vtlb_DynBackpatchLoadStore(uptr, u32, u32, u32, u8, u8, u8, bool, bool, bool) {}

// MultiISAFunctions
namespace MultiISAFunctions {
u64 GSXXH3_64_Long(const void*, size_t) { return 0; }
u64 GSXXH3_64_Digest(void*) { return 0; }
int GSXXH3_64_Update(void*, const void*, size_t) { return 0; }
}

// Pad
#include "SIO/Pad/Pad.h"
std::string Pad::GetConfigSection(unsigned int) { return {}; }
const Pad::ControllerInfo* Pad::GetControllerInfo(Pad::ControllerType) { return nullptr; }
const Pad::ControllerInfo* Pad::GetControllerInfoByName(std::string_view) { return nullptr; }
Pad::ControllerType Pad::GetDefaultPadType(unsigned int) { return Pad::ControllerType(0); }

// PerformanceMetrics
namespace PerformanceMetrics {
int GetInternalFPSMethod() { return 0; }
void OnGPUPresent(float) {}
void Update(bool, bool, bool) {}
}
