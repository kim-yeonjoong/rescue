import Testing
import Foundation
@testable import Rescue
@testable import RescueCore

// MARK: - PortNotificationManager Tests

@Suite @MainActor
struct PortNotificationManagerTests {

    // Test 1: isFirstScan=true일 때 removedPortSet만 반환 (알림 미발송 검증은 불가하나 반환값 검증)
    @Test func firstScan_noNotificationSent_removedPortSetReturned() {
        let manager = PortNotificationManager(isEnabled: true)
        let current = [PortEntry(port: 3000, pid: 1, processName: "node")]
        let previous: [PortEntry] = []

        let removed = manager.check(current: current, previous: previous)

        // 첫 스캔에서 previous가 비어있으면 removedPortSet도 비어있어야 함
        #expect(removed.isEmpty)
    }

    // Test 2: 두 번째 호출에서 새 포트 감지 — check()의 반환값(removedPortSet) 검증
    // isEnabled=false로 UNUserNotificationCenter 호출을 피함 (테스트 환경에서 크래시)
    @Test func secondScan_detectsNewPort_removedPortSetEmpty() {
        let manager = PortNotificationManager(isEnabled: false)
        let first = [PortEntry(port: 3000, pid: 1, processName: "node")]

        // 첫 번째 호출 (isFirstScan = true)
        _ = manager.check(current: first, previous: [])

        // 두 번째 호출: previous=first, current=first+새포트
        let second = first + [PortEntry(port: 8080, pid: 2, processName: "python")]
        let removed = manager.check(current: second, previous: first)

        // 제거된 포트 없으므로 removedPortSet은 비어야 함
        #expect(removed.isEmpty)
    }

    // Test 3: 제거된 포트가 removedPortSet에 포함됨
    // isEnabled=false로 UNUserNotificationCenter 호출을 피함
    @Test func check_removedPort_includedInReturnValue() {
        let manager = PortNotificationManager(isEnabled: false)
        let initial = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 8080, pid: 2, processName: "python"),
        ]

        // 첫 번째 호출
        _ = manager.check(current: initial, previous: [])

        // 두 번째 호출: 8080 제거
        let updated = [PortEntry(port: 3000, pid: 1, processName: "node")]
        let removed = manager.check(current: updated, previous: initial)

        #expect(removed == Set<UInt16>([8080]))
    }

    // Test 4: isEnabled=false일 때도 removedPortSet은 정상 반환
    @Test func check_isEnabledFalse_stillReturnsRemovedPortSet() {
        let manager = PortNotificationManager(isEnabled: false)
        let initial = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 5432, pid: 3, processName: "postgres"),
        ]

        // 첫 번째 호출
        _ = manager.check(current: initial, previous: [])

        // 두 번째 호출: 5432 제거
        let updated = [PortEntry(port: 3000, pid: 1, processName: "node")]
        let removed = manager.check(current: updated, previous: initial)

        #expect(removed == Set<UInt16>([5432]))
    }
}

// MARK: - UptimeTracker Tests

@Suite @MainActor
struct UptimeTrackerTests {

    private func makeTracker() -> (UptimeTracker, MockShellExecutorForRescueTests) {
        let mock = MockShellExecutorForRescueTests()
        let tracker = UptimeTracker(shell: mock)
        return (tracker, mock)
    }

    private func makeFormatter() -> DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "EEE MMM d HH:mm:ss yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }

    private func psOutput(pid: Int32, dateStr: String) -> String {
        "\(pid)  \(dateStr)\n"
    }

    // Test 1: 60초 미만은 "Xs" 형식
    @Test func uptimeString_lessThan60Seconds_returnsSecondsFormat() async {
        let (tracker, mock) = makeTracker()
        let entry = PortEntry(port: 3000, pid: 100, processName: "node")

        // 30초 전 시작
        let startDate = Date().addingTimeInterval(-30)
        let formatter = makeFormatter()
        let dateStr = formatter.string(from: startDate)

        await mock.register(
            command: "ps -p 100 -o pid=,lstart=",
            result: ShellResult(exitCode: 0, stdout: psOutput(pid: 100, dateStr: dateStr), stderr: "")
        )

        await tracker.update(for: [entry])

        let result = tracker.uptimeString(for: 3000)
        #expect(result != nil)
        #expect(result?.hasSuffix("s") == true)
        // 분/시/일 형식이 아닌지 확인
        #expect(result?.hasSuffix("m") == false)
        #expect(result?.hasSuffix("h") == false)
        #expect(result?.hasSuffix("d") == false)
    }

