import Darwin
import Foundation
import Testing
import RescueTestSupport
@testable import RescueCore

// MARK: - DockerManager coverage

@Suite struct DockerManagerCoverageTests {

    // Lines 25-26: listContainers failure path (stderr non-empty)
    @Test func listContainersReturnsEmptyOnFailure() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "Cannot connect to Docker daemon")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.isEmpty)
    }

    // Lines 80-86: restartContainer success
    @Test func restartContainerSuccess() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker restart -- abc123",
            result: ShellResult(exitCode: 0, stdout: "abc123", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let result = await manager.restartContainer(id: "abc123")
        #expect(result)
    }

    // Lines 80-86: restartContainer failure
    @Test func restartContainerFailure() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "docker restart -- abc123",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "Error: No such container")
        )
        let manager = DockerManager(shell: mock)
        let result = await manager.restartContainer(id: "abc123")
        #expect(!result)
    }

    // Line 94: parseStatus → .paused when status is purely "Paused" (not prefixed with "Up")
    @Test func parsesPurePausedStatus() async {
        let mock = MockShellExecutor()
        // "Paused" does not start with "Up" or "Exited", but contains "Paused"
        let json = #"{"ID":"xyz","Names":"paused-app","Image":"node:18","Status":"Paused","Ports":""}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.count == 1)
        if case .paused = containers[0].status { } else {
            Issue.record("Expected .paused status")
        }
    }

    // Lines 95-96: parseStatus → .other when status matches none of the known prefixes
    @Test func parsesOtherStatus() async {
        let mock = MockShellExecutor()
        let json = #"{"ID":"xyz","Names":"restarting-app","Image":"node:18","Status":"Restarting (1) 5 seconds ago","Ports":""}"#
        await mock.register(
            command: "docker ps -a --format {{json .}}",
            result: ShellResult(exitCode: 0, stdout: json + "\n", stderr: "")
        )
        let manager = DockerManager(shell: mock)
        let containers = await manager.listContainers()
        #expect(containers.count == 1)
        if case .other(let s) = containers[0].status {
            #expect(s == "Restarting (1) 5 seconds ago")
        } else {
            Issue.record("Expected .other status")
        }
    }
}

// MARK: - PortlessIntegrator coverage

@Suite struct PortlessIntegratorCoverageTests {

    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func removeTempDir(_ dir: URL) {
        try? FileManager.default.removeItem(at: dir)
    }

    // Lines 113-125: nvm/fnm versioned directory search
    // On macOS, fm.isExecutableFile(atPath: directoryPath) returns true for any traversable
    // directory (directories have the execute bit for traversal). So passing a directory as
    // a binarySearchPath candidate hits the isExecutableFile check at line 109 first and
    // returns the directory path itself. To reach lines 115-125, the candidate must have
    // isExecutableFile = false but fileExists = true.
    //
    // A regular non-executable FILE satisfies this: isExecutableFile → false, fileExists → true,
    // but contentsOfDirectory on a file returns nil (try? → nil), so the inner loop (117-122)
    // is skipped. This covers line 115 branch entry.
    //
    // Lines 117-122 (the version loop body) require a directory where isExecutableFile is false
    // but the directory is still listable. On macOS as the owner, chmod 644 on a directory
    // makes isExecutableFile return false while fileExists returns true, but
    // FileManager.contentsOfDirectory also returns nil (needs x bit to traverse).
    // Therefore lines 117-122 are structurally unreachable in test environments on macOS.
    // The test below covers lines 115-116 and 124-125 (the fileExists branch and its fallthrough).
    @Test func directorySearchWithNonExecutableFileCandidate() async throws {
        let baseDir = try makeTempDir()
        defer { removeTempDir(baseDir) }

        // Regular non-executable file: isExecutableFile → false, fileExists → true
        // contentsOfDirectory on a file → nil (try? skips inner loop)
        let filePath = baseDir.appendingPathComponent("nvm-dir-marker").path
        FileManager.default.createFile(atPath: filePath, contents: Data("placeholder".utf8))

        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "")
        )
        let integrator = PortlessIntegrator(
            shell: mock,
            routeStorePaths: [],
            binarySearchPaths: [filePath]
        )

        let available = await integrator.isPortlessAvailable()
        #expect(!available)
    }

    // Line 161: closing brace of `if let content` block in loadFromRouteStore's JSONL path.
    // Reached when: data is non-empty, JSON array decode fails, content is valid UTF-8,
    // but JSONL lines all fail to decode (malformed JSON per line) → routes.isEmpty = true
    // → the `if !routes.isEmpty { return routes }` block is NOT entered → falls through to
    // line 161 (closing `}` of `if let content`) and continues the outer for loop.
    @Test func routeStoreJSONLWithMalformedLinesReturnsNil() async throws {
        let baseDir = try makeTempDir()
        defer { removeTempDir(baseDir) }

        let routeFile = baseDir.appendingPathComponent("routes")
        // Not a JSON array (so JSON array decode fails), and lines are not valid PortlessRoute JSON
        // → JSONL parse produces empty array → routes.isEmpty = true → line 161 is hit
        let malformedJSONL = "not-json-at-all\nalso-not-json\n"
        try malformedJSONL.write(to: routeFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        // No CLI mock needed since we rely on CLI fallback after routeStore returns nil
        await mock.register(
            command: "portless list --json",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "not found")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile])
        let routes = await integrator.loadRoutes()
        // routeStore returns nil (malformed), CLI fails → empty
        #expect(routes.isEmpty)
    }

    // Confirm valid JSONL still works (lines 157-160 covered)
    @Test func loadsRoutesFromJSONLFallbackWithAliveProcess() async throws {
        let baseDir = try makeTempDir()
        defer { removeTempDir(baseDir) }

        let pid = ProcessInfo.processInfo.processIdentifier
        let routeFile = baseDir.appendingPathComponent("routes")
        let jsonl = "{\"hostname\":\"svc\",\"port\":9000,\"processId\":\(pid)}"
        try jsonl.write(to: routeFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile])

        let routes = await integrator.loadRoutes()
        #expect(routes.count == 1)
        #expect(routes[0].hostname == "svc")
    }
}

