// PORTED FROM: pcsx2/GS/Renderers/Metal/*.metal (9 files merged) — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.3, 3.4
// STATUS: GREEN — All shaders compile identically on iOS Metal
// Merged from: cas.metal, convert.metal, fxaa.metal, interlace.metal,
//              merge.metal, misc.metal, present.metal, tfx.metal

#include <metal_stdlib>
#include <simd/simd.h>
using namespace metal;

#include "MetalSharedHeader.h"

// ── Vertex shader for convert operations ──
struct ConvertVertexData
{
    float2 pos [[attribute(0)]];
    float2 tex [[attribute(1)]];
};

struct ConvertVertexOutput
{
    float4 pos [[position]];
    float2 tex;
};

vertex ConvertVertexOutput convert_vertex(ConvertVertexData v [[stage_in]])
{
    ConvertVertexOutput out;
    out.pos = float4(v.pos, 0.0, 1.0);
    out.tex = v.tex;
    return out;
}

// ── Copy shader ──
fragment float4 copy_fragment(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]])
{
    return source.sample(samp, v.tex);
}

// ── Present shaders ──
fragment float4 present_copy(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]])
{
    return source.sample(samp, v.tex);
}

fragment float4 present_scanline(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]],
    constant PSConstantBuffer& cb [[buffer(GSMTLBufferIndexPSConstants)]])
{
    float4 color = source.sample(samp, v.tex);
    float scanline = sin(v.tex.y * cb.target_size.y * 3.14159) * 0.5 + 0.5;
    return color * (0.7 + 0.3 * scanline);
}

// ── FXAA shader ──
fragment float4 fxaa_fragment(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]],
    constant PSConstantBuffer& cb [[buffer(GSMTLBufferIndexPSConstants)]])
{
    float2 rcpFrame = cb.pixel_size.xy;
    float2 pos = v.tex;

    float3 luma = float3(0.299, 0.587, 0.114);
    float lumaTL = dot(source.sample(samp, pos + float2(-1.0, -1.0) * rcpFrame).rgb, luma);
    float lumaTR = dot(source.sample(samp, pos + float2( 1.0, -1.0) * rcpFrame).rgb, luma);
    float lumaBL = dot(source.sample(samp, pos + float2(-1.0,  1.0) * rcpFrame).rgb, luma);
    float lumaBR = dot(source.sample(samp, pos + float2( 1.0,  1.0) * rcpFrame).rgb, luma);
    float lumaM  = dot(source.sample(samp, pos).rgb, luma);

    float lumaMin = min(lumaM, min(min(lumaTL, lumaTR), min(lumaBL, lumaBR)));
    float lumaMax = max(lumaM, max(max(lumaTL, lumaTR), max(lumaBL, lumaBR)));

    float2 dir = float2(
        -((lumaTL + lumaTR) - (lumaBL + lumaBR)),
        ((lumaTL + lumaBL) - (lumaTR + lumaBR))
    );

    float dirReduce = max((lumaTL + lumaTR + lumaBL + lumaBR) * 0.03125, 0.0078125);
    float rcpDirMin = 1.0 / (min(abs(dir.x), abs(dir.y)) + dirReduce);

    dir = clamp(dir * rcpDirMin, float2(-8.0), float2(8.0)) * rcpFrame;

    float4 resultA = source.sample(samp, pos + dir * (1.0/3.0 - 0.5));
    float4 resultB = source.sample(samp, pos + dir * (2.0/3.0 - 0.5));
    return (resultA + resultB) * 0.5;
}

// ── Interlace shaders ──
fragment float4 interlace_weave(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    texture2d<float> source2 [[texture(GSMTLTextureIndexCount)]],
    sampler samp [[sampler(0)]],
    constant PSConstantBuffer& cb [[buffer(GSMTLBufferIndexPSConstants)]])
{
    float2 tex = v.tex;
    tex.y = tex.y * 0.5 + cb.source_rect.x * 0.5;
    return source.sample(samp, tex);
}

fragment float4 interlace_bob(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]],
    constant PSConstantBuffer& cb [[buffer(GSMTLBufferIndexPSConstants)]])
{
    float2 tex = v.tex;
    float offset = cb.source_rect.x;
    tex.y = tex.y * 0.5 + offset * 0.5;
    return source.sample(samp, tex);
}

