import AppKit
import RescueCore
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {

    func applicationDidFinishLaunching(_: Notification) {
        // Hide dock icon - menu bar only app
        NSApp.setActivationPolicy(.accessory)
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error { RescueLogger.app.error("Notification authorization failed: \(error)") }
        }
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// 알림 탭 → 메뉴바 팝업 열기
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive _: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.windows
            .first(where: \.title.isEmpty)?
            .makeKeyAndOrderFront(nil)
        completionHandler()
    }

    /// 앱 활성 상태에서도 배너 표시
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}