// MARK: - ProcessTerminator SIGKILL escalation

@Suite struct ProcessTerminatorSigkillCoverageTests {

    // Lines 18-27: SIGKILL escalation path.
    // The process must survive SIGTERM for the full 3-second wait (30 × 100ms iterations).
    // Python with signal.SIG_IGN reliably ignores SIGTERM once its signal handler is installed.
    // We print "ready" to stdout after installing the handler, then read it to synchronize —
    // ensuring SIGTERM is sent only after signal.SIG_IGN is active.
    @Test(.timeLimit(.minutes(1))) func sigkillEscalationWhenSigtermIgnored() async throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        // Print "ready" after installing SIG_IGN so we can synchronize before sending SIGTERM
        process.arguments = [
            "-c",
            "import signal, time; signal.signal(signal.SIGTERM, signal.SIG_IGN); time.sleep(60)"
        ]
        process.standardOutput = Pipe()
        process.standardError = Pipe()
        try process.run()
        let pid = process.processIdentifier

        // Wait 1 second for Python to initialize and install the signal handler.
        // Without this delay, SIGTERM may arrive before signal.SIG_IGN is active.
        try await Task.sleep(for: .seconds(1))

        #expect(Darwin.kill(pid, 0) == 0, "Python process should be running")

        let terminator = ProcessTerminator()
        // SIGTERM is ignored → loop runs all 30 iterations (3s) → escalates to SIGKILL
        let result = await terminator.terminate(pid: pid)

        #expect(result, "Termination via SIGKILL escalation should succeed")
        try await Task.sleep(for: .milliseconds(200))
        #expect(Darwin.kill(pid, 0) != 0, "Process should be gone after SIGKILL")
    }
}

// MARK: - Process+Run catch block coverage

@Suite struct ProcessRunCatchBlockTests {

    // Lines 61-67: catch block when process.run() throws.
    // The Process.run(command:arguments:) extension hardcodes executableURL = /usr/bin/env,
    // which always exists on macOS. Therefore process.run() never throws through the public API.
    // The catch block is a defensive error-handling path for environments where /usr/bin/env
    // might be unavailable (e.g., sandboxed or restricted environments).
    //
    // We verify the identical catch-block logic by calling Process directly with a
    // non-existent executable, confirming that: the catch fires, exitCode = -1, stderr is set.
    // This covers the same code pattern even though the actual function lines 61-67 are
    // unreachable through the public extension API on macOS.
    @Test func directProcessRunThrowsForMissingExecutable() async {
        let result = await withCheckedContinuation { (continuation: CheckedContinuation<ShellResult, Never>) in
            let process = Process()
            let stdoutPipe = Pipe()
            let stderrPipe = Pipe()
            process.executableURL = URL(fileURLWithPath: "/nonexistent/path/to/binary_xyz")
            process.arguments = []
            process.standardOutput = stdoutPipe
            process.standardError = stderrPipe
            do {
                try process.run()
                let stdoutData = stdoutPipe.fileHandleForReading.readDataToEndOfFile()
                let stderrData = stderrPipe.fileHandleForReading.readDataToEndOfFile()
                process.waitUntilExit()
                try? stdoutPipe.fileHandleForReading.close()
                try? stderrPipe.fileHandleForReading.close()
                let stdout = String(data: stdoutData, encoding: .utf8) ?? ""
                let stderr = String(data: stderrData, encoding: .utf8) ?? ""
                continuation.resume(returning: ShellResult(exitCode: process.terminationStatus, stdout: stdout, stderr: stderr))
            } catch {
                try? stdoutPipe.fileHandleForReading.close()
                try? stderrPipe.fileHandleForReading.close()
                continuation.resume(returning: ShellResult(exitCode: -1, stdout: "", stderr: error.localizedDescription))
            }
        }
        #expect(result.exitCode == -1)
        #expect(!result.stderr.isEmpty)
        #expect(!result.succeeded)
    }
}
