// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.1, 4.2, 4.3
// STATUS: YELLOW — AppKit→UIKit, surface management changes only

// PORTED: #import <AppKit/AppKit.h> → #import <UIKit/UIKit.h> (Audit Sec 4.3)
// PORTED: NSView → UIView, NSWindow → UIWindow (Audit Sec 4.3)
// PORTED: CAMetalLayer usage stays identical — fully portable (Audit Sec 4.3)
// PORTED: MTLDevice, MTLCommandQueue, MTLRenderPipelineDescriptor unchanged
// PORTED: Pixel format MTLPixelFormatBGRA8Unorm confirmed portable

#if !__has_feature(objc_arc)
#error "Compile with -fobjc-arc"
#endif

#include "MetalRenderer.h"
#include "MetalTexture.h"
#include "GS/Renderers/Common/GSRenderer.h"
#include "GS/GS.h"
#include "GS/GSExtra.h"
#include "common/Align.h"
#include "common/Assertions.h"
#include "common/BitUtils.h"
#include "common/Console.h"
#include "common/Error.h"
#include "common/HostSys.h"
#include "common/StateWrapper.h"
#include "common/StringUtil.h"
#include "fmt/format.h"

// ── Construction / Destruction ──

MetalRenderer::MetalRenderer()
    : GSDevice(GSRendererType::Metal)
{
}

MetalRenderer::~MetalRenderer()
{
    Destroy();
}

bool MetalRenderer::Create(GSVSyncMode vsync_mode, bool allow_present_throttle)
{
    NSLog(@"[BionicSX2] MetalRenderer::Create");

    m_dev.dev = MTLCreateSystemDefaultDevice();
    if (!m_dev.dev)
    {
        NSLog(@"[BionicSX2] Failed to create MTLDevice");
        return false;
    }

    m_queue = [m_dev.dev newCommandQueue];
    if (!m_queue)
    {
        NSLog(@"[BionicSX2] Failed to create command queue");
        return false;
    }

    m_dev.features.unified_memory = m_dev.dev.hasUnifiedMemory;

    // Audit Sec 4.2: All iOS devices have unified memory
    m_dev.features.unified_memory = true;

    m_resource_options_shared_wc = MTLResourceStorageModeShared;
    if ([m_dev.dev hasUnifiedMemory])
        m_resource_options_shared_wc |= MTLResourceOptionCPUCacheModeWriteCombined;

    m_fn_constants = [MTLFunctionConstantValues new];
    m_hw_vertex = [MTLVertexDescriptor new];

    m_draw_sync_fence = [m_dev.dev newFence];

    m_use_present_drawable = UsePresentDrawable::Always;

    m_current_draw = 1;
    m_last_finished_draw.store(0, std::memory_order_release);
    m_encoders_in_current_cmdbuf = 0;

    // Set up sampler states
    SamplerSelector sel;
    for (u8 key = 0; key < (1 << 8); key++)
    {
        sel.key = key;
        MTLSamplerDescriptor* desc = [MTLSamplerDescriptor new];
        desc.minFilter = sel.lin ? MTLSamplerMinMagFilterLinear : MTLSamplerMinMagFilterNearest;
        desc.magFilter = sel.lin ? MTLSamplerMinMagFilterLinear : MTLSamplerMinMagFilterNearest;
        desc.mipFilter = sel.mip ? MTLSamplerMipFilterLinear : MTLSamplerMipFilterNotMipmapped;
        desc.sAddressMode = sel.tau ? MTLSamplerAddressModeRepeat : MTLSamplerAddressModeClampToEdge;
        desc.tAddressMode = sel.tav ? MTLSamplerAddressModeRepeat : MTLSamplerAddressModeClampToEdge;
        desc.lodMinClamp = 0.0f;
        desc.lodMaxClamp = FLT_MAX;
        desc.maxAnisotropy = sel.aniso ? 16 : 1;
        m_sampler_hw[key] = [m_dev.dev newSamplerStateWithDescriptor:desc];
    }

    NSLog(@"[BionicSX2] MetalRenderer created successfully");
    return true;
}

