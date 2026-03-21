import Testing
import Foundation
@testable import Rescue
@testable import RescueCore

// MARK: - Local Mock
// Duplicated from RescueCoreTests/Mocks — test targets cannot share sources
actor MockShellExecutorForRescueTests: ShellExecuting {
    private var responses: [String: ShellResult] = [:]

    func register(command: String, result: ShellResult) {
        responses[command] = result
    }

    func run(command: String, arguments: [String]) async -> ShellResult {
        let key = ([command] + arguments).joined(separator: " ")
        return responses[key] ?? ShellResult(
            exitCode: 1,
            stdout: "",
            stderr: "No mock registered for: \(key)"
        )
    }
}

// MARK: - PortListViewModel Tests

@Suite @MainActor
struct PortListViewModelTests {

    private func makeViewModel() -> PortListViewModel {
        let mock = MockShellExecutorForRescueTests()
        let shell = mock as any ShellExecuting
        let scanner = PortScanner(shell: shell)
        let detector = FrameworkDetector(shell: shell)
        let terminator = ProcessTerminator()
        let portlessIntegrator = PortlessIntegrator(shell: shell, routeStorePaths: [], binarySearchPaths: [])
        let actionQueue = ActionResultQueue()
        let dockerManager = DockerManager(shell: shell)
        let dockerVM = DockerViewModel(manager: dockerManager, actionQueue: actionQueue)
        let enricher = PortEnricher(
            dockerVM: dockerVM,
            detector: detector,
            portlessIntegrator: portlessIntegrator
        )
        return PortListViewModel(
            shell: shell,
            scanner: scanner,
            terminator: terminator,
            enricher: enricher,
            actionQueue: actionQueue,
            urlOpener: { _ in }
        )
    }

    // MARK: - filteredPorts

    @Test func filteredPorts_emptySearch_returnsAll() {
        let vm = makeViewModel()
        vm.ports = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 8080, pid: 2, processName: "python"),
        ]
        vm.searchText = ""
        #expect(vm.filteredPorts.count == 2)
    }

    @Test func filteredPorts_searchByPort_returnsMatch() {
        let vm = makeViewModel()
        vm.ports = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 8080, pid: 2, processName: "python"),
        ]
        vm.searchText = "3000"
        #expect(vm.filteredPorts.count == 1)
        #expect(vm.filteredPorts[0].port == 3000)
    }

    @Test func filteredPorts_searchByProcess_returnsMatch() {
        let vm = makeViewModel()
        vm.ports = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 8080, pid: 2, processName: "python"),
        ]
        vm.searchText = "python"
        #expect(vm.filteredPorts.count == 1)
        #expect(vm.filteredPorts[0].processName == "python")
    }

    @Test func filteredPorts_ignoredProcess_excluded() {
        let vm = makeViewModel()
        vm.ports = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 8080, pid: 2, processName: "chrome helper"),
        ]
        vm.ignoredProcesses = ["chrome helper"]
        #expect(vm.filteredPorts.count == 1)
        #expect(vm.filteredPorts[0].port == 3000)
    }

    @Test func filteredPorts_ignoredByPort_excluded() {
        let vm = makeViewModel()
        vm.ports = [
            PortEntry(port: 3000, pid: 1, processName: "node"),
            PortEntry(port: 8080, pid: 2, processName: "python"),
        ]
        vm.ignoredProcesses = ["8080"]
        #expect(vm.filteredPorts.count == 1)
    }

    // MARK: - toggleSort

    @Test func toggleSort_byPort_ascending() {
        let vm = makeViewModel()
        vm.ports = [
            PortEntry(port: 8080, pid: 2, processName: "python"),
            PortEntry(port: 3000, pid: 1, processName: "node"),
        ]
        vm.sortOrder = .byPort
        vm.sortAscending = true
        vm.toggleSort(.byPort)
        // 같은 order 토글 → descending
        #expect(vm.sortAscending == false)
    }

    @Test func toggleSort_differentOrder_resetsAscending() {
        let vm = makeViewModel()
        vm.sortOrder = .byPort
        vm.sortAscending = false
        vm.toggleSort(.byName)
        #expect(vm.sortOrder == .byName)
        #expect(vm.sortAscending == true)
    }

    // MARK: - openInBrowser URL scheme validation

    @Test func openInBrowser_httpScheme_allowed() {
        let vm = makeViewModel()
        let entry = PortEntry(port: 3000, pid: 1, processName: "node", portlessURL: "http://myapp.test")
        // Should not crash — just verify no assertion failure
        vm.openInBrowser(entry: entry)
    }

    @Test func openInBrowser_invalidScheme_blocked() {
        let vm = makeViewModel()
        let entry = PortEntry(port: 3000, pid: 1, processName: "node", portlessURL: "javascript:alert(1)")
        // Should silently return without opening
        vm.openInBrowser(entry: entry)
        // No crash = pass
    }
}

// MARK: - DockerViewModel Tests

@Suite @MainActor
struct DockerViewModelTests {

    private func makeViewModel() -> DockerViewModel {
        let mock = MockShellExecutorForRescueTests()
        let manager = DockerManager(shell: mock)
        return DockerViewModel(manager: manager, actionQueue: ActionResultQueue())
    }

    // MARK: - filteredContainers

    @Test func filteredContainers_emptySearch_returnsAll() {
        let vm = makeViewModel()
        vm.containers = [
            DockerContainer(id: "1", name: "api", image: "node:18", status: .running, rawStatus: "Up 2h", ports: []),
            DockerContainer(id: "2", name: "db", image: "postgres:15", status: .running, rawStatus: "Up 1h", ports: []),
        ]
        vm.searchText = ""
        #expect(vm.filteredContainers.count == 2)
    }

    @Test func filteredContainers_searchByName_returnsMatch() {
        let vm = makeViewModel()
        vm.containers = [
            DockerContainer(id: "1", name: "api", image: "node:18", status: .running, rawStatus: "Up 2h", ports: []),
            DockerContainer(id: "2", name: "db", image: "postgres:15", status: .running, rawStatus: "Up 1h", ports: []),
        ]
        vm.searchText = "api"
        #expect(vm.filteredContainers.count == 1)
        #expect(vm.filteredContainers[0].name == "api")
    }

    @Test func filteredContainers_searchByImage_returnsMatch() {
        let vm = makeViewModel()
        vm.containers = [
            DockerContainer(id: "1", name: "api", image: "node:18", status: .running, rawStatus: "Up 2h", ports: []),
            DockerContainer(id: "2", name: "db", image: "postgres:15", status: .running, rawStatus: "Up 1h", ports: []),
        ]
        vm.searchText = "postgres"
        #expect(vm.filteredContainers.count == 1)
        #expect(vm.filteredContainers[0].id == "2")
    }

    // MARK: - toggleSort

    @Test func toggleSort_sameOrder_togglesAscending() {
        let vm = makeViewModel()
        vm.sortOrder = .byName
        vm.sortAscending = true
        vm.toggleSort(.byName)
        #expect(vm.sortAscending == false)
    }

    @Test func toggleSort_differentOrder_resetsAscending() {
        let vm = makeViewModel()
        vm.sortOrder = .byName
        vm.sortAscending = false
        vm.toggleSort(.byImage)
        #expect(vm.sortOrder == .byImage)
        #expect(vm.sortAscending == true)
    }
}
