// PORTED FROM: pcsx2/GS/Renderers/Metal/GSMTLSharedHeader.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 3.2
// STATUS: GREEN — Pure C types, no platform dependency

#pragma once

#import <simd/simd.h>

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#define NSObject
#define NSString
#else
#include <Metal/Metal.h>
#endif

// Buffer index constants
typedef NS_ENUM(NSInteger, GSMTLBufferIndex)
{
    GSMTLBufferIndexVSConstants = 0,
    GSMTLBufferIndexPSConstants = 1,
    GSMTLBufferIndexVertexBuffer = 2,
    GSMTLBufferIndexIndexBuffer = 3,
};

// Texture index constants
typedef NS_ENUM(NSInteger, GSMTLTextureIndex)
{
    GSMTLTextureIndexRT = 0,
    GSMTLTextureIndexPalette = 1,
    GSMTLTextureIndexSource = 2,
    GSMTLTextureIndexCLUT = 3,
    GSMTLTextureIndexCount = 4,
};

// Shader converter types
typedef NS_ENUM(NSInteger, ShaderConvert)
{
    ShaderConvert_None = -1,
    ShaderConvert_Copy = 0,
    ShaderConvert_DATM0 = 1,
    ShaderConvert_DATM1 = 2,
    ShaderConvert_RGBA8_TO_16_BITS = 3,
    ShaderConvert_16_BITS_TO_RGBA8 = 4,
    ShaderConvert_RGBA8_TO_FLOAT32 = 5,
    ShaderConvert_FLOAT32_TO_RGBA8 = 6,
    ShaderConvert_FLOAT32_TO_16_BITS = 7,
    ShaderConvert_COPY8 = 8,
    ShaderConvert_DATM2 = 9,
    ShaderConvert_DATM3 = 10,
    ShaderConvert_TRANSPOSE = 11,
    ShaderConvert_RGBA_TO_ARGB = 12,
    ShaderConvert_COPY16 = 13,
    ShaderConvert_COUNT = 14,
};

// Present shader types
typedef NS_ENUM(NSInteger, PresentShader)
{
    PresentShader_Copy = 0,
    PresentShader_Scanline = 1,
    PresentShader_Diagonal = 2,
    PresentShader_Triangular = 3,
    PresentShader_Weave = 4,
    PresentShader_Blend = 5,
    PresentShader_Count = 6,
};

// Interlace shader types
#define NUM_INTERLACE_SHADERS 5

typedef NS_ENUM(NSInteger, ShaderInterlace)
{
    ShaderInterlace_Weave = 0,
    ShaderInterlace_Bob = 1,
    ShaderInterlace_Blend = 2,
    ShaderInterlace_Adaptive = 3,
    ShaderInterlace_Auto = 4,
};

#define NUM_CAS_CONSTANTS 4

// Vertex format for convert shaders
struct ConvertVertexShader
{
    simd_float2 pos;
    simd_float2 tex;
};

// VS constant buffer
struct VSConstantBuffer
{
    simd_float4 vertex_scale_offsets;
    simd_float4 texture_scale_offsets;
    simd_float4 depth_scale;
};

// PS constant buffer
struct PSConstantBuffer
{
    simd_float4 source_size;
    simd_float4 pixel_size;
    simd_float4 target_size;
    simd_float4 scale;
    simd_float4 source_rect;
    simd_float4 fog_color;
    simd_float4 ta0_afix;
    simd_float4 eye;
};
