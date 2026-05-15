// PORTED FROM: common/Linux/LnxHostSys.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 6.2, 6.3
// STATUS: NEW — iOS-safe memory management using Mach VM API
// Replaces mmap/mprotect with vm_allocate/vm_protect per Audit Sec 6.2

#include "PrecompiledHeader.h"
#import <Foundation/Foundation.h>
#include "common/Assertions.h"
#include "common/BitUtils.h"
#include "common/Console.h"
#include "common/CrashHandler.h"
#include "common/Error.h"
#include "common/HostSys.h"

#include <cstdio>
#include <csignal>
#include <cerrno>
#include <mutex>
#include <mach/mach.h>
#include <mach/mach_init.h>
#include <mach/vm_map.h>
#include <sys/sysctl.h>
#include <unistd.h>

#include "fmt/format.h"

// Audit Sec 6.2: Replace mmap/mprotect with Mach VM API for iOS
// vm_allocate / vm_protect are available on both macOS and iOS

static uint MachProt(const PageProtectionMode& mode)
{
    uint prot = VM_PROT_NONE;
    if (mode.CanWrite())
        prot |= VM_PROT_WRITE;
    if (mode.CanRead())
        prot |= VM_PROT_READ;
    if (mode.CanExecute())
        prot |= VM_PROT_EXECUTE | VM_PROT_READ;
    return prot;
}

void HostSys::MemProtect(void* baseaddr, size_t size, const PageProtectionMode& mode)
{
    pxAssertMsg((size & (__pagesize - 1)) == 0, "Size is page aligned");

    const uint machmode = MachProt(mode);
    const kern_return_t kr = vm_protect(mach_task_self(),
        reinterpret_cast<vm_address_t>(baseaddr), size, FALSE, machmode);
    if (kr != KERN_SUCCESS) {
        NSLog(@"[BionicSX2] vm_protect() failed: %x", kr);
        pxFail("vm_protect() failed");
    }
}

std::string HostSys::GetFileMappingName(const char* prefix)
{
    const unsigned pid = static_cast<unsigned>(getpid());
    return fmt::format("{}_{}", prefix, pid);
}

void* HostSys::CreateSharedMemory(const char* name, size_t size)
{
    // Audit Sec 6.3: iOS does not support shm_open in the same way.
    // Use Mach VM allocation as a shared memory replacement.
    vm_address_t addr = 0;
    kern_return_t kr = vm_allocate(mach_task_self(), &addr, size, VM_FLAGS_ANYWHERE);
    if (kr != KERN_SUCCESS) {
        NSLog(@"[BionicSX2] vm_allocate(%zu) for shared memory failed: %x", size, kr);
        return nullptr;
    }
    return reinterpret_cast<void*>(addr);
}

void HostSys::DestroySharedMemory(void* ptr)
{
    if (ptr) {
        vm_deallocate(mach_task_self(),
            reinterpret_cast<vm_address_t>(ptr), 0);
    }
}

size_t HostSys::GetRuntimePageSize()
{
    int res = sysconf(_SC_PAGESIZE);
    return (res > 0) ? static_cast<size_t>(res) : 0;
}

size_t HostSys::GetRuntimeCacheLineSize()
{
    // Audit Sec 6.2: sysctl works on iOS for cache line size
    u64 cachelinesize = 0;
    size_t len = sizeof(cachelinesize);
    int mib[] = {CTL_HW, HW_CACHELINE};
    if (sysctl(mib, 2, &cachelinesize, &len, NULL, 0) < 0)
        return 128; // Default for Apple Silicon
    return static_cast<size_t>(cachelinesize);
}

SharedMemoryMappingArea::SharedMemoryMappingArea(u8* base_ptr, size_t size, size_t num_pages)
    : m_base_ptr(base_ptr)
    , m_size(size)
    , m_num_pages(num_pages)
{
}

SharedMemoryMappingArea::~SharedMemoryMappingArea()
{
    pxAssertRel(m_num_mappings == 0, "No mappings left");
    if (m_base_ptr) {
        vm_deallocate(mach_task_self(),
            reinterpret_cast<vm_address_t>(m_base_ptr), m_size);
    }
}

std::unique_ptr<SharedMemoryMappingArea> SharedMemoryMappingArea::Create(size_t size, bool jit)
{
    pxAssertRel(Common::IsAlignedPow2(size, __pagesize), "Size is page aligned");

    vm_address_t addr = 0;
    kern_return_t kr = vm_allocate(mach_task_self(), &addr, size, VM_FLAGS_ANYWHERE);
    if (kr != KERN_SUCCESS) {
        NSLog(@"[BionicSX2] SharedMemoryMappingArea::Create vm_allocate(%zu) failed: %x", size, kr);
        return nullptr;
    }

    // Audit Sec 6.3: MAP_JIT not available without entitlement.
    // In Phase 1 of BionicSX2, JIT is disabled (all Recompiler flags = false).
    if (jit) {
        NSLog(@"[BionicSX2] MAP_JIT not available — JIT disabled, interpreter path active");
        // Gracefully skip JIT — log and return non-fatal
    }

    return std::unique_ptr<SharedMemoryMappingArea>(
        new SharedMemoryMappingArea(static_cast<u8*>(reinterpret_cast<void*>(addr)), size, size / __pagesize));
}

u8* SharedMemoryMappingArea::Map(void* file_handle, size_t file_offset, void* map_base, size_t map_size, const PageProtectionMode& mode)
{
    pxAssert(static_cast<u8*>(map_base) >= m_base_ptr &&
             static_cast<u8*>(map_base) < (m_base_ptr + m_size));

    const uint machmode = MachProt(mode);
    kern_return_t kr = vm_protect(mach_task_self(),
        reinterpret_cast<vm_address_t>(map_base), map_size, FALSE, machmode);
    if (kr != KERN_SUCCESS) {
        NSLog(@"[BionicSX2] SharedMemoryMappingArea::Map vm_protect failed: %x", kr);
        return nullptr;
    }

    m_num_mappings++;
    return static_cast<u8*>(map_base);
}

bool SharedMemoryMappingArea::Unmap(void* map_base, size_t map_size, bool is_file)
{
    pxAssert(static_cast<u8*>(map_base) >= m_base_ptr &&
             static_cast<u8*>(map_base) < (m_base_ptr + m_size));

    kern_return_t kr = vm_protect(mach_task_self(),
        reinterpret_cast<vm_address_t>(map_base), map_size, FALSE, VM_PROT_NONE);
    if (kr != KERN_SUCCESS) {
        NSLog(@"[BionicSX2] SharedMemoryMappingArea::Unmap vm_protect failed: %x", kr);
        return false;
    }

    m_num_mappings--;
    return true;
}

#ifdef ARCH_ARM64
void HostSys::FlushInstructionCache(void* address, u32 size)
{
    __builtin___clear_cache(reinterpret_cast<char*>(address),
                            reinterpret_cast<char*>(address) + size);
}
#endif

// Page fault handler uses Mach exception ports (Audit Sec 6.2)
// These are available on iOS and handled in PageFaultHandler.cpp