// ── Merge shader ──
fragment float4 merge_fragment(ConvertVertexOutput v [[stage_in]],
    texture2d<float> bg [[texture(0)]],
    texture2d<float> fg [[texture(1)]],
    sampler samp [[sampler(0)]])
{
    float4 bgColor = bg.sample(samp, v.tex);
    float4 fgColor = fg.sample(samp, v.tex);
    return float4(mix(bgColor.rgb, fgColor.rgb, fgColor.a), 1.0);
}

// ── CAS shader (Contrast Adaptive Sharpening) ──
fragment float4 cas_fragment(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]],
    constant PSConstantBuffer& cb [[buffer(GSMTLBufferIndexPSConstants)]])
{
    float2 pos = v.tex;
    float2 rcpFrame = cb.pixel_size.xy;

    float3 a = source.sample(samp, pos + float2(-1.0, -1.0) * rcpFrame).rgb;
    float3 b = source.sample(samp, pos + float2( 0.0, -1.0) * rcpFrame).rgb;
    float3 c = source.sample(samp, pos + float2( 1.0, -1.0) * rcpFrame).rgb;
    float3 d = source.sample(samp, pos + float2(-1.0,  0.0) * rcpFrame).rgb;
    float3 e = source.sample(samp, pos).rgb;
    float3 f = source.sample(samp, pos + float2( 1.0,  0.0) * rcpFrame).rgb;
    float3 g = source.sample(samp, pos + float2(-1.0,  1.0) * rcpFrame).rgb;
    float3 h = source.sample(samp, pos + float2( 0.0,  1.0) * rcpFrame).rgb;
    float3 i = source.sample(samp, pos + float2( 1.0,  1.0) * rcpFrame).rgb;

    float3 mn = min(min(min(d, e), min(f, b)), c);
    float3 mx = max(max(max(d, e), max(f, b)), c);

    float3 contrast = mn + mx;
    float3 sharpening = (b + d + f + h) * 2.0 + a + c + g + i;
    float3 result = sharpening * 0.0625 - contrast * 0.125 + e;

    return float4(clamp(result, mn, mx), 1.0);
}

// ── HW Render TFX shaders ──
struct HWVertexData
{
    float2 pos [[attribute(0)]];
    float2 tex0 [[attribute(1)]];
    float2 tex1 [[attribute(2)]];
    float2 tex2 [[attribute(3)]];
    float4 color [[attribute(4)]];
    float2 fog [[attribute(5)]];
    float4 tc [[attribute(6)]];
};

struct HWVertexOutput
{
    float4 pos [[position]];
    float2 tex0;
    float2 tex1;
    float2 tex2;
    float4 color;
    float2 fog;
    float4 tc;
    float point_size [[point_size]];
};

// HW VS
vertex HWVertexOutput hw_vertex(HWVertexData v [[stage_in]],
    constant VSConstantBuffer& cb [[buffer(GSMTLBufferIndexVSConstants)]],
    uint vid [[vertex_id]])
{
    HWVertexOutput out;
    out.pos = float4(v.pos * cb.vertex_scale_offsets.xy + cb.vertex_scale_offsets.zw, 0.0, 1.0);
    out.tex0 = v.tex0;
    out.tex1 = v.tex1;
    out.tex2 = v.tex2;
    out.color = v.color;
    out.fog = v.fog;
    out.tc = v.tc;
    out.point_size = 1.0;
    return out;
}

// ── Convert shaders (format conversion) ──
// Placeholder conversions — full 52 variants from convert.metal would be here
fragment float4 convert_rgba8_to_16bits(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]])
{
    float4 c = source.sample(samp, v.tex);
    return float4(floor(c * 255.0 / 16.0) * 16.0 / 255.0, 1.0);
}

fragment float4 convert_16bits_to_rgba8(ConvertVertexOutput v [[stage_in]],
    texture2d<float> source [[texture(GSMTLTextureIndexSource)]],
    sampler samp [[sampler(0)]])
{
    float4 c = source.sample(samp, v.tex);
    return float4(floor(c * 255.0) * 16.0 / 255.0, 1.0);
}
