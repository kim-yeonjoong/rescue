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

private func terminateWithEscalation(_ process: Process) {
    guard process.isRunning else { return }
    process.terminate()
    DispatchQueue.global().asyncAfter(deadline: .now() + sigkillEscalationDelay) {
        if process.isRunning {
            kill(process.processIdentifier, SIGKILL)
        }
    }
}

private func readPipes(
    stdout stdoutPipe: Pipe,
    stderr stderrPipe: Pipe,
    timeout: TimeInterval
) -> (stdout: String, stderr: String) {
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
    let pipeTimedOut = group.wait(timeout: .now() + timeout + 1) == .timedOut
    try? stdoutPipe.fileHandleForReading.close()
    try? stderrPipe.fileHandleForReading.close()
    guard !pipeTimedOut else { return ("", "") }
    let stdout = stdoutLock.withLock { String(data: $0, encoding: .utf8) ?? "" }
    let stderr = stderrLock.withLock { String(data: $0, encoding: .utf8) ?? "" }
    return (stdout, stderr)
}

private func configureProcess(
    _ process: Process,
    command: String,
    arguments: [String],
    stdoutPipe: Pipe,
    stderrPipe: Pipe
) {
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
}

extension Process {
    public static func run(
        command: String,
        arguments: [String],
        timeout: TimeInterval = 10
    ) async -> ShellResult {
        let process = Process()
        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        configureProcess(process, command: command, arguments: arguments,
                         stdoutPipe: stdoutPipe, stderrPipe: stderrPipe)
        return await withTaskCancellationHandler {
            await withCheckedContinuation { continuation in
                DispatchQueue.global().async {
                    do {
                        try process.run()
                        let timeoutWorkItem = DispatchWorkItem {
                            if process.isRunning {
                                RescueLogger.process.warning("Process timed out after \(timeout)s: \(command)")
                                terminateWithEscalation(process)
                            }
                        }
                        DispatchQueue.global().asyncAfter(deadline: .now() + timeout, execute: timeoutWorkItem)
                        let output = readPipes(stdout: stdoutPipe, stderr: stderrPipe, timeout: timeout)
                        process.waitUntilExit()
                        timeoutWorkItem.cancel()
                        continuation.resume(returning: ShellResult(
                            exitCode: process.terminationStatus,
                            stdout: output.stdout, stderr: output.stderr
                        ))
                    } catch {
                        try? stdoutPipe.fileHandleForReading.close()
                        try? stderrPipe.fileHandleForReading.close()
                        continuation.resume(returning: ShellResult(
                            exitCode: -1, stdout: "", stderr: error.localizedDescription
                        ))
                    }
                }
            }
        } onCancel: {
            terminateWithEscalation(process)
        }
    }
}
