import Foundation
import os

public actor DockerManager {
    private let shell: any ShellExecuting

    public init(shell: any ShellExecuting) {
        self.shell = shell
    }

    public func isDockerAvailable() async -> Bool {
        let result = await shell.run(command: "docker", arguments: ["ps", "-q"])
        if !result.succeeded {
            RescueLogger.docker.info("Docker not available")
        }
        return result.succeeded
    }

    public func listContainers() async -> [DockerContainer] {
        let result = await shell.run(
            command: "docker",
            arguments: ["ps", "-a", "--format", "{{json .}}"]
        )
        guard result.succeeded else {
            RescueLogger.docker.error("Failed to list containers: \(result.stderr)")
            return []
        }

        let decoder = JSONDecoder()
        return result.stdout
            .components(separatedBy: "\n")
            .compactMap { line -> DockerContainer? in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty,
                      let data = trimmed.data(using: .utf8),
                      let json = try? decoder.decode(ContainerJSON.self, from: data)
                else { return nil }

                let status = parseStatus(json.Status)
                let ports = DockerContainer.parsePorts(json.Ports ?? "")
                return DockerContainer(
                    id: json.ID,
                    name: json.Names,
                    image: json.Image,
                    status: status,
                    rawStatus: json.Status,
                    ports: ports
                )
            }
    }

    public func startContainer(id: String) async -> Bool {
        await runContainerCommand("start", id: id)
    }

    public func stopContainer(id: String) async -> Bool {
        await runContainerCommand("stop", id: id)
    }

    public func restartContainer(id: String) async -> Bool {
        await runContainerCommand("restart", id: id)
    }

    private func runContainerCommand(_ subcommand: String, id: String) async -> Bool {
        guard !id.hasPrefix("-") else {
            RescueLogger.docker.error("Invalid container ID: \(id)")
            return false
        }
        let result = await shell.run(command: "docker", arguments: [subcommand, "--", id])
        if !result.succeeded {
            RescueLogger.docker.error("Failed to \(subcommand) container \(id): \(result.stderr)")
        }
        return result.succeeded
    }

    private func parseStatus(_ status: String) -> DockerContainer.ContainerStatus {
        if status.contains("Paused") { return .paused }
        if status.hasPrefix("Up") { return .running }
        if status.hasPrefix("Exited") { return .exited }
        return .other(status)
    }
}

// MARK: - Private

private struct ContainerJSON: Decodable {
    let ID: String
    let Names: String
    let Image: String
    let Status: String
    let Ports: String?
}
