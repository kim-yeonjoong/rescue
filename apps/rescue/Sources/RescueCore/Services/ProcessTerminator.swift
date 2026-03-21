import Darwin
import os

private let sigtermCheckCount = 30
private let sigtermCheckInterval: Duration = .milliseconds(100)
private let postSigkillDelay: Duration = .milliseconds(200)

public actor ProcessTerminator {
    public init() {}

    public func terminate(pid: Int32) async -> Bool {
        // Send SIGTERM
        guard Darwin.kill(pid, SIGTERM) == 0 else {
            RescueLogger.terminator.error("SIGTERM failed for pid \(pid)")
            return false
        }

        // Wait for process to exit (sigtermCheckCount * sigtermCheckInterval)
        for _ in 0..<sigtermCheckCount {
            try? await Task.sleep(for: sigtermCheckInterval)
            if Darwin.kill(pid, 0) != 0 { return true }  // Process exited
        }

        // Escalate to SIGKILL
        RescueLogger.terminator.warning("Escalating to SIGKILL for pid \(pid)")
        let killResult = Darwin.kill(pid, SIGKILL)
        if killResult != 0 {
            RescueLogger.terminator.error("SIGKILL failed for pid \(pid)")
        }
        try? await Task.sleep(for: postSigkillDelay)
        return Darwin.kill(pid, 0) != 0
    }
}
