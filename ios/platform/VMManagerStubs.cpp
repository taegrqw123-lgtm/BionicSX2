// VMManager, VU_Thread, Sio stub implementations
#include "PrecompiledHeader.h"
#include "VMManager.h"
#include "MTVU.h"
#include "SIO/Sio.h"
#include "SIO/Sio2.h"

// VMManager
u32 VMManager::GetDiscCRC() { return 0; }
std::string VMManager::GetDiscSerial() { return {}; }
GSVSyncMode VMManager::GetEffectiveVSyncMode() { return GSVSyncMode::Disabled; }
VMManager::State VMManager::GetState() { return VMManager::State::Shutdown; }
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

// Sio
Sio g_Sio0;
Sio2 g_Sio2;
u16 Sio0::GetBaud() { return 0; }
u16 Sio0::GetCtrl() { return 0; }
u16 Sio0::GetMode() { return 0; }
u8  Sio0::GetRxData() { return 0; }
u16 Sio0::GetStat() { return 0; }
void Sio0::Interrupt(Sio0Interrupt) {}
void Sio0::SetBaud(u16) {}
void Sio0::SetCtrl(u16) {}
void Sio0::SetMode(u16) {}
void Sio0::SetTxData(u8) {}
u32 Sio2::Read() { return 0; }
void Sio2::SetCmd(u32, u32) {}
void Sio2::SetCtrl(u32) {}
void Sio2::Write(u8) {}
