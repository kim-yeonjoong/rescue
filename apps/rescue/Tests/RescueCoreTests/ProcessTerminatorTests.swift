import Darwin
import Foundation
import Testing
@testable import RescueCore

@Suite struct ProcessTerminatorTests {

    @Test func terminatesRunningProcess() async throws {
        // Spawn a sleep process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process.arguments = ["60"]
        try process.run()
        let pid = process.processIdentifier

        // Verify it's running
        #expect(Darwin.kill(pid, 0) == 0, "Process should be running")

        let terminator = ProcessTerminator()
        let result = await terminator.terminate(pid: pid)

        #expect(result, "Termination should succeed")
        // Give a moment for cleanup
        try await Task.sleep(for: .milliseconds(100))
        #expect(Darwin.kill(pid, 0) != 0, "Process should be gone")
    }

    @Test func returnsFalseForNonexistentProcess() async {
        let terminator = ProcessTerminator()
        // Use a PID that almost certainly doesn't exist
        let result = await terminator.terminate(pid: 99999)
        #expect(!result, "Should fail for nonexistent process")
    }

    @Test func terminatesMultipleProcesses() async throws {
        // Spawn two sleep processes
        let process1 = Process()
        process1.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process1.arguments = ["60"]
        try process1.run()

        let process2 = Process()
        process2.executableURL = URL(fileURLWithPath: "/bin/sleep")
        process2.arguments = ["60"]
        try process2.run()

        let terminator = ProcessTerminator()

        let result1 = await terminator.terminate(pid: process1.processIdentifier)
        let result2 = await terminator.terminate(pid: process2.processIdentifier)

        #expect(result1)
        #expect(result2)
    }
}
