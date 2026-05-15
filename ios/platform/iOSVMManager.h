// BionicSX2 iOS VM Manager — Header
// AUDIT REFERENCE: Section 2.3-ADDENDUM

#pragma once

namespace iOSVMManager {
    bool StartVM(const char* isoPath);
    void StopVM();
    bool IsInitialized();
}
