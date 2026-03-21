import SwiftUI
import RescueCore

@Observable
@MainActor
final class PortEnricher {
    var isPortlessAvailable = false
    var portlessEnabled = true
    var portlessRoutes: [PortlessRoute] = []
    var portlessSortOrder: PortlessSortOrder = .byHostname
    var portlessSortAscending: Bool = true

    enum PortlessSortOrder: String, CaseIterable {
        case byHostname = "Hostname"
        case byPort = "Port"
    }

    private let dockerVM: DockerViewModel
    private let detector: FrameworkDetector
    private let portlessIntegrator: PortlessIntegrator

    init(dockerVM: DockerViewModel, detector: FrameworkDetector, portlessIntegrator: PortlessIntegrator) {
        self.dockerVM = dockerVM
        self.detector = detector
        self.portlessIntegrator = portlessIntegrator
    }

    func detectFrameworks(_ entries: [PortEntry]) async -> [PortEntry] {
        let detector = self.detector
        return await withTaskGroup(of: (Int, DevFramework?).self) { group in
            for (index, entry) in entries.enumerated() {
                group.addTask {
                    let fw = await detector.detect(
                        port: entry.port,
                        pid: entry.pid,
                        processName: entry.processName
                    )
                    return (index, fw)
                }
            }
            var result = entries
            for await (index, framework) in group {
                guard index < result.count else { continue }
                result[index].framework = framework
            }
            return result
        }
    }

    func enrichWithDockerContainers(_ entries: [PortEntry]) -> [PortEntry] {
        let containers = dockerVM.containers
        guard !containers.isEmpty else { return entries }
        return entries.map { entry in
            guard let container = containers.first(where: { dc in
                dc.ports.contains { $0.hostPort == entry.port }
            }) else { return entry }
            var e = entry
            e.framework = container.inferredFramework ?? .docker
            return e
        }
    }

    func enrichWithPortless(_ entries: [PortEntry]) async -> [PortEntry] {
        if portlessEnabled {
            isPortlessAvailable = await portlessIntegrator.isPortlessAvailable()
        } else {
            isPortlessAvailable = false
        }
        guard isPortlessAvailable else {
            portlessRoutes = []
            return entries
        }
        let routes = await portlessIntegrator.loadRoutes()
        portlessRoutes = sortedPortless(routes)
        return portlessIntegrator.enrichEntries(entries, with: routes)
    }

    func effectiveFramework(for entry: PortEntry) -> DevFramework? {
        let containers = dockerVM.containers
        if let container = containers.first(where: { $0.ports.contains { $0.hostPort == entry.port } }) {
            return container.inferredFramework ?? .docker
        }
        return entry.framework
    }

    func displayProcessName(for entry: PortEntry) -> String {
        if let route = portlessRoutes.first(where: { $0.port == entry.port }) {
            return route.displayHostname
        }
        guard entry.processName.lowercased().hasPrefix("com.docker") else {
            return entry.processName
        }
        let containers = dockerVM.containers
        let match = containers.first { container in
            container.ports.contains { $0.hostPort == entry.port }
        }
        return match.map(\.name) ?? entry.processName
    }

    func togglePortlessSort(_ order: PortlessSortOrder) {
        if portlessSortOrder == order {
            portlessSortAscending.toggle()
        } else {
            portlessSortOrder = order
            portlessSortAscending = true
        }
        portlessRoutes = sortedPortless(portlessRoutes)
    }

    private func sortedPortless(_ routes: [PortlessRoute]) -> [PortlessRoute] {
        let asc = portlessSortAscending
        switch portlessSortOrder {
        case .byHostname:
            return routes.sorted { asc ? $0.hostname < $1.hostname : $0.hostname > $1.hostname }
        case .byPort:
            return routes.sorted { asc ? $0.port < $1.port : $0.port > $1.port }
        }
    }
}
