// PORTED FROM: pcsx2/GS/Renderers/Metal/GSTextureMTL.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.5
// STATUS: GREEN

#pragma once

#import <Metal/Metal.h>
#include "GS/GS.h"

class MetalRenderer;

class GSTextureMTL final : public GSTexture
{
public:
    GSTextureMTL(Type type, Format format, u16 width, u16 height, u16 layers, u16 levels);
    ~GSTextureMTL() override;

    bool Create(MetalRenderer* renderer, id<MTLTexture> texture);
    bool Create(MetalRenderer* renderer, MTLTextureDescriptor* desc);
    void Destroy();

    id<MTLTexture> GetMTLTexture() const;

    bool Update(const GSVector4i& rect, const void* data, int stride, uint32_t layer = 0) override;
    bool Map(GSMap& m, const GSVector4i& area, uint32_t layer = 0) override;
    void Unmap() override;
    void SetDebugName(const std::string_view& name) override;
    void CommitClear() override;

private:
    MetalRenderer* m_renderer = nullptr;
    MRCOwned<id<MTLTexture>> m_texture;
};