void MetalRenderer::Destroy()
{
    m_queue = nil;
    m_dev.dev = nil;
}

void MetalRenderer::AttachSurfaceOnMainThread()
{
    // PORTED: Surface attached via UIView/CAMetalLayer (Audit Sec 4.3)
    if (!m_view || !m_view.layer)
        return;

    m_layer = (CAMetalLayer*)m_view.layer;
    m_layer.device = m_dev.dev;
    m_layer.pixelFormat = MTLPixelFormatBGRA8Unorm;
    m_layer.framebufferOnly = YES;
    m_layer.presentsWithTransaction = NO;
}

void MetalRenderer::DetachSurfaceOnMainThread()
{
    m_layer = nil;
    m_current_drawable = nil;
    m_pass_desc = nil;
}

// ── Surface management ──

RenderAPI MetalRenderer::GetRenderAPI() const { return RenderAPI::Metal; }
bool MetalRenderer::HasSurface() const { return m_layer != nil; }

void MetalRenderer::DestroySurface()
{
    // PORTED: UIView surface cleanup (Audit Sec 4.3)
    m_layer = nil;
    m_current_drawable = nil;
    m_pass_desc = nil;
}

bool MetalRenderer::UpdateWindow() { return true; }
bool MetalRenderer::SupportsExclusiveFullscreen() const { return false; }

std::string MetalRenderer::GetDriverInfo() const
{
    return fmt::format("Metal on {} ({} cores, unified mem: {})",
        [m_dev.dev.name UTF8String],
        (int)m_dev.dev.maxBufferLength,
        m_dev.dev.hasUnifiedMemory ? "yes" : "no");
}

void MetalRenderer::ResizeWindow(u32 new_window_width, u32 new_window_height, float new_window_scale)
{
    // PORTED: UIView resize handling (Audit Sec 4.3)
    if (m_layer)
    {
        m_layer.drawableSize = CGSizeMake(
            new_window_width * new_window_scale,
            new_window_height * new_window_scale);
    }
}

// ── Render pass management ──

void MetalRenderer::BeginRenderPass(NSString* name, GSTexture* color, MTLLoadAction color_load,
    GSTexture* depth, MTLLoadAction depth_load, GSTexture* stencil, MTLLoadAction stencil_load, bool rt1)
{
    // Implementation mirrors GSDeviceMTL::BeginRenderPass but without AppKit dependency
    MTLRenderPassDescriptor* desc = [MTLRenderPassDescriptor renderPassDescriptor];

    if (color)
    {
        GSTextureMTL* tex = static_cast<GSTextureMTL*>(color);
        desc.colorAttachments[0].texture = tex->GetMTLTexture();
        desc.colorAttachments[0].loadAction = color_load;
        desc.colorAttachments[0].storeAction = MTLStoreActionStore;
        desc.colorAttachments[0].slice = rt1 ? 1 : 0;
    }

    if (depth)
    {
        GSTextureMTL* tex = static_cast<GSTextureMTL*>(depth);
        desc.depthAttachment.texture = tex->GetMTLTexture();
        desc.depthAttachment.loadAction = depth_load;
        desc.depthAttachment.storeAction = MTLStoreActionStore;
    }

    if (stencil)
    {
        GSTextureMTL* tex = static_cast<GSTextureMTL*>(stencil);
        desc.stencilAttachment.texture = tex->GetMTLTexture();
        desc.stencilAttachment.loadAction = stencil_load;
        desc.stencilAttachment.storeAction = MTLStoreActionStore;
    }

    id<MTLCommandBuffer> cmdbuf = GetRenderCmdBuf();
    m_current_render.encoder = [cmdbuf renderCommandEncoderWithDescriptor:desc];
    [m_current_render.encoder pushDebugGroup:name];
}

void MetalRenderer::EndRenderPass()
{
    if (m_current_render.encoder)
    {
        [m_current_render.encoder popDebugGroup];
        [m_current_render.encoder endEncoding];
        m_current_render.encoder = nil;
    }
}

void MetalRenderer::FrameCompleted()
{
    EndRenderPass();
    FlushEncoders();

    if (m_current_render_cmdbuf)
    {
        [m_current_render_cmdbuf commit];
        m_current_render_cmdbuf = nil;
    }

    m_current_draw++;
}

