// PORTED FROM: pcsx2/VMManager.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 2.3-ADDENDUM (2.3-E, 2.3-F), 6.2, 12.2
// STATUS: NEW — Custom VM init for iOS, bypasses macOS VMManager::StartVM()

#import <Foundation/Foundation.h>
#include "PrecompiledHeader.h"
#include "VMManager.h"
#include "Config.h"
#include "GS/GS.h"
#include "Memory.h"
#include "R5900.h"
#include "Hw.h"
#include "Vif_Dynarec.h"
#include "Vif.h"
#include "Vif_Unpack.h"
#include "CDVD/CDVD.h"
#include "common/Console.h"
#include "common/HostSys.h"

namespace iOSVMManager {

// Static init guard prevents re-entry crash loops (Audit Sec 2.3-E)
static bool s_initialized = false;

bool StartVM(const char* isoPath)
{
    if (s_initialized) {
        NSLog(@"[BionicSX2] VM already initialized, skipping");
        return true;
    }

    NSLog(@"[BionicSX2] Starting VM...");

    // Step 1: Configure emulator flags BEFORE any reset call
    // Audit Section 2.3-F: newVifDynaRec is compile-time const in Vif_Dynarec.h
    // The #ifdef PCSX2_TARGET_IOS fix is already applied at compile time.
    // At runtime, disable all recompilers to use interpreter paths:
    EmuConfig.Cpu.Recompiler.EnableEE  = false; // Interpreter only — no JIT (Audit Sec 2.2)
    EmuConfig.Cpu.Recompiler.EnableVU0 = false; // Audit Sec 2.2
    EmuConfig.Cpu.Recompiler.EnableVU1 = false; // Audit Sec 2.2
    EmuConfig.Cpu.Recompiler.EnableIOP = false; // Audit Sec 2.3
    EmuConfig.GS.Renderer = GSRendererType::Metal; // Metal only on iOS

    // Step 2: SysMemory::Allocate() MUST be called before cpuReset()
    // Audit Section 2.3-E: On macOS, SysMemory::Reset() runs at
    // VMManager::StartVM():1525 BEFORE cpuReset() at :1526.
    if (!SysMemory::Allocate()) {
        NSLog(@"[BionicSX2] SysMemory::Allocate() failed");
        return false;
    }
    NSLog(@"[BionicSX2] SysMemory::Allocate() succeeded");

    // Step 3: Reset CPU state
    // cpuReset() → hwReset() → vif0Reset/vif1Reset → resetNewVif(0/1)
    cpuReset();
    NSLog(@"[BionicSX2] cpuReset() completed");

    // Step 4: Initialize GS with Metal backend
    Pcsx2Config::GSOptions gsOptions;
    if (!GSopen(gsOptions, GSRendererType::Metal, nullptr, 0)) {
        NSLog(@"[BionicSX2] GSopen(Metal) failed");
        return false;
    }
    NSLog(@"[BionicSX2] GSopen(Metal) succeeded");

    // Step 5: Load ISO if provided
    if (isoPath && strlen(isoPath) > 0) {
        NSString* isoNSStr = [NSString stringWithUTF8String:isoPath];
        NSLog(@"[BionicSX2] Loading ISO: %@", isoNSStr);
        CDVDsys_SetFile(CDVD_SourceType::Iso, isoPath);
        CDVDsys_ChangeSource(CDVD_SourceType::Iso);
    }

    s_initialized = true;
    NSLog(@"[BionicSX2] VM started successfully");
    return true;
}

void StopVM()
{
    NSLog(@"[BionicSX2] Stopping VM...");
    GSclose();
    SysMemory::Release();
    s_initialized = false;
    NSLog(@"[BionicSX2] VM stopped");
}

bool IsInitialized()
{
    return s_initialized;
}

} // namespace iOSVMManager
