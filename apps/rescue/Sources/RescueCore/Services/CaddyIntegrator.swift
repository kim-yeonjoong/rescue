import Foundation
import os

public actor CaddyIntegrator {
    private let shell: any ShellExecuting
    private let adminAPI: String
    private let caddyfilePaths: [String]
    private let binarySearchPaths: [String]
    private var resolvedBinaryPath: String?

    public init(
        shell: any ShellExecuting,
        adminAPI: String = "http://localhost:2019",
        caddyfilePaths: [String]? = nil,
        binarySearchPaths: [String]? = nil
    ) {
        self.shell = shell
        self.adminAPI = adminAPI
        self.caddyfilePaths = caddyfilePaths ?? Self.defaultCaddyfilePaths()
        self.binarySearchPaths = binarySearchPaths ?? Self.defaultBinarySearchPaths()
    }

    private static func defaultCaddyfilePaths() -> [String] {
        let home = FileManager.default.homeDirectoryForCurrentUser.path
        return [
            "/etc/caddy/Caddyfile",
            "\(home)/Caddyfile",
            "\(home)/.config/caddy/Caddyfile",
        ]
    }

    private static func defaultBinarySearchPaths() -> [String] {
        return [
            "/opt/homebrew/bin/caddy",
            "/usr/local/bin/caddy",
            "/usr/bin/caddy",
        ]
    }

    /// Check if Caddy is running (admin API reachable or binary exists)
    public func isCaddyAvailable() async -> Bool {
        // Try admin API first — indicates Caddy is actively running
        let result = await shell.run(command: "curl", arguments: [
            "-s", "-o", "/dev/null", "-w", "%{http_code}",
            "--connect-timeout", "1", "\(adminAPI)/config/",
        ])
        if result.succeeded, result.stdout.trimmingCharacters(in: .whitespacesAndNewlines) == "200" {
            RescueLogger.caddy.debug("Caddy admin API is reachable")
            return true
        }

        // Check if binary exists
        if resolvedBinaryPath == nil {
            resolvedBinaryPath = await findCaddyBinary()
        }
        if resolvedBinaryPath != nil {
            RescueLogger.caddy.debug("Caddy binary found; will attempt Caddyfile fallback if API is unreachable")
            return true
        }

        RescueLogger.caddy.info("Caddy not available")
        return false
    }

    /// Load reverse proxy routes from Caddy config
    public func loadRoutes() async -> [CaddyRoute] {
        // Try admin API first
        if let routes = await loadFromAdminAPI() {
            return routes
        }
        // Fallback: adapt Caddyfile via CLI
        if let routes = await loadFromCaddyfile() {
            return routes
        }
        return []
    }

    /// Match Caddy routes to port entries by upstream port
    public nonisolated func enrichEntries(_ entries: [PortEntry], with routes: [CaddyRoute]) -> [PortEntry] {
        var enriched = entries
        let routesByPort = Dictionary(grouping: routes, by: \.upstreamPort)
        for i in enriched.indices {
            if let route = routesByPort[enriched[i].port]?.first {
                enriched[i].caddyURL = route.url
            }
        }
        return enriched
    }

    // MARK: - Admin API

    private func loadFromAdminAPI() async -> [CaddyRoute]? {
        let result = await shell.run(command: "curl", arguments: [
            "-s", "--connect-timeout", "2", "\(adminAPI)/config/",
        ])
        guard result.succeeded, !result.stdout.isEmpty,
              let data = result.stdout.data(using: .utf8) else {
            RescueLogger.caddy.debug("Admin API not available or returned empty config")
            return nil
        }
        return parseCaddyJSON(data)
    }

    // MARK: - Caddyfile Fallback

    private func loadFromCaddyfile() async -> [CaddyRoute]? {
        if resolvedBinaryPath == nil {
            resolvedBinaryPath = await findCaddyBinary()
        }
        guard let binary = resolvedBinaryPath else { return nil }
        for path in caddyfilePaths {
            guard FileManager.default.fileExists(atPath: path) else { continue }
            let result = await shell.run(
                command: binary, arguments: ["adapt", "--config", path, "--adapter", "caddyfile"]
            )
            guard result.succeeded, let data = result.stdout.data(using: .utf8) else { continue }
            if let routes = parseCaddyJSON(data) {
                RescueLogger.caddy.debug("Loaded \(routes.count) routes from Caddyfile at \(path)")
                return routes
            }
        }
        return nil
    }

    // MARK: - Binary Discovery

    private func findCaddyBinary() async -> String? {
        let whichResult = await shell.run(command: "which", arguments: ["caddy"])
        if whichResult.succeeded {
            let path = whichResult.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
            if !path.isEmpty { return path }
        }
        let fm = FileManager.default
        for candidate in binarySearchPaths where fm.isExecutableFile(atPath: candidate) {
            RescueLogger.caddy.debug("Found caddy at \(candidate)")
            return candidate
        }
        RescueLogger.caddy.debug("Could not find caddy binary in known paths")
        return nil
    }

    // MARK: - JSON Parsing

    /// Parse Caddy's JSON config to extract reverse_proxy routes.
    /// Structure: { "apps": { "http": { "servers": { "srv0": { "routes": [...] } } } } }
    internal func parseCaddyJSON(_ data: Data) -> [CaddyRoute]? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let apps = json["apps"] as? [String: Any],
              let http = apps["http"] as? [String: Any],
              let servers = http["servers"] as? [String: Any] else {
            return nil
        }

        var routes: [CaddyRoute] = []
        for (_, serverValue) in servers {
            guard let server = serverValue as? [String: Any],
                  let serverRoutes = server["routes"] as? [[String: Any]] else { continue }
            for route in serverRoutes {
                let hostnames = extractHostnames(from: route)
                let upstreams = extractUpstreams(from: route)
                for hostname in hostnames {
                    for (host, port) in upstreams {
                        routes.append(CaddyRoute(hostname: hostname, upstreamPort: port, upstreamHost: host))
                    }
                }
            }
        }
        return routes.isEmpty ? nil : routes
    }

    private func extractHostnames(from route: [String: Any]) -> [String] {
        guard let matchers = route["match"] as? [[String: Any]] else { return [] }
        var hostnames: [String] = []
        for matcher in matchers {
            if let hosts = matcher["host"] as? [String] {
                hostnames.append(contentsOf: hosts)
            }
        }
        return hostnames
    }

    private func extractUpstreams(from route: [String: Any]) -> [(String, UInt16)] {
        guard let handlers = route["handle"] as? [[String: Any]] else { return [] }
        var upstreams: [(String, UInt16)] = []
        for handler in handlers {
            upstreams.append(contentsOf: extractUpstreamsFromHandler(handler))
        }
        return upstreams
    }

    /// Recursively search handlers for reverse_proxy upstreams.
    /// Caddy may nest handlers inside "subroute" handlers.
    private func extractUpstreamsFromHandler(_ handler: [String: Any]) -> [(String, UInt16)] {
        let handlerType = handler["handler"] as? String

        if handlerType == "reverse_proxy" {
            return parseReverseProxyUpstreams(handler)
        }

        // Recurse into subroutes
        if handlerType == "subroute",
           let subRoutes = handler["routes"] as? [[String: Any]] {
            var upstreams: [(String, UInt16)] = []
            for subRoute in subRoutes {
                if let handlers = subRoute["handle"] as? [[String: Any]] {
                    for h in handlers {
                        upstreams.append(contentsOf: extractUpstreamsFromHandler(h))
                    }
                }
            }
            return upstreams
        }

        return []
    }

    /// Parse "upstreams": [{"dial": "localhost:3000"}]
    private func parseReverseProxyUpstreams(_ handler: [String: Any]) -> [(String, UInt16)] {
        guard let upstreams = handler["upstreams"] as? [[String: Any]] else { return [] }
        var result: [(String, UInt16)] = []
        for upstream in upstreams {
            guard let dial = upstream["dial"] as? String else { continue }
            let components = dial.components(separatedBy: ":")
            if components.count >= 2, let portString = components.last, let port = UInt16(portString) {
                let host = components.dropLast().joined(separator: ":")
                result.append((host.isEmpty ? "localhost" : host, port))
            }
        }
        return result
    }
}
