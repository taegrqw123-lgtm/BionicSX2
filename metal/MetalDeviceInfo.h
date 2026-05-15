// PORTED FROM: pcsx2/GS/Renderers/Metal/GSMTLDeviceInfo.h — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.2
// STATUS: GREEN

#pragma once

#import <Metal/Metal.h>
#include <string>

struct GSMTLDeviceFeatures
{
    bool unified_memory = false;
    bool texture_swizzle = false;
    bool framebuffer_fetch = false;
    bool primid = false;
    bool memoryless_textures = false;
    bool depth_feedback = false;
    int shader_version = 1;
    u32 max_texsize = 4096;
};

struct GSMTLDevice
{
    id<MTLDevice> dev = nil;
    std::string name;
    GSMTLDeviceFeatures features;
};

namespace GSMTLDeviceInfo
{
    GSMTLDevice GetDevice();
}
