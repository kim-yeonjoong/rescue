import Foundation
import RescueCore

@MainActor
final class UptimeTracker {
    private(set) var portStartTimes: [UInt16: Date] = [:]
    private let shell: any ShellExecuting

    private static let processDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEE MMM d HH:mm:ss yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init(shell: any ShellExecuting) {
        self.shell = shell
    }

    func update(for entries: [PortEntry]) async {
        let pids = entries.map { String($0.pid) }.joined(separator: ",")
        guard !pids.isEmpty else { return }
        let psResult = await shell.run(command: "ps", arguments: ["-p", pids, "-o", "pid=,lstart="])
        guard psResult.succeeded || !psResult.stdout.isEmpty else { return }
        let formatter = Self.processDateFormatter
        var pidToStart: [Int32: Date] = [:]
        for line in psResult.stdout.components(separatedBy: "\n") {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, let spaceIdx = trimmed.firstIndex(of: " ") else { continue }
            let pidStr = String(trimmed[trimmed.startIndex..<spaceIdx])
            guard let pid = Int32(pidStr) else { continue }
            let dateStr = String(trimmed[spaceIdx...])
                .components(separatedBy: .whitespaces)
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            if let date = formatter.date(from: dateStr) {
                pidToStart[pid] = date
            }
        }
        for entry in entries {
            if let startDate = pidToStart[entry.pid] {
                portStartTimes[entry.port] = startDate
            }
        }
    }

    func cleanup(removedPorts: Set<UInt16>) {
        for port in removedPorts {
            portStartTimes.removeValue(forKey: port)
        }
    }

    func uptimeString(for port: UInt16) -> String? {
        guard let start = portStartTimes[port] else { return nil }
        let seconds = max(0, Int(-start.timeIntervalSinceNow))
        if seconds < 60 { return "\(seconds)s" }
        if seconds < 3600 { return "\(seconds / 60)m" }
        if seconds < 86400 { return "\(seconds / 3600)h" }
        return "\(seconds / 86400)d"
    }
}
