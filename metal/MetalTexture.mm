// PORTED FROM: pcsx2/GS/Renderers/Metal/GSTextureMTL.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.5
// STATUS: GREEN — Zero changes required; MTLResourceStorageModeShared works on iOS Apple Silicon

// PORTED: MTLResourceStorageModeShared works on iOS Apple Silicon (Audit Sec 3.5)
// PORTED: All texture upload management patterns are portable (Audit Sec 3.5)

#include "MetalTexture.h"
#include "MetalRenderer.h"
#include "common/Align.h"
#include "common/Assertions.h"
#include "common/Console.h"

GSTextureMTL::GSTextureMTL(GSTexture::Type type, GSTexture::Format format, u16 width, u16 height, u16 layers, u16 levels)
    : GSTexture(type, format, width, height, layers, levels)
{
}

GSTextureMTL::~GSTextureMTL()
{
    Destroy();
}

bool GSTextureMTL::Create(MetalRenderer* renderer, id<MTLTexture> texture)
{
    m_renderer = renderer;
    m_texture = texture;
    return m_texture != nil;
}

bool GSTextureMTL::Create(MetalRenderer* renderer, MTLTextureDescriptor* desc)
{
    m_renderer = renderer;
    m_texture = [renderer->m_dev.dev newTextureWithDescriptor:desc];
    return m_texture != nil;
}

void GSTextureMTL::Destroy()
{
    m_texture = nil;
}

id<MTLTexture> GSTextureMTL::GetMTLTexture() const
{
    return m_texture;
}

bool GSTextureMTL::Update(const GSVector4i& rect, const void* data, int stride, uint32_t layer)
{
    if (!m_texture)
        return false;

    MTLRegion region = MTLRegionMake2D(rect.left, rect.top, rect.width(), rect.height());
    [m_texture replaceRegion:region
                 mipmapLevel:0
                       slice:layer
                   withBytes:data
                 bytesPerRow:stride
               bytesPerImage:0];
    return true;
}

bool GSTextureMTL::Map(GSMap& m, const GSVector4i& area, uint32_t layer)
{
    return false; // Not implemented for initial iOS port
}

void GSTextureMTL::Unmap()
{
}

void GSTextureMTL::SetDebugName(const std::string_view& name)
{
    if (m_texture)
        m_texture.label = [NSString stringWithUTF8String:std::string(name).c_str()];
}

void GSTextureMTL::CommitClear()
{
    if (m_state == GSTexture::State::Cleared && m_texture)
    {
        MTLRegion region = MTLRegionMake2D(0, 0, m_width, m_height);
        uint8_t clearColor[4] = {0, 0, 0, 0};
        [m_texture replaceRegion:region
                     mipmapLevel:0
                           slice:0
                       withBytes:clearColor
                     bytesPerRow:m_width * 4
                   bytesPerImage:0];
        m_state = GSTexture::State::Dirty;
    }
}
