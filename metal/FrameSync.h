// PORTED FROM: pcsx2/GS/Renderers/Metal/GSDeviceMTL.mm (extracted) — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.2
// STATUS: NEW

#pragma once

#import <Metal/Metal.h>
#include <memory>
#include <atomic>

class ReadbackSpinManager;

class FrameSync
{
public:
    FrameSync();
    ~FrameSync();

    bool Initialize(id<MTLDevice> device);
    void Shutdown();

    void SignalFence(id<MTLCommandBuffer> cmdbuf);
    void WaitForFence(id<MTLCommandBuffer> cmdbuf);
    void SubmitSyncCommands(id<MTLCommandQueue> queue);
    void WaitForGPU(id<MTLDevice> device);
    void OnCommandBufferCompleted(u64 draw_id);

private:
    MRCOwned<id<MTLFence>> m_spin_fence;
    std::unique_ptr<ReadbackSpinManager> m_spin_manager;
};
