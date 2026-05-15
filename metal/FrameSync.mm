// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm (extracted) — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.2
// STATUS: NEW — Frame synchronization using MTLFence, MTLCommandBuffer completion handlers

// Audit Sec 4.2: Extracted frame sync logic from GSDeviceMTL for iOS clarity
// Uses MTLFence, MTLCommandBuffer completion handlers, ReadbackSpinManager

#import <Metal/Metal.h>
#include "FrameSync.h"
#include "common/Console.h"
#include "common/ReadbackSpinManager.h"
#include <atomic>

FrameSync::FrameSync()
    : m_spin_manager(std::make_unique<ReadbackSpinManager>())
{
}

FrameSync::~FrameSync() = default;

bool FrameSync::Initialize(id<MTLDevice> device)
{
    m_spin_fence = [device newFence];
    if (!m_spin_fence)
    {
        NSLog(@"[BionicSX2] Failed to create spin fence");
        return false;
    }

    m_spin_manager->Clear();
    return true;
}

void FrameSync::Shutdown()
{
    m_spin_fence = nil;
    m_spin_manager->Clear();
}

void FrameSync::SignalFence(id<MTLCommandBuffer> cmdbuf)
{
    // Encode fence update at end of command buffer
    id<MTLBlitCommandEncoder> blit = [cmdbuf blitCommandEncoder];
    [blit updateFence:m_spin_fence afterStages:MTLRenderStagesFragment];
    [blit endEncoding];
}

void FrameSync::WaitForFence(id<MTLCommandBuffer> cmdbuf)
{
    id<MTLBlitCommandEncoder> blit = [cmdbuf blitCommandEncoder];
    [blit waitForFence:m_spin_fence beforeStages:MTLRenderStagesVertex];
    [blit endEncoding];
}

void FrameSync::SubmitSyncCommands(id<MTLCommandQueue> queue)
{
    id<MTLCommandBuffer> cmdbuf = [queue commandBuffer];
    SignalFence(cmdbuf);
    [cmdbuf commit];
}

void FrameSync::WaitForGPU(id<MTLDevice> device)
{
    m_spin_manager->WaitForAll();
}

void FrameSync::OnCommandBufferCompleted(u64 draw_id)
{
    m_spin_manager->Deactivate(draw_id);
}
