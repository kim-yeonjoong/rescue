import Foundation

public struct PortEntry: Identifiable, Sendable, Hashable {
    public let port: UInt16
    public let pid: Int32
    public let processName: String
    public var framework: DevFramework?
    public var portlessURL: String?
    public var caddyURL: String?

    public var id: String { "\(port)-\(pid)" }

    // Identity based on port+pid only; framework and portlessURL are enrichment
    // metadata that may change between poll cycles without affecting identity.
    public static func == (lhs: PortEntry, rhs: PortEntry) -> Bool {
        lhs.port == rhs.port && lhs.pid == rhs.pid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(port)
        hasher.combine(pid)
    }

    public init(
        port: UInt16, pid: Int32, processName: String,
        framework: DevFramework? = nil, portlessURL: String? = nil,
        caddyURL: String? = nil
    ) {
        self.port = port
        self.pid = pid
        self.processName = processName
        self.framework = framework
        self.portlessURL = portlessURL
        self.caddyURL = caddyURL
    }
}
