import Darwin
import Foundation
import os

public actor PortlessIntegrator {
    private let shell: any ShellExecuting
    private let routeStorePaths: [URL]
    private let binarySearchPaths: [String]
    private var resolvedBinaryPath: String?

    public init(shell: any ShellExecuting, routeStorePaths: [URL]? = nil, binarySearchPaths: [String]? = nil) {
        self.shell = shell
        self.routeStorePaths = routeStorePaths ?? Self.defaultRouteStorePaths()
        self.binarySearchPaths = binarySearchPaths ?? Self.defaultBinarySearchPaths()
    }

    private static func defaultRouteStorePaths() -> [URL] {
        let userHome = FileManager.default.homeDirectoryForCurrentUser
        // sudo로 실행된 portless는 root 홈(macOS: /var/root)에 저장
        let rootHome = URL(fileURLWithPath: "/var/root")
        return [
            URL(fileURLWithPath: "/tmp/portless/routes.json"),
            userHome.appendingPathComponent(".portless/routes.json"),
            userHome.appendingPathComponent(".config/portless/routes.json"),
            userHome.appendingPathComponent(".portless/routes"),
            userHome.appendingPathComponent(".config/portless/routes"),
            rootHome.appendingPathComponent(".portless/routes.json"),
            rootHome.appendingPathComponent(".config/portless/routes.json"),
            rootHome.appendingPathComponent(".portless/routes"),
            rootHome.appendingPathComponent(".config/portless/routes"),
        ]
    }

    /// Check if portless CLI is installed
    public func isPortlessAvailable() async -> Bool {
        if resolvedBinaryPath == nil {
            resolvedBinaryPath = await findPortlessBinary()
        }
        if await routeStoreExists() { return true }
        if resolvedBinaryPath != nil { return true }
        RescueLogger.portless.info("Portless not available")
        return false
    }

    /// Load routes from portless
    /// Priority: 1) RouteStore file, 2) CLI fallback
    public func loadRoutes() async -> [PortlessRoute] {
        // Try RouteStore file first
        if let routes = await loadFromRouteStore() {
            return routes.filter { isProcessAlive($0.processId) }
        }
        // Fallback to CLI
        let cliRoutes = await loadFromCLI()
        return cliRoutes.filter { isProcessAlive($0.processId) }
    }

    /// Register an alias for a port
    public func registerAlias(name: String, port: UInt16) async -> Bool {
        guard !name.isEmpty,
              name.count <= 253,
              !name.hasPrefix("-"),
              name != ".",
              name != "..",
              name.allSatisfy({ ($0.isLetter && $0.isASCII) || $0.isNumber || $0 == "-" || $0 == "." }) else {
            RescueLogger.portless.error("Invalid alias name: \(name)")
            return false
        }
        let binary = resolvedBinaryPath ?? "portless"
        let result = await shell.run(command: binary, arguments: ["alias", name, String(port)])
        if !result.succeeded {
            RescueLogger.portless.error("Failed to register alias \(name) for port \(port): \(result.stderr)")
        }
        return result.succeeded
    }

    /// Match portless routes to port entries by port number
    public nonisolated func enrichEntries(_ entries: [PortEntry], with routes: [PortlessRoute]) -> [PortEntry] {
        var enriched = entries
        let routesByPort = Dictionary(grouping: routes, by: \.port)
        for i in enriched.indices {
            if let route = routesByPort[enriched[i].port]?.first {
                enriched[i].portlessURL = route.url
            }
        }
        return enriched
    }

    // MARK: - Binary Discovery

    private static func defaultBinarySearchPaths() -> [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            // nvm (most common for npm -g installs)
            "\(home)/.nvm/versions/node",
            // Homebrew
            "/opt/homebrew/bin/portless",
            "/usr/local/bin/portless",
            // volta
            "\(home)/.volta/bin/portless",
            // pnpm global
            "\(home)/.local/share/pnpm/portless",
            // fnm
            "\(home)/Library/Application Support/fnm/node-versions",
        ]
    }

    private func findPortlessBinary() async -> String? {
        // 1. Check `which` first (works if PATH is set, e.g. terminal launch)
        let whichResult = await shell.run(command: "which", arguments: ["portless"])
        if whichResult.succeeded {
            let path = whichResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            if !path.isEmpty { return path }
        }

        // 2. Search common installation paths (GUI apps don't inherit shell PATH)
        let fm = FileManager.default

        for candidate in binarySearchPaths {
            // Direct binary path
            if fm.isExecutableFile(atPath: candidate) {
                RescueLogger.portless.debug("Found portless at \(candidate)")
                return candidate
            }

            // nvm/fnm directory: search for bin/portless inside version dirs
            if fm.fileExists(atPath: candidate) {
                if let versions = try? fm.contentsOfDirectory(atPath: candidate) {
                    for version in versions.sorted().reversed() {
                        let binPath = "\(candidate)/\(version)/bin/portless"
                        if fm.isExecutableFile(atPath: binPath) {
                            RescueLogger.portless.debug("Found portless at \(binPath)")
                            return binPath
                        }
                    }
                }
            }
        }

        RescueLogger.portless.debug("Could not find portless binary in known paths")
        return nil
    }

    // MARK: - Route Store

    private func routeStoreExists() async -> Bool {
        let paths = routeStorePaths
        return await Task.detached {
            paths.contains { FileManager.default.fileExists(atPath: $0.path) }
        }.value
    }

    private func loadFromRouteStore() async -> [PortlessRoute]? {
        let paths = routeStorePaths
        return await Task.detached {
            for path in paths {
                guard let data = try? Data(contentsOf: path), !data.isEmpty else { continue }
                if let routes = try? JSONDecoder().decode([PortlessRoute].self, from: data), !routes.isEmpty {
                    RescueLogger.portless.debug("Loaded \(routes.count) routes from \(path.path)")
                    return routes
                }
                if let content = String(data: data, encoding: .utf8) {
                    let routes = content
                        .split(separator: "\n")
                        .compactMap { line -> PortlessRoute? in
                            guard let lineData = line.data(using: .utf8) else { return nil }
                            return try? JSONDecoder().decode(PortlessRoute.self, from: lineData)
                        }
                    if !routes.isEmpty {
                        RescueLogger.portless.debug("Loaded \(routes.count) routes (JSONL) from \(path.path)")
                        return routes
                    }
                }
            }
            return nil
        }.value
    }

    // MARK: - CLI Fallback

    private func loadFromCLI() async -> [PortlessRoute] {
        let binary = resolvedBinaryPath ?? "portless"
        let result = await shell.run(command: binary, arguments: ["list", "--json"])
        guard result.succeeded, let data = result.stdout.data(using: .utf8) else {
            if !result.succeeded {
                RescueLogger.portless.error("Failed to load routes from CLI: \(result.stderr)")
            }
            return []
        }
        return (try? JSONDecoder().decode([PortlessRoute].self, from: data)) ?? []
    }

    private nonisolated func isProcessAlive(_ pid: Int32) -> Bool {
        let result = Darwin.kill(pid, 0)
        return result == 0 || (result == -1 && errno == EPERM)
    }
}
