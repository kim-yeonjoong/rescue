import Testing
import RescueTestSupport
@testable import RescueCore

@Suite struct PortScannerTests {

    @Test func parsesPortsAndProcesses() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: "p1234\ncnode\nn*:3000\n", stderr: "")
        )
        let scanner = PortScanner(shell: mock)

        // When
        let entries = await scanner.scan()

        // Then
        #expect(entries.count == 1)
        #expect(entries[0].port == 3000)
        #expect(entries[0].pid == 1234)
        #expect(entries[0].processName == "node")
    }

    @Test func emptyOutputReturnsEmptyArray() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: "", stderr: "")
        )
        let scanner = PortScanner(shell: mock)

        // When
        let entries = await scanner.scan()

        // Then
        #expect(entries.isEmpty)
    }

    @Test func parsesIPv6Port() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: "p5678\ncpython\nn[::]:8080\n", stderr: "")
        )
        let scanner = PortScanner(shell: mock)

        // When
        let entries = await scanner.scan()

        // Then
        #expect(entries.count == 1)
        #expect(entries[0].port == 8080)
        #expect(entries[0].pid == 5678)
        #expect(entries[0].processName == "python")
    }

    @Test func multiplePortsPerPID() async {
        // Given
        let mock = MockShellExecutor()
        let output = "p1111\ncruby\nn*:3000\nn*:3001\n"
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: output, stderr: "")
        )
        let scanner = PortScanner(shell: mock)

        // When
        let entries = await scanner.scan()

        // Then
        #expect(entries.count == 2)
        let ports = entries.map(\.port)
        #expect(ports.contains(3000))
        #expect(ports.contains(3001))
    }

    @Test func deduplicatesIPv4AndIPv6() async {
        // Given
        let mock = MockShellExecutor()
        let output = "p9999\ncgo\nn*:4000\nn[::]:4000\n"
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: output, stderr: "")
        )
        let scanner = PortScanner(shell: mock)

        // When
        let entries = await scanner.scan()

        // Then
        #expect(entries.count == 1)
        #expect(entries[0].port == 4000)
        #expect(entries[0].pid == 9999)
    }

    @Test func commandFailureReturnsEmptyArray() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "permission denied")
        )
        let scanner = PortScanner(shell: mock)
        let entries = await scanner.scan()
        #expect(entries.isEmpty)
    }

    @Test func malformedOutputHandledGracefully() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: "garbage\ndata\nhere\n", stderr: "")
        )
        let scanner = PortScanner(shell: mock)
        let entries = await scanner.scan()
        #expect(entries.isEmpty)
    }

    @Test func missingCommandLineSkipsEntry() async {
        // PID without command line, then port
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: "p1234\nn*:3000\n", stderr: "")
        )
        let scanner = PortScanner(shell: mock)
        let entries = await scanner.scan()
        #expect(entries.isEmpty, "Should skip entries without command")
    }

    @Test func invalidPortNumberSkipped() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "lsof -iTCP -sTCP:LISTEN -nP -F pcn",
            result: ShellResult(exitCode: 0, stdout: "p1234\ncnode\nn*:notaport\n", stderr: "")
        )
        let scanner = PortScanner(shell: mock)
        let entries = await scanner.scan()
        #expect(entries.isEmpty)
    }
}
