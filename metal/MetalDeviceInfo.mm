// PORTED FROM: pcsx2/GS/Renderers/Metal/GSMTLDeviceInfo.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.2, 13.4
// STATUS: GREEN — Removed AMD slow_color_compression heuristic (Audit Sec 13.4)

// PORTED: AMD-specific heuristic removed (slow_color_compression) (Audit Sec 13.4)
// PORTED: All iOS devices have Apple GPUs — no AMD/NVIDIA workarounds needed

#import <Metal/Metal.h>
#include "MetalDeviceInfo.h"
#include "common/Console.h"
#include <string>

GSMTLDevice GSMTLDeviceInfo::GetDevice()
{
    GSMTLDevice dev;
    dev.dev = MTLCreateSystemDefaultDevice();
    if (!dev.dev)
    {
        Console.Error("Failed to create Metal device.");
        return dev;
    }

    // Device identification
    dev.name = std::string([dev.dev.name UTF8String]);

    // Feature detection
    dev.features.unified_memory = dev.dev.hasUnifiedMemory;
    dev.features.texture_swizzle = [dev.dev supportsFamily:MTLGPUFamilyApple3];
    dev.features.framebuffer_fetch = [dev.dev supportsFamily:MTLGPUFamilyApple1];
    dev.features.primid = [dev.dev supportsFamily:MTLGPUFamilyApple4];
    dev.features.memoryless_textures = [dev.dev supportsFamily:MTLGPUFamilyApple2];
    dev.features.depth_feedback = true;

    // Shader version detection
    if ([dev.dev supportsFamily:MTLGPUFamilyApple8])
        dev.features.shader_version = 3;
    else if ([dev.dev supportsFamily:MTLGPUFamilyApple7])
        dev.features.shader_version = 3;
    else if ([dev.dev supportsFamily:MTLGPUFamilyApple6])
        dev.features.shader_version = 2;
    else if ([dev.dev supportsFamily:MTLGPUFamilyApple4])
        dev.features.shader_version = 2;
    else
        dev.features.shader_version = 1;

    // Max texture size
    dev.features.max_texsize = dev.dev.supports32BitMSAA ? 16384 : 8192;

    Console.WriteLn("Metal Device: %s (unified: %s, shader v%d)",
        dev.name.c_str(),
        dev.features.unified_memory ? "yes" : "no",
        dev.features.shader_version);

    return dev;
}
