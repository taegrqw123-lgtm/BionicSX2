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

#import <UIKit/UIKit.h>      // PORTED: AppKit→UIKit (Audit Sec 4.3)
#import <QuartzCore/QuartzCore.h>

// PORTED: NSView → UIView, NSWindow → UIWindow (Audit Sec 4.3)
// PORTED: AppKit removed, UIKit added (Audit Sec 4.3)

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

    // PORTED: NSView → UIView (Audit Sec 4.3)
    UIView* view = (__bridge UIView*)wi->window_handle;
    [view setWantsLayer:YES];  // UIView supports setWantsLayer on iOS
    [view setLayer:layer];
    [layer setContentsScale:[[UIScreen mainScreen] scale]];  // PORTED: NSWindow screen → UIScreen
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

    // PORTED: NSView → UIView (Audit Sec 4.3)
    UIView* view = (__bridge UIView*)wi->window_handle;
    CAMetalLayer* layer = (__bridge_transfer CAMetalLayer*)wi->surface_handle;
    if (!layer)
        return;
    wi->surface_handle = nullptr;
    [view setLayer:nil];
    [view setWantsLayer:NO];
}

std::optional<float> CocoaTools::GetViewRefreshRate(const WindowInfo& wi)
{
    // PORTED: iOS uses UIScreen maximumFramesPerSecond (Audit Sec 4.3)
    return static_cast<float>([UIScreen mainScreen].maximumFramesPerSecond);
}

// PORTED: NSMenu removed — no equivalent on iOS (Audit Sec 4.3)
void CocoaTools::MarkHelpMenu(void*) {}

// PORTED: NSSound unavailable on iOS, stub (Audit Sec 4.3)
bool Common::PlaySoundAsync(const char*) { return false; }

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
    // PORTED: Translocation does not apply on iOS (Audit Sec 4.3)
    return [[[NSBundle mainBundle] bundlePath] UTF8String];
}

// PORTED: NSTask/Finder not available on iOS — stub (Audit Sec 4.3)
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

// PORTED: CreateWindow now uses UIWindow/UIViewController (Audit Sec 4.3)
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
        // PORTED: NSWindow → UIWindow (Audit Sec 4.3)
        UIWindow* window = (__bridge UIWindow*)cf_window;
        float scale = [window screen].scale;
        UIView* view = [window rootViewController].view;
        CGRect dims = [view frame];
        wi->type = WindowInfo::Type::MacOS;  // Keep MacOS type for compatibility
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

// PORTED: iOS uses UIApplicationMain run loop — no Cocoa event loop needed (Audit Sec 4.3)
void CocoaTools::RunCocoaEventLoop(bool) {}
void CocoaTools::StopMainThreadEventLoop() {}
