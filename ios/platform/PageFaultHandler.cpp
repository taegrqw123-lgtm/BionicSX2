// PORTED FROM: common/Darwin/DarwinMisc.cpp — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 6.2
// STATUS: YELLOW — Retained: Mach exception handler, sysctl CPU detection
//                    Removed: CoreGraphics, IOKit power management

// Audit Sec 6.2: Mach exception ports for page fault handling are available on iOS.
// Audit Sec 4.3: CoreGraphics removed (CGEventTap, CGWarpCursor not on iOS).
// Audit Sec 4.3: IOKit power management removed (use UIApplication idle timer instead).

#include "PrecompiledHeader.h"
#include "common/Assertions.h"
#include "common/BitUtils.h"
#include "common/Console.h"
#include "common/CrashHandler.h"
#include "common/Darwin/DarwinMisc.h"
#include "common/Error.h"
#include "common/Pcsx2Types.h"
#include "common/Threading.h"
#include "common/WindowInfo.h"
#include "common/HostSys.h"
#include "fmt/format.h"

#include <csignal>
#include <cstring>
#include <cstdlib>
#include <optional>
#include <sys/sysctl.h>
#include <thread>
#include <time.h>
#include <mach/mach_time.h>
#include <mach/message.h>
#include <mach/task.h>
#include <mach/thread_state.h>
#include <mutex>

// ── Memory and CPU info (retained from DarwinMisc.cpp) ──
// These use sysctl which works on iOS ARM64

u64 GetPhysicalMemory()
{
    u64 getmem = 0;
    size_t len = sizeof(getmem);
    int mib[] = {CTL_HW, HW_MEMSIZE};
    if (sysctl(mib, std::size(mib), &getmem, &len, NULL, 0) < 0)
        perror("sysctl:");
    return getmem;
}

u64 GetAvailablePhysicalMemory()
{
    const mach_port_t host_port = mach_host_self();
    vm_size_t page_size;
    if (host_page_size(host_port, &page_size) != KERN_SUCCESS)
        return 0;

    vm_statistics64_data_t vm_stat;
    mach_msg_type_number_t host_size = sizeof(vm_statistics64_data_t) / sizeof(integer_t);
    if (host_statistics64(host_port, HOST_VM_INFO, reinterpret_cast<host_info64_t>(&vm_stat), &host_size) != KERN_SUCCESS)
        return 0;

    const u64 free_pages = static_cast<u64>(vm_stat.free_count);
    const u64 inactive_pages = static_cast<u64>(vm_stat.inactive_count);
    return (free_pages + inactive_pages) * page_size;
}

static mach_timebase_info_data_t s_timebase_info;
static const u64 tickfreq = []() {
    if (mach_timebase_info(&s_timebase_info) != KERN_SUCCESS)
        abort();
    return (u64)1e9 * (u64)s_timebase_info.denom / (u64)s_timebase_info.numer;
}();

u64 GetTickFrequency() { return tickfreq; }
u64 GetCPUTicks() { return mach_absolute_time(); }

static std::string sysctl_str(int category, int name)
{
    char buf[32];
    size_t len = sizeof(buf);
    int mib[] = {category, name};
    sysctl(mib, std::size(mib), buf, &len, nullptr, 0);
    return std::string(buf, len > 0 ? len - 1 : 0);
}

template <typename T>
static std::optional<T> sysctlbyname_T(const char* name)
{
    T output = 0;
    size_t output_size = sizeof(output);
    if (sysctlbyname(name, &output, &output_size, nullptr, 0) != 0)
        return std::nullopt;
    return output;
}

std::string GetOSVersionString()
{
    std::string type = sysctl_str(CTL_KERN, KERN_OSTYPE);
    std::string release = sysctl_str(CTL_KERN, KERN_OSRELEASE);
    std::string arch = sysctl_str(CTL_HW, HW_MACHINE);
    return type + " " + release + " " + arch;
}

// PORTED: IOKit power management removed (Audit Sec 4.3)
// iOS power management handled by UIApplication lifecycle — do not replicate
bool Common::InhibitScreensaver(bool inhibit)
{
    // On iOS, use [UIApplication sharedApplication].idleTimerDisabled = inhibit
    return true;
}

// PORTED: CoreGraphics mouse tracking removed (Audit Sec 4.3)
void Common::SetMousePosition(int, int) {}
bool Common::AttachMousePositionCb(std::function<void(int, int)>) { return false; }
void Common::DetachMousePositionCb() {}

// ── Threading helpers (retained from DarwinMisc.cpp) ──
void Threading::Sleep(int ms) { usleep(1000 * ms); }

