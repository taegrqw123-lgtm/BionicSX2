// VMManager, VU_Thread, Sio stub implementations
#include "PrecompiledHeader.h"
#include "VMManager.h"
#include "MTVU.h"


// VMManager
u32 VMManager::GetDiscCRC() { return 0; }
std::string VMManager::GetDiscSerial() { return {}; }
GSVSyncMode VMManager::GetEffectiveVSyncMode() { return GSVSyncMode::Disabled; }
VMState VMManager::GetState() { return VMState::Shutdown; }
float VMManager::GetTargetSpeed() { return 1.0f; }
std::string VMManager::GetTitle(bool) { return {}; }
bool VMManager::HasValidVM() { return false; }
bool VMManager::IsTargetSpeedAdjustedToHost() { return false; }
void VMManager::SetPaused(bool) {}
bool VMManager::ShouldAllowPresentThrottle() { return false; }

bool VMManager::Internal::HasBootedELF() { return false; }
std::string VMManager::Internal::GetELFOverride() { return {}; }
void VMManager::Internal::DisableFastBoot() {}
void VMManager::Internal::FrameRateChanged() {}
void VMManager::Internal::VSyncOnCPUThread() {}
bool VMManager::Internal::IsFastBootInProgress() { return false; }
void VMManager::Internal::PollInputOnCPUThread() {}
void VMManager::Internal::ELFLoadingOnCPUThread(const std::string&) {}
bool VMManager::Internal::IsExecutionInterrupted() { return false; }
u32 VMManager::Internal::GetCurrentELFEntryPoint() { return 0; }
void VMManager::Internal::EntryPointCompilingOnCPUThread() {}
void VMManager::Internal::Throttle() {}

// VU_Thread
u32 VU_Thread::Get_MTVUChanges() { return 0; }
void VU_Thread::WaitVU() {}
void VU_Thread::WriteCol(vifStruct&) {}
void VU_Thread::WriteRow(vifStruct&) {}

