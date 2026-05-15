// PORTED FROM: common/CocoaTools.mm — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.3, 1.3
// STATUS: YELLOW — NSView→UIView, NSWindow→UIWindow, AppKit→UIKit

#if ! __has_feature(objc_arc)
    #error "Compile this with -fobjc-arc"
#endif

#include "CocoaTools.h"
#include "common/Console.h"
#include "common/HostSys.h"
#include "common/WindowInfo.h"

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

static NSString* NSStringFromStringView(std::string_view sv)
{
    return [[NSString alloc] initWithBytes:sv.data() length:sv.size() encoding:NSUTF8StringEncoding];
}

bool CocoaTools::CreateMetalLayer(WindowInfo* wi)
{
    if (![NSThread isMainThread])
    {
        bool ret;
        dispatch_sync(dispatch_get_main_queue(), [&ret, wi]{ ret = CreateMetalLayer(wi); });
        return ret;
    }

    CAMetalLayer* layer = [CAMetalLayer layer];
    if (!layer)
    {
        Console.Error("Failed to create Metal layer.");
        return false;
    }

    // PORTED: On iOS, CAMetalLayer is set via UIView.layerClass override
    // The UIView's layer is already CAMetalLayer (set in MetalViewController)
    UIView* view = (__bridge UIView*)wi->window_handle;
    [layer setContentsScale:[[UIScreen mainScreen] scale]];
    wi->surface_handle = (__bridge_retained void*)layer;
    return true;
}

void CocoaTools::DestroyMetalLayer(WindowInfo* wi)
{
    if (![NSThread isMainThread])
    {
        dispatch_sync_f(dispatch_get_main_queue(), wi, [](void* ctx){ DestroyMetalLayer(static_cast<WindowInfo*>(ctx)); });
        return;
    }

    CAMetalLayer* layer = (__bridge_transfer CAMetalLayer*)wi->surface_handle;
    if (!layer)
        return;
    wi->surface_handle = nullptr;
}

std::optional<float> CocoaTools::GetViewRefreshRate(const WindowInfo& wi)
{
    return static_cast<float>([UIScreen mainScreen].maximumFramesPerSecond);
}

void CocoaTools::MarkHelpMenu(void*) {}

// PORTED: Stub — NSSound not available on iOS
namespace Common {
    bool PlaySoundAsync(const char*) { return false; }
}

std::optional<std::string> CocoaTools::GetBundlePath()
{
    std::optional<std::string> ret;
    @autoreleasepool {
        NSURL* url = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        if (url)
            ret = std::string([url fileSystemRepresentation]);
    }
    return ret;
}

std::optional<std::string> CocoaTools::GetNonTranslocatedBundlePath()
{
    return [[[NSBundle mainBundle] bundlePath] UTF8String];
}

bool CocoaTools::MoveToTrash(std::string_view) { return false; }
bool CocoaTools::DelayedLaunch(std::string_view) { return false; }
bool CocoaTools::ShowInFinder(std::string_view) { return false; }

std::optional<std::string> CocoaTools::GetResourcePath()
{ @autoreleasepool {
    if (NSBundle* bundle = [NSBundle mainBundle])
    {
        NSString* rsrc = [bundle resourcePath];
        NSString* root = [bundle bundlePath];
        if ([rsrc isEqualToString:root])
            rsrc = [rsrc stringByAppendingString:@"/resources"];
        return [rsrc UTF8String];
    }
    return std::nullopt;
}}

void* CocoaTools::CreateWindow(std::string_view title, u32 width, u32 height)
{
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController* vc = [[UIViewController alloc] init];
    window.rootViewController = vc;
    [window makeKeyAndVisible];
    return (__bridge_retained void*)window;
}

void CocoaTools::DestroyWindow(void* window)
{
    (void)(__bridge_transfer UIWindow*)window;
}

void CocoaTools::GetWindowInfoFromWindow(WindowInfo* wi, void* cf_window)
{
    if (cf_window)
    {
        UIWindow* window = (__bridge UIWindow*)cf_window;
        float scale = [window screen].scale;
        UIView* view = [window rootViewController].view;
        CGRect dims = [view frame];
        wi->type = WindowInfo::Type::MacOS;
        wi->window_handle = (__bridge void*)view;
        wi->surface_width = dims.size.width * scale;
        wi->surface_height = dims.size.height * scale;
        wi->surface_scale = scale;
    }
    else
    {
        wi->type = WindowInfo::Type::Surfaceless;
    }
}

void CocoaTools::RunCocoaEventLoop(bool) {}
void CocoaTools::StopMainThreadEventLoop() {}
