import Testing
import Foundation
import RescueTestSupport
@testable import Rescue
@testable import RescueCore

// MARK: - UptimeTracker Tests

@Suite @MainActor
struct UptimeTrackerTests {

    private func makeTracker() -> (UptimeTracker, MockShellExecutor) {
        let mock = MockShellExecutor()
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
