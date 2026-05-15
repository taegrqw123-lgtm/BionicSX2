// BionicSX2 iOS App Entry Point
// AUDIT REFERENCE: Section 4.3
// STATUS: NEW — UIKit main entry point replacing SwiftUI for initial build

#import <UIKit/UIKit.h>
#import "MetalViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    MetalViewController *vc = [[MetalViewController alloc] init];
    self.window.rootViewController = vc;
    [self.window makeKeyAndVisible];
    application.idleTimerDisabled = YES;
    return YES;
}

@end

int main(int argc, char *argv[]) {
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