void Threading::SleepUntil(u64 ticks)
{
    const s64 diff = static_cast<s64>(ticks - GetCPUTicks());
    if (diff <= 0) return;
    const u64 nanos = (static_cast<u64>(diff) * static_cast<u64>(s_timebase_info.denom)) /
                       static_cast<u64>(s_timebase_info.numer);
    if (nanos == 0) return;
    struct timespec ts;
    ts.tv_sec = nanos / 1000000000ULL;
    ts.tv_nsec = nanos % 1000000000ULL;
    nanosleep(&ts, nullptr);
}

std::vector<DarwinMisc::CPUClass> DarwinMisc::GetCPUClasses()
{
    std::vector<CPUClass> out;
    if (std::optional<u32> nperflevels = sysctlbyname_T<u32>("hw.nperflevels"))
    {
        char name[64];
        for (u32 i = 0; i < *nperflevels; i++)
        {
            snprintf(name, sizeof(name), "hw.perflevel%u.physicalcpu", i);
            std::optional<u32> physicalcpu = sysctlbyname_T<u32>(name);
            snprintf(name, sizeof(name), "hw.perflevel%u.logicalcpu", i);
            std::optional<u32> logicalcpu = sysctlbyname_T<u32>(name);
            char levelname[64];
            size_t levelname_size = sizeof(levelname);
            snprintf(name, sizeof(name), "hw.perflevel%u.name", i);
            if (0 != sysctlbyname(name, levelname, &levelname_size, nullptr, 0))
                strcpy(levelname, "???");
            if (!physicalcpu.has_value() || !logicalcpu.has_value())
                continue;
            out.push_back({levelname, *physicalcpu, *logicalcpu});
        }
    }
    return out;
}

// ── CPU info ──
static CPUInfo CalcCPUInfo()
{
    CPUInfo out;
    char name[256];
    size_t name_size = sizeof(name);
    if (0 != sysctlbyname("machdep.cpu.brand_string", name, &name_size, nullptr, 0))
        strcpy(name, "Apple ARM64");
    out.name = name;
    std::vector<DarwinMisc::CPUClass> classes = DarwinMisc::GetCPUClasses();
    out.num_clusters = static_cast<u32>(classes.size());
    out.num_big_cores = classes.empty() ? 0 : classes[0].num_physical;
    out.num_threads   = classes.empty() ? 0 : classes[0].num_logical;
    out.num_small_cores = 0;
    for (std::size_t i = 1; i < classes.size(); i++)
    {
        out.num_small_cores += classes[i].num_physical;
        out.num_threads += classes[i].num_logical;
    }
    return out;
}

const CPUInfo& GetCPUInfo()
{
    static const CPUInfo info = CalcCPUInfo();
    return info;
}

size_t HostSys::GetRuntimePageSize()
{
    return sysctlbyname_T<u32>("hw.pagesize").value_or(16384);
}

size_t HostSys::GetRuntimeCacheLineSize()
{
    return static_cast<size_t>(std::max<s64>(sysctlbyname_T<s64>("hw.cachelinesize").value_or(128), 0));
}

// ── Mach Exception Port Page Fault Handler ──
// Audit Sec 6.2: Mach exception ports work on iOS

#define USE_MACH_EXCEPTION_PORTS

namespace PageFaultHandler
{
#ifdef USE_MACH_EXCEPTION_PORTS
    static void SignalHandler(mach_port_t port);
    static mach_port_t s_port = 0;
#endif

    static std::recursive_mutex s_exception_handler_mutex;
    static bool s_in_exception_handler = false;
    static bool s_installed = false;
}

#ifdef USE_MACH_EXCEPTION_PORTS

#if defined(ARCH_ARM64)
#define THREAD_STATE64_COUNT ARM_THREAD_STATE64_COUNT
#define THREAD_STATE64 ARM_THREAD_STATE64
#define thread_state64_t arm_thread_state64_t
#else
#error Unknown Darwin Platform
#endif

