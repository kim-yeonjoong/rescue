import Foundation
import Testing
@testable import RescueCore

@Suite struct PortlessIntegratorTests {

    // MARK: - Helpers

    private func makeTempDir() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private func removeTempDir(_ dir: URL) {
        try? FileManager.default.removeItem(at: dir)
    }

    private var currentPID: Int32 { ProcessInfo.processInfo.processIdentifier }

    // MARK: - isPortlessAvailable

    @Test func portlessNotAvailable() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "portless not found")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [], binarySearchPaths: [])

        // When
        let available = await integrator.isPortlessAvailable()

        // Then
        #expect(!available)
    }

    @Test func loadsRoutesFromCLI() async {
        // Given: RouteStore files don't exist, but CLI works
        let mock = MockShellExecutor()
        let json = #"[{"hostname":"myapp","port":4532,"processId":99999}]"#
        await mock.register(
            command: "portless list --json",
            result: ShellResult(exitCode: 0, stdout: json, stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [])

        // When
        let routes = await integrator.loadRoutes()

        // Then - process 99999 will not exist in test environment
        #expect(routes.isEmpty)
    }

    @Test func enrichesEntries() async {
        // Given
        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock)
        let entries = [
            PortEntry(port: 3000, pid: 100, processName: "node"),
            PortEntry(port: 8000, pid: 200, processName: "python"),
        ]
        let routes = [
            PortlessRoute(hostname: "myapp", port: 3000, processId: 100),
        ]

        // When
        let enriched = integrator.enrichEntries(entries, with: routes)

        // Then
        #expect(enriched[0].portlessURL == "http://myapp.localhost")
        #expect(enriched[1].portlessURL == nil)
    }

    @Test func gracefulWhenNotInstalled() async {
        // Given
        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "")
        )
        await mock.register(
            command: "portless list --json",
            result: ShellResult(exitCode: 127, stdout: "", stderr: "command not found")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [])

        // When
        let routes = await integrator.loadRoutes()

        // Then
        #expect(routes.isEmpty)
    }

    @Test func loadRoutesWithMalformedJSON() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "portless list --json",
            result: ShellResult(exitCode: 0, stdout: "not valid json", stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [])
        let routes = await integrator.loadRoutes()
        #expect(routes.isEmpty)
    }

    @Test func registerAliasFailure() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "portless alias myapp 3000",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "alias already exists")
        )
        let integrator = PortlessIntegrator(shell: mock)
        let result = await integrator.registerAlias(name: "myapp", port: 3000)
        #expect(!result)
    }

    @Test func enrichesMultipleRoutes() async {
        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock)
        let entries = [
            PortEntry(port: 3000, pid: 100, processName: "node"),
            PortEntry(port: 8000, pid: 200, processName: "python"),
            PortEntry(port: 5173, pid: 300, processName: "node"),
        ]
        let routes = [
            PortlessRoute(hostname: "frontend", port: 3000, processId: 100),
            PortlessRoute(hostname: "api", port: 8000, processId: 200),
        ]
        let enriched = integrator.enrichEntries(entries, with: routes)
        #expect(enriched[0].portlessURL == "http://frontend.localhost")
        #expect(enriched[1].portlessURL == "http://api.localhost")
        #expect(enriched[2].portlessURL == nil)
    }

    // MARK: - isPortlessAvailable (true paths)

    @Test func portlessAvailableViaRouteStore() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let routeFile = tempDir.appendingPathComponent("routes.json")
        try #"[{"hostname":"app","port":3000,"processId":1}]"#
            .write(to: routeFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile])

        #expect(await integrator.isPortlessAvailable())
    }

    @Test func portlessAvailableViaBinaryDiscovery() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 0, stdout: "/usr/local/bin/portless\n", stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [], binarySearchPaths: [])

        #expect(await integrator.isPortlessAvailable())
    }

    @Test func findsBinaryViaFilesystemSearch() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let binaryPath = tempDir.appendingPathComponent("portless").path
        FileManager.default.createFile(atPath: binaryPath, contents: Data("#!/bin/sh".utf8))
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: binaryPath)

        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [], binarySearchPaths: [binaryPath])

        #expect(await integrator.isPortlessAvailable())
    }

    @Test func findsBinaryInVersionedDirectory() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let versionBinDir = tempDir.appendingPathComponent("v18.0.0/bin")
        try FileManager.default.createDirectory(at: versionBinDir, withIntermediateDirectories: true)

        let binaryPath = versionBinDir.appendingPathComponent("portless").path
        FileManager.default.createFile(atPath: binaryPath, contents: Data("#!/bin/sh".utf8))
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: binaryPath)

        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 1, stdout: "", stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [], binarySearchPaths: [tempDir.path])

        #expect(await integrator.isPortlessAvailable())
    }

    // MARK: - loadRoutes (RouteStore paths)

    @Test func loadsRoutesFromRouteStoreJSON() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let routeFile = tempDir.appendingPathComponent("routes.json")
        try "[{\"hostname\":\"myapp\",\"port\":3000,\"processId\":\(currentPID)}]"
            .write(to: routeFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile])

        let routes = await integrator.loadRoutes()
        #expect(routes.count == 1)
        #expect(routes[0].hostname == "myapp")
    }

    @Test func loadsRoutesFromRouteStoreJSONL() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let routeFile = tempDir.appendingPathComponent("routes")
        let jsonl = "{\"hostname\":\"app1\",\"port\":3000,\"processId\":\(currentPID)}\n"
            + "{\"hostname\":\"app2\",\"port\":4000,\"processId\":\(currentPID)}"
        try jsonl.write(to: routeFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile])

        let routes = await integrator.loadRoutes()
        #expect(routes.count == 2)
        #expect(routes[0].hostname == "app1")
        #expect(routes[1].hostname == "app2")
    }

    @Test func routeStoreFiltersDeadProcesses() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let routeFile = tempDir.appendingPathComponent("routes.json")
        try #"[{"hostname":"dead","port":3000,"processId":99999}]"#
            .write(to: routeFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile])

        let routes = await integrator.loadRoutes()
        #expect(routes.isEmpty)
    }

    @Test func routeStoreSkipsEmptyAndFallsToNext() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }

        let emptyFile = tempDir.appendingPathComponent("empty.json")
        try "".write(to: emptyFile, atomically: true, encoding: .utf8)

        let validFile = tempDir.appendingPathComponent("valid.json")
        try "[{\"hostname\":\"app\",\"port\":3000,\"processId\":\(currentPID)}]"
            .write(to: validFile, atomically: true, encoding: .utf8)

        let mock = MockShellExecutor()
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [emptyFile, validFile])

        let routes = await integrator.loadRoutes()
        #expect(routes.count == 1)
        #expect(routes[0].hostname == "app")
    }

    // MARK: - registerAlias

    @Test func registerAliasSuccess() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "portless alias myapp 3000",
            result: ShellResult(exitCode: 0, stdout: "registered", stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock)
        let result = await integrator.registerAlias(name: "myapp", port: 3000)
        #expect(result)
    }

    @Test func routeStoreAvailableAndBinaryFoundSetsResolvedPath() async throws {
        let tempDir = try makeTempDir()
        defer { removeTempDir(tempDir) }
        let routeFile = tempDir.appendingPathComponent("routes.json")
        try #"[{"hostname":"app","port":3000,"processId":1}]"#
            .write(to: routeFile, atomically: true, encoding: .utf8)
        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 0, stdout: "/custom/bin/portless\n", stderr: "")
        )
        await mock.register(
            command: "/custom/bin/portless alias svc 8080",
            result: ShellResult(exitCode: 0, stdout: "ok", stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [routeFile], binarySearchPaths: [])
        #expect(await integrator.isPortlessAvailable())
        #expect(await integrator.registerAlias(name: "svc", port: 8080))
    }

    @Test func cliRoutesFiltersDeadProcesses() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 0, stdout: "/usr/local/bin/portless\n", stderr: "")
        )
        await mock.register(
            command: "/usr/local/bin/portless list --json",
            result: ShellResult(exitCode: 0,
                stdout: #"[{"hostname":"dead","port":3000,"processId":99999}]"#, stderr: "")
        )
        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [], binarySearchPaths: [])
        _ = await integrator.isPortlessAvailable()
        let routes = await integrator.loadRoutes()
        #expect(routes.isEmpty)
    }

    // MARK: - resolvedBinaryPath propagation

    @Test func resolvedBinaryPathUsedByAliasAndCLI() async {
        let mock = MockShellExecutor()
        await mock.register(
            command: "which portless",
            result: ShellResult(exitCode: 0, stdout: "/custom/bin/portless\n", stderr: "")
        )
        await mock.register(
            command: "/custom/bin/portless alias svc 8080",
            result: ShellResult(exitCode: 0, stdout: "ok", stderr: "")
        )
        let pid = ProcessInfo.processInfo.processIdentifier
        await mock.register(
            command: "/custom/bin/portless list --json",
            result: ShellResult(exitCode: 0, stdout: "[{\"hostname\":\"svc\",\"port\":8080,\"processId\":\(pid)}]", stderr: "")
        )

        let integrator = PortlessIntegrator(shell: mock, routeStorePaths: [], binarySearchPaths: [])

        // Resolves binary path via which
        #expect(await integrator.isPortlessAvailable())
        // Uses resolved path for alias
        #expect(await integrator.registerAlias(name: "svc", port: 8080))
        // Uses resolved path for CLI fallback
        let routes = await integrator.loadRoutes()
        #expect(routes.count == 1)
        #expect(routes[0].hostname == "svc")
    }
}
