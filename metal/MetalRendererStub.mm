// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3
// STATUS: STUB — Minimal Metal renderer for initial iOS build

#import <Metal/Metal.h>
#import <UIKit/UIKit.h>
#include "PrecompiledHeader.h"
#include "GS/GS.h"
#include "GS/Renderers/Common/GSDevice.h"
#include "common/Console.h"
#include "common/Error.h"

class MetalRendererStub : public GSDevice
{
public:
    MetalRendererStub() : GSDevice(GSRendererType::Metal) {}
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

    PresentResult BeginPresent(bool frame_skip) override { return PresentResult::FrameSkip; }
    void EndPresent() override {}

    void ClearSamplerCache() override {}

    std::unique_ptr<GSDownloadTexture> CreateDownloadTexture(u32 width, u32 height, GSTexture::Format format) override
    {
        return nullptr;
    }

    GSTexture* CreateSurface(GSTexture::Type type, int width, int height, int levels, GSTexture::Format format) override
    {
        return nullptr;
    }

    void CopyRect(GSTexture* sTex, GSTexture* dTex, const GSVector4i& r, u32 destX, u32 destY) override {}

    void DoMerge(GSTexture* sTex[3], GSVector4* sRect, GSTexture* dTex, GSVector4* dRect,
        const GSRegPMODE& PMODE, const GSRegEXTBUF& EXTBUF, u32 c, const bool linear) override {}

    void DoInterlace(GSTexture* sTex, const GSVector4& sRect, GSTexture* dTex, const GSVector4& dRect,
        ShaderInterlace shader, bool linear, const InterlaceConstantBuffer& cb) override {}

    void DoFXAA(GSTexture* sTex, GSTexture* dTex) override {}
    void DoShadeBoost(GSTexture* sTex, GSTexture* dTex, const float params[4]) override {}

    bool DoCAS(GSTexture* sTex, GSTexture* dTex, bool sharpen_only,
        const std::array<u32, NUM_CAS_CONSTANTS>& constants) override
    {
        return false;
    }

    void RenderHW(GSHWDrawConfig& config) override {}

    void PresentRect(GSTexture* sTex, const GSVector4& sRect, GSTexture* dTex,
        const GSVector4& dRect, PresentShader shader, float shaderTime, bool linear) override {}

    void DrawMultiStretchRects(const MultiStretchRect* rects, u32 num_rects,
        GSTexture* dTex, ShaderConvert shader) override {}

    void UpdateCLUTTexture(GSTexture* sTex, float sScale, u32 offsetX, u32 offsetY,
        GSTexture* dTex, u32 dOffset, u32 dSize) override {}

    void ConvertToIndexedTexture(GSTexture* sTex, float sScale, u32 offsetX, u32 offsetY,
        u32 SBW, u32 SPSM, GSTexture* dTex, u32 DBW, u32 DPSM) override {}

    void FilteredDownsampleTexture(GSTexture* sTex, GSTexture* dTex, u32 downsample_factor,
        const GSVector2i& clamp_min, const GSVector4& dRect) override {}

    void BeginDSAsRT(GSTexture* ds, const GSVector4i& drawarea) override {}

    void FlushClears(GSTexture* tex) override {}

protected:
    void DoStretchRect(GSTexture* sTex, const GSVector4& sRect, GSTexture* dTex,
        const GSVector4& dRect, GSHWDrawConfig::ColorMaskSelector cms,
        ShaderConvert shader, bool linear) override {}
};

// Factory function called from GSDevice.cpp
GSDevice* MakeGSDeviceMTL()
{
    return new MetalRendererStub();
}
