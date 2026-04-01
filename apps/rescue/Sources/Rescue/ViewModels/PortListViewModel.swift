import SwiftUI
import RescueCore

struct ActionResult: Identifiable {
    let id = UUID()
    let message: String
    let isError: Bool
}

@Observable
@MainActor
final class ActionResultQueue {
    private(set) var current: ActionResult?
    private var dismissTask: Task<Void, Never>?

    func push(_ result: ActionResult) {
        dismissTask?.cancel()
        current = result
        dismissTask = Task {
            try? await Task.sleep(for: Constants.bannerDismissDelay)
            if !Task.isCancelled { current = nil }
        }
    }
}

@Observable
@MainActor
final class PortListViewModel {
    var ports: [PortEntry] = []
    var searchText: String = ""
    var isLoading = false
    var sortOrder: SortOrder = .byPort
    var sortAscending: Bool = true
    var ignoredProcesses: Set<String> = []
    var isKilling: Set<String> = []
    let enricher: PortEnricher
    let actionQueue: ActionResultQueue
    let actionHandler: PortActionHandler
    private let shell: any ShellExecuting
    private let scanner: PortScanner
    private let uptimeTracker: UptimeTracker
    private var pollingTask: Task<Void, Never>?
    private var isRefreshing = false

    enum SortOrder: String, CaseIterable {
        case byPort = "Port"
        case byName = "Name"
        case byFramework = "Framework"
    }

    init(
        shell: any ShellExecuting,
        scanner: PortScanner,
        terminator: ProcessTerminator,
        enricher: PortEnricher,
        actionQueue: ActionResultQueue,
        urlOpener: @escaping (URL) -> Void = { NSWorkspace.shared.open($0) }
    ) {
        self.shell = shell
        self.scanner = scanner
        self.enricher = enricher
        self.actionQueue = actionQueue
        self.actionHandler = PortActionHandler(
            actionQueue: actionQueue,
            terminator: terminator,
            urlOpener: urlOpener
        )
        self.uptimeTracker = UptimeTracker(shell: shell)
    }

    func startPolling(interval: TimeInterval = Constants.defaultPollingInterval) {
        pollingTask?.cancel()
        pollingTask = Task {
            while !Task.isCancelled {
                await refresh()
                do {
                    try await Task.sleep(for: .seconds(interval))
                } catch {
                    break
                }
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        isLoading = true
        defer { isLoading = false }
        var entries = await scanner.scan()
        entries = await enricher.detectFrameworks(entries)
        entries = enricher.enrichWithDockerContainers(entries)
        entries = await enricher.enrichWithPortless(entries)
        entries = await enricher.enrichWithCaddy(entries)
        await uptimeTracker.update(for: entries)
        let removedPorts = Set(ports.map(\.port)).subtracting(Set(entries.map(\.port)))
        uptimeTracker.cleanup(removedPorts: removedPorts)
        ports = sorted(entries)
    }

    func reenrichPorts() {
        ports = enricher.enrichWithDockerContainers(ports)
    }

    func uptimeString(for port: UInt16) -> String? {
        uptimeTracker.uptimeString(for: port)
    }

    func toggleSort(_ order: SortOrder) {
        if sortOrder == order {
            sortAscending.toggle()
        } else {
            sortOrder = order
            sortAscending = true
        }
        ports = sorted(ports)
    }

    func killProcess(entry: PortEntry) async {
        isKilling.insert(entry.id)
        defer { isKilling.remove(entry.id) }
        _ = await actionHandler.killProcess(entry: entry)
        await refresh()
    }

    func openInBrowser(entry: PortEntry) {
        actionHandler.openInBrowser(entry: entry)
    }

    func copyPort(_ entry: PortEntry) {
        actionHandler.copyPort(entry)
    }

    func copyURL(_ entry: PortEntry) {
        actionHandler.copyURL(entry)
    }

    var filteredPorts: [PortEntry] {
        let base: [PortEntry]
        if searchText.isEmpty {
            base = ports
        } else {
            let q = searchText.lowercased()
            base = ports.filter { entry in
                String(entry.port).contains(q)
                || entry.processName.lowercased().contains(q)
                || (entry.framework?.displayName.lowercased().contains(q) ?? false)
                || (entry.portlessURL?.lowercased().contains(q) ?? false)
                || (entry.caddyURL?.lowercased().contains(q) ?? false)
            }
        }
        guard !ignoredProcesses.isEmpty else { return base }
        return base.filter { entry in
            let name = entry.processName.lowercased()
            let portStr = String(entry.port)
            return !ignoredProcesses.contains { term in
                portStr == term || name.contains(term)
            }
        }
    }

    var filteredPortlessRoutes: [PortlessRoute] {
        guard !searchText.isEmpty else { return enricher.portlessRoutes }
        let q = searchText.lowercased()
        return enricher.portlessRoutes.filter { route in
            route.hostname.lowercased().contains(q)
            || String(route.port).contains(q)
            || route.url.lowercased().contains(q)
        }
    }

    var filteredCaddyRoutes: [CaddyRoute] {
        guard !searchText.isEmpty else { return enricher.caddyRoutes }
        let q = searchText.lowercased()
        return enricher.caddyRoutes.filter { route in
            route.hostname.lowercased().contains(q)
            || String(route.upstreamPort).contains(q)
            || route.url.lowercased().contains(q)
        }
    }

    private func sorted(_ entries: [PortEntry]) -> [PortEntry] {
        let asc = sortAscending
        switch sortOrder {
        case .byPort:
            return entries.sorted { asc ? $0.port < $1.port : $0.port > $1.port }
        case .byName:
            return entries.sorted { asc ? $0.processName < $1.processName : $0.processName > $1.processName }
        case .byFramework:
            return entries.sorted { lhs, rhs in
                let lhsName = lhs.framework?.displayName ?? "zzz"
                let rhsName = rhs.framework?.displayName ?? "zzz"
                return asc ? lhsName < rhsName : lhsName > rhsName
            }
        }
    }
}