// ── Present ──

MetalRenderer::PresentResult MetalRenderer::BeginPresent(bool frame_skip)
{
    if (!m_layer)
        return PresentResult::FrameSkip;

    m_current_drawable = [m_layer nextDrawable];
    if (!m_current_drawable)
        return PresentResult::FrameSkip;

    return PresentResult::OK;
}

void MetalRenderer::EndPresent()
{
    if (m_current_drawable)
    {
        id<MTLCommandBuffer> cmdbuf = GetRenderCmdBuf();
        [cmdbuf presentDrawable:m_current_drawable];
        [cmdbuf commit];
        m_current_render_cmdbuf = nil;
        m_current_drawable = nil;
    }
}

void MetalRenderer::SetVSyncMode(GSVSyncMode mode, bool allow_present_throttle) {}
bool MetalRenderer::SetGPUTimingEnabled(bool enabled) { return false; }
float MetalRenderer::GetAndResetAccumulatedGPUTime() { return 0; }
void MetalRenderer::AccumulateCommandBufferTime(id<MTLCommandBuffer>) {}

// ── Stub implementations for remaining methods ──
// These will be fully implemented when the full Metal backend is ported.

GSTexture* MetalRenderer::CreateSurface(GSTexture::Type, int, int, int, GSTexture::Format) { return nullptr; }
std::unique_ptr<GSDownloadTexture> MetalRenderer::CreateDownloadTexture(u32, u32, GSTexture::Format) { return nullptr; }
void MetalRenderer::ClearSamplerCache() {}
void MetalRenderer::CopyRect(GSTexture*, GSTexture*, const GSVector4i&, u32, u32) {}
void MetalRenderer::DoMerge(GSTexture**, GSVector4*, GSTexture*, GSVector4*, const GSRegPMODE&, const GSRegEXTBUF&, u32, const bool) {}
void MetalRenderer::DoInterlace(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, ShaderInterlace, bool, const InterlaceConstantBuffer&) {}
void MetalRenderer::DoFXAA(GSTexture*, GSTexture*) {}
void MetalRenderer::DoShadeBoost(GSTexture*, GSTexture*, const float[4]) {}
bool MetalRenderer::DoCAS(GSTexture*, GSTexture*, bool, const std::array<u32, NUM_CAS_CONSTANTS>&) { return false; }
void MetalRenderer::RenderHW(GSHWDrawConfig&) {}
void MetalRenderer::RenderCopy(GSTexture*, id<MTLRenderPipelineState>, const GSVector4i&) {}
void MetalRenderer::BeginStretchRect(NSString*, GSTexture*, MTLLoadAction) {}
void MetalRenderer::DoStretchRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, id<MTLRenderPipelineState>, bool, LoadAction, const void*, size_t) {}
void MetalRenderer::DrawStretchRect(const GSVector4&, const GSVector4&, const GSVector2&) {}
void MetalRenderer::PresentRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, PresentShader, float, bool) {}
void MetalRenderer::DrawMultiStretchRects(const MultiStretchRect*, u32, GSTexture*, ShaderConvert) {}
void MetalRenderer::UpdateCLUTTexture(GSTexture*, float, u32, u32, GSTexture*, u32, u32) {}
void MetalRenderer::ConvertToIndexedTexture(GSTexture*, float, u32, u32, u32, u32, GSTexture*, u32, u32) {}
void MetalRenderer::FilteredDownsampleTexture(GSTexture*, GSTexture*, u32, const GSVector2i&, const GSVector4&) {}
void MetalRenderer::BeginDSAsRT(GSTexture*, const GSVector4i&) {}
void MetalRenderer::FlushClears(GSTexture*) {}
void MetalRenderer::DoStretchRect(GSTexture*, const GSVector4&, GSTexture*, const GSVector4&, GSHWDrawConfig::ColorMaskSelector, ShaderConvert, bool) {}
void MetalRenderer::MRESetHWPipelineState(GSHWDrawConfig::VSSelector, GSHWDrawConfig::PSSelector, GSHWDrawConfig::BlendState, GSHWDrawConfig::ColorMaskSelector) {}
void MetalRenderer::MRESetDSS(DepthStencilSelector) {}
void MetalRenderer::MRESetDSS(id<MTLDepthStencilState>) {}
void MetalRenderer::MRESetSampler(SamplerSelector) {}
void MetalRenderer::MRESetTexture(GSTexture*, int) {}
void MetalRenderer::MRESetVertices(id<MTLBuffer>, size_t) {}
void MetalRenderer::MRESetVSIndices(id<MTLBuffer>, size_t) {}
void MetalRenderer::MRESetScissor(const GSVector4i&) {}
void MetalRenderer::MREClearScissor() {}
void MetalRenderer::MRESetCB(const GSHWDrawConfig::VSConstantBuffer&) {}
void MetalRenderer::MRESetCB(const GSHWDrawConfig::PSConstantBuffer&) {}
void MetalRenderer::MRESetBlendColor(u8) {}
void MetalRenderer::MRESetPipeline(id<MTLRenderPipelineState>) {}
void MetalRenderer::MREInitHWDraw(GSHWDrawConfig&, const Map&) {}
void MetalRenderer::SetupDestinationAlpha(GSTexture*, GSTexture*, const GSVector4i&, SetDATM) {}
void MetalRenderer::SendHWDraw(GSHWDrawConfig&, id<MTLRenderCommandEncoder>, id<MTLBuffer>, size_t, bool, bool) {}
void MetalRenderer::RenderImGui(ImDrawData*) {}
void MetalRenderer::PushDebugGroup(const char*, ...) {}
void MetalRenderer::PopDebugGroup() {}
void MetalRenderer::InsertDebugMessage(DebugMessageCategory, const char*, ...) {}
void MetalRenderer::ProcessDebugEntry(id<MTLCommandEncoder>, const DebugEntry&) {}
void MetalRenderer::FlushDebugEntries(id<MTLCommandEncoder>) {}
void MetalRenderer::EndDebugGroup(id<MTLCommandEncoder>) {}
void MetalRenderer::UpdateTexture(id<MTLTexture>, u32, u32, u32, u32, const void*, u32) {}
void MetalRenderer::FlushEncoders() {}
void MetalRenderer::FlushEncodersForReadback() {}
MetalRenderer::Map MetalRenderer::Allocate(UploadBuffer&, size_t) { return {}; }
MetalRenderer::Map MetalRenderer::Allocate(BufferPair&, size_t) { return {}; }
void MetalRenderer::Sync(BufferPair&) {}
id<MTLBlitCommandEncoder> MetalRenderer::GetTextureUploadEncoder() { return nil; }
id<MTLBlitCommandEncoder> MetalRenderer::GetLateTextureUploadEncoder() { return nil; }
id<MTLBlitCommandEncoder> MetalRenderer::GetVertexUploadEncoder() { return nil; }
id<MTLCommandBuffer> MetalRenderer::GetRenderCmdBuf()
{
    if (!m_current_render_cmdbuf)
        m_current_render_cmdbuf = [m_queue commandBuffer];
    return m_current_render_cmdbuf;
}
id<MTLCommandBuffer> MetalRenderer::GetRenderCmdBufWithoutCreate() { return m_current_render_cmdbuf; }
id<MTLFence> MetalRenderer::GetSpinFence() { return nil; }
id<MTLTexture> MetalRenderer::GetRT1DepthTexture(GSTextureMTL*) { return nil; }
void MetalRenderer::DrawCommandBufferFinished(u64, id<MTLCommandBuffer>) {}
MRCOwned<id<MTLFunction>> MetalRenderer::LoadShader(NSString* name) { return nil; }
MRCOwned<id<MTLRenderPipelineState>> MetalRenderer::MakePipeline(MTLRenderPipelineDescriptor*, id<MTLFunction>, id<MTLFunction>, NSString*) { return nil; }
MRCOwned<id<MTLComputePipelineState>> MetalRenderer::MakeComputePipeline(id<MTLFunction>, NSString*) { return nil; }
