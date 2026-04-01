import Foundation

public struct CaddyRoute: Sendable, Identifiable {
    public let hostname: String
    public let upstreamPort: UInt16
    public let upstreamHost: String

    public var id: String { "\(hostname)-\(upstreamPort)" }

    public var url: String {
        if hostname.contains(".") {
            return "https://\(hostname)"
        }
        return "https://\(hostname).localhost"
    }

    public var displayHostname: String {
        hostname.hasSuffix(".localhost") ? String(hostname.dropLast(10)) : hostname
    }

    public init(hostname: String, upstreamPort: UInt16, upstreamHost: String = "localhost") {
        self.hostname = hostname
        self.upstreamPort = upstreamPort
        self.upstreamHost = upstreamHost
    }
}
