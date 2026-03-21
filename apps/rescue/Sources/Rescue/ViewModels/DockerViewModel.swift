import SwiftUI
import RescueCore

@Observable
@MainActor
final class DockerViewModel {
    var containers: [DockerContainer] = []
    var searchText: String = ""
    var isDockerAvailable = false
    var isLoading = false
    var operatingContainers: Set<String> = []
    var sortOrder: SortOrder = .byName
    var sortAscending: Bool = true
    let actionQueue: ActionResultQueue
    private let manager: DockerManager
    private var pollingTask: Task<Void, Never>?
    private var isRefreshing = false

    enum SortOrder: String, CaseIterable {
        case byName = "Name"
        case byImage = "Image"
        case byStatus = "Status"
    }

    init(manager: DockerManager, actionQueue: ActionResultQueue) {
        self.manager = manager
        self.actionQueue = actionQueue
    }

    func startPolling(interval: TimeInterval = 5.0) {
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
        isDockerAvailable = await manager.isDockerAvailable()
        guard isDockerAvailable else {
            containers = []
            return
        }
        containers = sorted(await manager.listContainers())
    }

    func toggleSort(_ order: SortOrder) {
        if sortOrder == order {
            sortAscending.toggle()
        } else {
            sortOrder = order
            sortAscending = true
        }
        containers = sorted(containers)
    }

    var filteredContainers: [DockerContainer] {
        guard !searchText.isEmpty else { return containers }
        let q = searchText.lowercased()
        return containers.filter { container in
            container.name.lowercased().contains(q)
            || container.image.lowercased().contains(q)
            || container.displayStatus.lowercased().contains(q)
        }
    }

    private func sorted(_ list: [DockerContainer]) -> [DockerContainer] {
        let asc = sortAscending
        switch sortOrder {
        case .byName:
            return list.sorted { asc ? $0.name < $1.name : $0.name > $1.name }
        case .byImage:
            return list.sorted { asc ? $0.image < $1.image : $0.image > $1.image }
        case .byStatus:
            return list.sorted { asc ? $0.displayStatus < $1.displayStatus : $0.displayStatus > $1.displayStatus }
        }
    }

    func start(_ container: DockerContainer) async {
        await performAction("Started", failVerb: "start", on: container) {
            await self.manager.startContainer(id: container.id)
        }
    }

    func stop(_ container: DockerContainer) async {
        await performAction("Stopped", failVerb: "stop", on: container) {
            await self.manager.stopContainer(id: container.id)
        }
    }

    func restart(_ container: DockerContainer) async {
        await performAction("Restarted", failVerb: "restart", on: container) {
            await self.manager.restartContainer(id: container.id)
        }
    }

    private func performAction(
        _ successVerb: String,
        failVerb: String,
        on container: DockerContainer,
        _ work: () async -> Bool
    ) async {
        operatingContainers.insert(container.id)
        defer { operatingContainers.remove(container.id) }
        let success = await work()
        actionQueue.push(ActionResult(
            message: success ? "\(successVerb) \(container.name)" : "Couldn't \(failVerb) \(container.name)",
            isError: !success
        ))
        await refresh()
    }
}
