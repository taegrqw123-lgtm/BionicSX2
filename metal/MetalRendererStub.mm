// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3
// STATUS: STUB — Minimal Metal renderer for initial iOS build

#import <Metal/Metal.h>
#include "PrecompiledHeader.h"
#include "GS/GS.h"
#include "GS/Renderers/Common/GSDevice.h"
#include "common/Console.h"
#include "common/Error.h"

class MetalRendererStub : public GSDevice
{
public:
    MetalRendererStub() : GSDevice() {}
    ~MetalRendererStub() override {}

    bool Create(GSVSyncMode vsync_mode, bool allow_present_throttle) override
    {
        id<MTLDevice> dev = MTLCreateSystemDefaultDevice();
        if (!dev) {
            Console.Error("Failed to create Metal device");
            return false;
        }
        Console.WriteLn("Metal device: %s", [dev.name UTF8String]);
        return true;
    }

    void Destroy() override {}
    bool HasSurface() const override { return false; }
    void DestroySurface() override {}
    bool UpdateWindow() override { return true; }
    bool SupportsExclusiveFullscreen() const override { return false; }
    std::string GetDriverInfo() const override { return "Metal (stub)"; }
    RenderAPI GetRenderAPI() const override { return RenderAPI::Metal; }
    void SetVSyncMode(GSVSyncMode mode, bool allow_present_throttle) override {}
    bool SetGPUTimingEnabled(bool enabled) override { return false; }
    float GetAndResetAccumulatedGPUTime() override { return 0.0f; }
    void ResizeWindow(u32 width, u32 height, float scale) override {}

    PresentResult BeginPresent(bool frame_skip) override { return PresentResult::FrameSkipped; }
    void EndPresent() override {}
    void ClearSamplerCache() override {}

    void PushDebugGroup(const char* fmt, ...) override {}
    void PopDebugGroup() override {}
    void InsertDebugMessage(DebugMessageCategory category, const char* fmt, ...) override {}

    std::unique_ptr<GSDownloadTexture> CreateDownloadTexture(u32, u32, GSTexture::Format) override { return nullptr; }
    GSTexture* CreateSurface(GSTexture::Type, int, int, int, GSTexture::Format) override { return nullptr; }
    void CopyRect(GSTexture*, GSTexture*, const GSVector4i&, u32, u32) override {}

    void DoMerge(GSTexture* sTex[3], GSVector4* sRect, GSTexture* dTex, GSVector4* dRect,
        const GSRegPMODE& PMODE, const GSRegEXTBUF& EXTBUF, u32 c, const bool linear) override {}
    void DoInterlace(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&,
        ShaderInterlace, bool, const InterlaceConstantBuffer&) override {}
    void DoFXAA(GSTexture*, GSTexture*) override {}
    void DoShadeBoost(GSTexture*, GSTexture*, const float[4]) override {}
    bool DoCAS(GSTexture*, GSTexture*, bool, const std::array<u32, NUM_CAS_CONSTANTS>&) override { return false; }
    void RenderHW(GSHWDrawConfig&) override {}
    void PresentRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&,
        PresentShader, float, bool) override {}
    void DrawMultiStretchRects(const MultiStretchRect*, u32, GSTexture*, ShaderConvert) override {}
    void UpdateCLUTTexture(GSTexture*, float, u32, u32, GSTexture*, u32, u32) override {}
    void ConvertToIndexedTexture(GSTexture*, float, u32, u32, u32, u32, GSTexture*, u32, u32) override {}
    void FilteredDownsampleTexture(GSTexture*, GSTexture*, u32, const GSVector2i&, const GSVector4&) override {}
    void BeginDSAsRT(GSTexture*, const GSVector4i&) override {}

protected:
    void DoStretchRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&,
        GSHWDrawConfig::ColorMaskSelector, ShaderConvert, bool) override {}
};

GSDevice* MakeGSDeviceMTL()
{
    return new MetalRendererStub();
}
