import Foundation
import os

public struct ShellResult: Sendable {
    public let exitCode: Int32
    public let stdout: String
    public let stderr: String
    public var succeeded: Bool { exitCode == 0 }

    public init(exitCode: Int32, stdout: String, stderr: String) {
        self.exitCode = exitCode
        self.stdout = stdout
        self.stderr = stderr
    }
}

private let sigkillEscalationDelay: TimeInterval = 0.2

extension Process {
    public static func run(command: String, arguments: [String], timeout: TimeInterval = 10) async -> ShellResult {
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()

        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = [command] + arguments
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        // macOS GUI apps have a minimal PATH (/usr/bin:/bin:/usr/sbin:/sbin).
        // Extend it so tools like `docker` and `lsof` installed in common locations are found.
        var env = ProcessInfo.processInfo.environment
        let extra = "/usr/local/bin:/opt/homebrew/bin"
        if let existing = env["PATH"], !existing.isEmpty {
            env["PATH"] = "\(extra):\(existing)"
        } else {
            env["PATH"] = "\(extra):/usr/bin:/bin:/usr/sbin:/sbin"
        }
        process.environment = env

        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                DispatchQueue.global().async {
                    do {
                        try process.run()

                        let timeoutWorkItem = DispatchWorkItem {
                            if process.isRunning {
                                RescueLogger.process.warning("Process timed out after \(timeout)s: \(command)")
                                process.terminate()
                                // Escalate to SIGKILL if process ignores SIGTERM
                                DispatchQueue.global().asyncAfter(deadline: .now() + sigkillEscalationDelay) {
                                    if process.isRunning {
                                        kill(process.processIdentifier, SIGKILL)
                                    }
                                }
                            }
                        }
                        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem)

                        // Read stdout and stderr concurrently to prevent pipe buffer deadlock
                        let stdoutLock = OSAllocatedUnfairLock(initialState: Data())
                        let stderrLock = OSAllocatedUnfairLock(initialState: Data())
                        let group = DispatchGroup()
                        group.enter()
                        DispatchQueue.global().async {
                            let data = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                            stdoutLock.withLock { $0 = data }
                            group.leave()
                        }
                        group.enter()
                        DispatchQueue.global().async {
                            let data = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                            stderrLock.withLock { $0 = data }
                            group.leave()
                        }
                        // Use a bounded wait to prevent deadlock when child processes inherit pipe FDs
                        let pipeTimeout = DispatchTime.now() + timeout + 1
                        let pipeTimedOut = group.wait(timeout: pipeTimeout) == .timedOut
                        if pipeTimedOut {
                            try? stdoutPipe.fileHandleForReading.close()
                            try? stderrPipe.fileHandleForReading.close()
                        }
                        process.waitUntilExit()
                        timeoutWorkItem.cancel()

                        if !pipeTimedOut {
                            try? stdoutPipe.fileHandleForReading.close()
                            try? stderrPipe.fileHandleForReading.close()
                        }

                        // Avoid reading lock when pipe timed out to prevent data race
                        let stdout: String
                        let stderr: String
                        if pipeTimedOut {
                            stdout = ""
                            stderr = ""
                        } else {
                            stdout = stdoutLock.withLock { String(data: $0, encoding: .utf8) ?? "" }
                            stderr = stderrLock.withLock { String(data: $0, encoding: .utf8) ?? "" }
                        }

                        continuation.resume(returning: ShellResult(
                            exitCode: process.terminationStatus,
                            stdout: stdout,
                            stderr: stderr
                        ))
                    } catch {
                        try? stdoutPipe.fileHandleForReading.close()
                        try? stderrPipe.fileHandleForReading.close()
                        continuation.resume(returning: ShellResult(
                            exitCode: -1,
                            stdout: "",
                            stderr: error.localizedDescription
                        ))
                    }
                }
            }
        } onCancel: {
            guard process.isRunning else { return }
            process.terminate()
            // Escalate to SIGKILL if process ignores SIGTERM
            DispatchQueue.global().asyncAfter(deadline: .now() + sigkillEscalationDelay) {
                if process.isRunning {
                    kill(process.processIdentifier, SIGKILL)
                }
            }
        }
    }
}