    // Test 2: 60초~3600초는 "Xm" 형식
    @Test func uptimeString_between60And3600Seconds_returnsMinutesFormat() async {
        let (tracker, mock) = makeTracker()
        let entry = PortEntry(port: 3001, pid: 101, processName: "node")

        // 5분 전 시작
        let startDate = Date().addingTimeInterval(-300)
        let formatter = makeFormatter()
        let dateStr = formatter.string(from: startDate)

        await mock.register(
            command: "ps -p 101 -o pid=,lstart=",
            result: ShellResult(exitCode: 0, stdout: psOutput(pid: 101, dateStr: dateStr), stderr: "")
        )

        await tracker.update(for: [entry])

        let result = tracker.uptimeString(for: 3001)
        #expect(result?.hasSuffix("m") == true)
    }

    // Test 3: 3600초~86400초는 "Xh" 형식
    @Test func uptimeString_between3600And86400Seconds_returnsHoursFormat() async {
        let (tracker, mock) = makeTracker()
        let entry = PortEntry(port: 3002, pid: 102, processName: "node")

        // 2시간 전 시작
        let startDate = Date().addingTimeInterval(-7200)
        let formatter = makeFormatter()
        let dateStr = formatter.string(from: startDate)

        await mock.register(
            command: "ps -p 102 -o pid=,lstart=",
            result: ShellResult(exitCode: 0, stdout: psOutput(pid: 102, dateStr: dateStr), stderr: "")
        )

        await tracker.update(for: [entry])

        let result = tracker.uptimeString(for: 3002)
        #expect(result?.hasSuffix("h") == true)
    }

    // Test 4: 86400초 이상은 "Xd" 형식
    @Test func uptimeString_moreThan86400Seconds_returnsDaysFormat() async {
        let (tracker, mock) = makeTracker()
        let entry = PortEntry(port: 3003, pid: 103, processName: "node")

        // 3일 전 시작
        let startDate = Date().addingTimeInterval(-259200)
        let formatter = makeFormatter()
        let dateStr = formatter.string(from: startDate)

        await mock.register(
            command: "ps -p 103 -o pid=,lstart=",
            result: ShellResult(exitCode: 0, stdout: psOutput(pid: 103, dateStr: dateStr), stderr: "")
        )

        await tracker.update(for: [entry])

        let result = tracker.uptimeString(for: 3003)
        #expect(result?.hasSuffix("d") == true)
    }

    // Test 5: cleanup(removedPorts:)가 해당 포트의 start time 제거
    @Test func cleanup_removesStartTimeForPort() async {
        let (tracker, mock) = makeTracker()
        let entry = PortEntry(port: 4000, pid: 200, processName: "ruby")

        let startDate = Date().addingTimeInterval(-120)
        let formatter = makeFormatter()
        let dateStr = formatter.string(from: startDate)

        await mock.register(
            command: "ps -p 200 -o pid=,lstart=",
            result: ShellResult(exitCode: 0, stdout: psOutput(pid: 200, dateStr: dateStr), stderr: "")
        )

        await tracker.update(for: [entry])

        // 등록되었는지 확인
        #expect(tracker.uptimeString(for: 4000) != nil)

        // cleanup 후 제거되었는지 확인
        tracker.cleanup(removedPorts: [4000])
        #expect(tracker.uptimeString(for: 4000) == nil)
    }

    // Test 6: 알려지지 않은 포트는 uptimeString이 nil 반환
    @Test func uptimeString_unknownPort_returnsNil() {
        let (tracker, _) = makeTracker()
        #expect(tracker.uptimeString(for: 9999) == nil)
    }

    // Test 7: update(for:) - MockShellExecutor로 ps 출력 모킹하여 파싱 검증
    @Test func update_parsesPsOutput_storesStartTime() async {
        let (tracker, mock) = makeTracker()
        let entry = PortEntry(port: 5000, pid: 12345, processName: "go")

        // "Fri Mar 21 10:00:00 2026" 형식 고정 날짜 주입
        let dateStr = "Fri Mar 21 10:00:00 2026"
        await mock.register(
            command: "ps -p 12345 -o pid=,lstart=",
            result: ShellResult(exitCode: 0, stdout: psOutput(pid: 12345, dateStr: dateStr), stderr: "")
        )

        await tracker.update(for: [entry])

        // 파싱 성공 시 portStartTimes에 저장되어 uptimeString이 nil이 아님
        #expect(tracker.uptimeString(for: 5000) != nil)
        // portStartTimes에 저장된 날짜가 예상값과 일치하는지 확인
        #expect(tracker.portStartTimes[5000] != nil)
        let expectedDate = makeFormatter().date(from: dateStr)
        #expect(tracker.portStartTimes[5000] == expectedDate)
    }
}
