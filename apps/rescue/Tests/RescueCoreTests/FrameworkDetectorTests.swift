import Testing
@testable import RescueCore

@Suite struct FrameworkDetectorTests {

    @Test func detectsNextjs() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 1234 -o command=",
            result: ShellResult(exitCode: 0, stdout: "/usr/local/bin/node /app/node_modules/.bin/next dev\n", stderr: "")
        )
        let detector = FrameworkDetector(shell: mock)

        // When
        let result = await detector.detect(port: 3000, pid: 1234, processName: "node")

        // Then
        #expect(result == .nextjs)
    }

    @Test func detectsVite() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 5678 -o command=",
            result: ShellResult(exitCode: 0, stdout: "/usr/local/bin/node /app/node_modules/.bin/vite\n", stderr: "")
        )
        let detector = FrameworkDetector(shell: mock)

        // When
        let result = await detector.detect(port: 5173, pid: 5678, processName: "node")

        // Then
        #expect(result == .vite)
    }

    @Test func detectsDjango() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 9999 -o command=",
            result: ShellResult(exitCode: 0, stdout: "/usr/bin/python3 manage.py runserver 0.0.0.0:8000\n", stderr: "")
        )
        let detector = FrameworkDetector(shell: mock)

        // When
        let result = await detector.detect(port: 8000, pid: 9999, processName: "python3")

        // Then
        #expect(result == .django)
    }

    @Test func fallsBackToPortProcessCombo() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 1111 -o command=",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "no such process")
        )
        let detector = FrameworkDetector(shell: mock)

        // When: port 5173 + "node" → .vite via fallback table
        let result = await detector.detect(port: 5173, pid: 1111, processName: "node")

        // Then
        #expect(result == .vite)
    }

    @Test func returnsNilForUnknown() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 2222 -o command=",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "no such process")
        )
        let detector = FrameworkDetector(shell: mock)

        // When: port 9999 + "unknown" has no mapping
        let result = await detector.detect(port: 9999, pid: 2222, processName: "unknown")

        // Then
        #expect(result == nil)
    }

    @Test func emptyCommandOutputFallsToPortBased() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 3333 -o command=",
            result: ShellResult(exitCode: 0, stdout: "\n", stderr: "")
        )
        let detector = FrameworkDetector(shell: mock)
        // port 4200 + node → angular via fallback
        let result = await detector.detect(port: 4200, pid: 3333, processName: "node")
        #expect(result == .angular)
    }

    @Test func doesNotMisdetectContextAsNextjs() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "ps -p 9000 -o command=",
            result: ShellResult(exitCode: 0, stdout: "/usr/bin/node context-manager.js\n", stderr: "")
        )
        let detector = FrameworkDetector(shell: mock)
        let result = await detector.detect(port: 3000, pid: 9000, processName: "node")
        #expect(result == nil)
    }

    @Test func detectsMultipleFrameworks() async {
        let mock = MockShellExecutor()
        // Rails
        await mock.register(
            command: "ps -p 1001 -o command=",
            result: ShellResult(exitCode: 0, stdout: "/usr/bin/ruby bin/rails server\n", stderr: "")
        )
        // Flask
        await mock.register(
            command: "ps -p 1002 -o command=",
            result: ShellResult(exitCode: 0, stdout: "/usr/bin/python3 -m flask run\n", stderr: "")
        )
        // Spring Boot
        await mock.register(
            command: "ps -p 1003 -o command=",
            result: ShellResult(exitCode: 0, stdout: "java -jar app.jar --spring.profiles.active=dev\n", stderr: "")
        )
        let detector = FrameworkDetector(shell: mock)

        let rails = await detector.detect(port: 3000, pid: 1001, processName: "ruby")
        #expect(rails == .rails)

        let flask = await detector.detect(port: 5000, pid: 1002, processName: "python3")
        #expect(flask == .flask)

        let spring = await detector.detect(port: 8080, pid: 1003, processName: "java")
        #expect(spring == .springBoot)
    }
}
