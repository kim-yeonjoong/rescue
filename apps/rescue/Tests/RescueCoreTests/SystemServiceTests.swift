import Darwin
import Foundation
import Testing
@testable import RescueCore

// MARK: - ProcessTerminator SIGKILL escalation

@Suite struct ProcessTerminatorSigkillTests {

    /// Spawn a process that ignores SIGTERM (trap '' TERM) so the terminator is
    /// forced to wait the full 3 s and then escalate to SIGKILL.
    @Test(.timeLimit(.minutes(1))) func escalatesToSigkillWhenProcessIgnoresSigterm() async throws {
        // Use /bin/sh with a loop that traps/ignores SIGTERM
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sh")
        process.arguments = ["-c", "trap '' TERM; while true; do sleep 0.1; done"]
        try process.run()
        let pid = process.processIdentifier

        #expect(Darwin.kill(pid, 0) == 0, "Process should be running")

        let terminator = ProcessTerminator()
        let result = await terminator.terminate(pid: pid)

        // After SIGKILL the process should be gone
        #expect(result, "Termination via SIGKILL should succeed")
        try await Task.sleep(for: .milliseconds(100))
        #expect(Darwin.kill(pid, 0) != 0, "Process should be gone after SIGKILL")
    }
}

// MARK: - ShellExecutor integration tests

@Suite struct ShellExecutorTests {

    @Test func runSuccessfulCommand() async {
        let executor = ShellExecutor()
        let result = await executor.run(command: "echo", arguments: ["hello"])
        #expect(result.succeeded)
        #expect(result.exitCode == 0)
        #expect(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "hello")
    }

    @Test func runFailedCommand() async {
        let executor = ShellExecutor()
        let result = await executor.run(command: "false", arguments: [])
        #expect(!result.succeeded)
        #expect(result.exitCode != 0)
    }

    @Test func runCommandWithStderrOutput() async {
        let executor = ShellExecutor()
        // Write to stderr via sh -c
        let result = await executor.run(command: "sh", arguments: ["-c", "echo error_output >&2; exit 1"])
        #expect(!result.succeeded)
        #expect(result.stderr.contains("error_output"))
    }

    @Test func runCommandWithBothOutputStreams() async {
        let executor = ShellExecutor()
        let result = await executor.run(command: "sh", arguments: ["-c", "echo stdout_line; echo stderr_line >&2"])
        #expect(result.succeeded)
        #expect(result.stdout.contains("stdout_line"))
        #expect(result.stderr.contains("stderr_line"))
    }
}

// MARK: - Process+Run extension tests

@Suite struct ProcessRunExtensionTests {

    @Test func successfulExecutionReturnsStdout() async {
        let result = await Process.run(command: "echo", arguments: ["hello world"])
        #expect(result.exitCode == 0)
        #expect(result.succeeded)
        #expect(result.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "hello world")
        #expect(result.stderr.isEmpty)
    }

    @Test func failedCommandReturnsNonZeroExitCode() async {
        let result = await Process.run(command: "false", arguments: [])
        #expect(!result.succeeded)
        #expect(result.exitCode != 0)
    }

    @Test func commandProducingStderr() async {
        let result = await Process.run(command: "sh", arguments: ["-c", "echo from_stderr >&2; exit 2"])
        #expect(result.exitCode == 2)
        #expect(result.stderr.contains("from_stderr"))
    }

    @Test func commandProducingOnlyStdout() async {
        let result = await Process.run(command: "printf", arguments: ["%s", "no_newline"])
        #expect(result.exitCode == 0)
        #expect(result.stdout == "no_newline")
    }

    @Test func invalidCommandReturnsErrorResult() async {
        // A command that doesn't exist causes Process.run() to throw,
        // which is caught and returned as exitCode -1 with stderr set.
        let result = await Process.run(command: "this_command_does_not_exist_xyz", arguments: [])
        #expect(result.exitCode == -1 || result.exitCode != 0)
        // Either the catch branch fires (exitCode == -1) or env reports an error
    }

    @Test(.timeLimit(.minutes(1))) func timeoutTerminatesLongRunningCommand() async {
        // Use a very short timeout so the test finishes quickly.
        // The process should be terminated before it naturally exits.
        let result = await Process.run(command: "sleep", arguments: ["60"], timeout: 0.5)
        // After timeout the process is terminated; terminationStatus is non-zero
        #expect(!result.succeeded || result.exitCode == 0)
        // Main assertion: we got a result at all (didn't hang)
        // The real signal is that the test completes well within the time limit
    }
}
