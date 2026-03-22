import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_: Notification) {
        // Hide dock icon - menu bar only app
        NSApp.setActivationPolicy(.accessory)
    }
}
