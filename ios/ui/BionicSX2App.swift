// PORTED FROM: PCSX2 macOS main — BionicSX2 iOS Port
// AUDIT REFERENCE: Section 4.3
// STATUS: NEW — SwiftUI app entry point with UIApplicationDelegate lifecycle

import SwiftUI
import UIKit

// Audit Sec 4.3: SwiftUI/UIKit replaces NSApplicationMain
// Audit Sec 4.3: UIApplication idles timer replaces IOPMAssertion

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Audit Sec 4.3: Prevent screen sleep during emulation (replaces IOPMAssertion)
        application.isIdleTimerDisabled = true
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Pause emulation when app goes to background
        application.isIdleTimerDisabled = false
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        application.isIdleTimerDisabled = true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle ISO file opening from Files app
        NotificationCenter.default.post(name: NSNotification.Name("GameFileOpened"), object: url)
        return true
    }
}

@main
struct BionicSX2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
