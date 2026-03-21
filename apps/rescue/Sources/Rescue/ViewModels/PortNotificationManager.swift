import Foundation
import RescueCore
import UserNotifications

@MainActor
final class PortNotificationManager {
    var isEnabled: Bool
    private var isFirstScan = true

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    /// 새/제거된 포트를 확인하고 알림을 발송합니다.
    /// 반환값: 제거된 포트 번호 집합 (UptimeTracker 정리에 사용)
    func check(current: [PortEntry], previous: [PortEntry]) -> Set<UInt16> {
        let currentPortSet = Set(current.map(\.port))
        let previousPortSet = Set(previous.map(\.port))
        let newPortSet = currentPortSet.subtracting(previousPortSet)
        let removedPortSet = previousPortSet.subtracting(currentPortSet)

        if !isFirstScan && isEnabled {
            send(entries: current.filter { newPortSet.contains($0.port) })
        }
        isFirstScan = false

        return removedPortSet
    }

    private func send(entries: [PortEntry]) {
        let center = UNUserNotificationCenter.current()
        for entry in entries {
            let content = UNMutableNotificationContent()
            content.title = "New port opened"
            content.body = ":\(entry.port) — \(entry.processName)"
            let request = UNNotificationRequest(
                identifier: "rescue-port-\(entry.port)-\(entry.pid)",
                content: content,
                trigger: nil
            )
            center.add(request) { @Sendable error in
                if let error { RescueLogger.app.error("Failed to post notification: \(error)") }
            }
        }
    }
}