void PageFaultHandler::SignalHandler(mach_port_t port)
{
    Threading::SetNameOfCurrentThread("Mach Exception Thread");

#pragma pack(4)
    struct
    {
        mach_msg_header_t Head;
        NDR_record_t NDR;
        exception_type_t exception;
        mach_msg_type_number_t codeCnt;
        int64_t code[2];
        int flavor;
        mach_msg_type_number_t old_stateCnt;
        natural_t old_state[THREAD_STATE64_COUNT];
        mach_msg_trailer_t trailer;
    } msg_in;

    struct
    {
        mach_msg_header_t Head;
        NDR_record_t NDR;
        kern_return_t RetCode;
        int flavor;
        mach_msg_type_number_t new_stateCnt;
        natural_t new_state[THREAD_STATE64_COUNT];
    } msg_out;
#pragma pack()

    memset(&msg_in, 0xee, sizeof(msg_in));
    memset(&msg_out, 0xee, sizeof(msg_out));
    mach_msg_size_t send_size = 0;
    mach_msg_option_t option = MACH_RCV_MSG;

    while (true)
    {
        kern_return_t r;
        if ((r = mach_msg_overwrite(&msg_out.Head, option, send_size, sizeof(msg_in), port,
                 MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL, &msg_in.Head, 0)))
        {
            pxFail(fmt::format("CRITICAL: mach_msg_overwrite: {:x}", r).c_str());
        }

        if (msg_in.Head.msgh_id == MACH_NOTIFY_NO_SENDERS)
        {
            mach_port_deallocate(mach_task_self(), port);
            return;
        }

        if (msg_in.Head.msgh_id != 2406)
        {
            pxFailRel("unknown message received");
            return;
        }

        thread_state64_t* state = (thread_state64_t*)msg_in.old_state;

        HandlerResult result = HandlerResult::ExecuteNextHandler;
        if (!s_in_exception_handler)
        {
            s_in_exception_handler = true;
            result = HandlePageFault(
                reinterpret_cast<void*>(state->__pc),
                reinterpret_cast<void*>(msg_in.code[1]),
                (msg_in.code[0] & 2) != 0);
            s_in_exception_handler = false;
        }

        msg_out.Head.msgh_bits = MACH_MSGH_BITS(MACH_MSGH_BITS_REMOTE(msg_in.Head.msgh_bits), 0);
        msg_out.Head.msgh_remote_port = msg_in.Head.msgh_remote_port;
        msg_out.Head.msgh_local_port = MACH_PORT_NULL;
        msg_out.Head.msgh_id = msg_in.Head.msgh_id + 100;
        msg_out.NDR = msg_in.NDR;

        if (result != HandlerResult::ContinueExecution)
        {
            msg_out.RetCode = KERN_FAILURE;
            msg_out.flavor = 0;
            msg_out.new_stateCnt = 0;
        }
        else
        {
            msg_out.RetCode = KERN_SUCCESS;
            msg_out.flavor = THREAD_STATE64;
            msg_out.new_stateCnt = THREAD_STATE64_COUNT;
            memcpy(msg_out.new_state, msg_in.old_state, THREAD_STATE64_COUNT * sizeof(natural_t));
        }

        msg_out.Head.msgh_size =
            offsetof(__typeof__(msg_out), new_state) + msg_out.new_stateCnt * sizeof(natural_t);
        send_size = msg_out.Head.msgh_size;
        option |= MACH_SEND_MSG;
    }
}

bool PageFaultHandler::Install(Error* error)
{
    mach_port_t port;
    kern_return_t r;

    if ((r = mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE, &port)))
    {
        pxFailRel(fmt::format("mach_port_allocate: {:x}", r).c_str());
        return false;
    }

    std::thread sig_thread(PageFaultHandler::SignalHandler, port);
    sig_thread.detach();

    if ((r = mach_port_insert_right(mach_task_self(), port, port, MACH_MSG_TYPE_MAKE_SEND)))
    {
        mach_port_deallocate(mach_task_self(), port);
        return false;
    }

    task_set_exception_ports(mach_task_self(), EXC_MASK_BAD_ACCESS, MACH_PORT_NULL, EXCEPTION_DEFAULT, THREAD_STATE_NONE);

    if ((r = thread_set_exception_ports(mach_thread_self(), EXC_MASK_BAD_ACCESS, port,
             EXCEPTION_STATE | MACH_EXCEPTION_CODES, THREAD_STATE64)))
    {
        mach_port_deallocate(mach_task_self(), port);
        return false;
    }

    mach_port_t previous;
    if ((r = mach_port_request_notification(mach_task_self(), port, MACH_NOTIFY_NO_SENDERS, 0,
             port, MACH_MSG_TYPE_MAKE_SEND_ONCE, &previous)))
    {
        mach_port_deallocate(mach_task_self(), port);
        return false;
    }

    s_installed = true;
    s_port = port;
    return true;
}

bool PageFaultHandler::InstallSecondaryThread()
{
    kern_return_t r = thread_set_exception_ports(mach_thread_self(), EXC_MASK_BAD_ACCESS, s_port,
        EXCEPTION_STATE | MACH_EXCEPTION_CODES, THREAD_STATE64);
    if (r)
    {
        pxFailRel(fmt::format("thread_set_exception_ports(secondary): {:x}", r).c_str());
        return false;
    }
    return true;
}

#endif // USE_MACH_EXCEPTION_PORTS
