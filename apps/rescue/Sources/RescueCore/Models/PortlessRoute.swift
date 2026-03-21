import Foundation

public struct PortlessRoute: Sendable, Identifiable {
    public let hostname: String
    public let port: UInt16
    public let processId: Int32

    public var id: String { "\(hostname)-\(port)" }

    public var url: String {
        if hostname.contains(".") {
            return "http://\(hostname)"
        }
        return "http://\(hostname).localhost"
    }

    public var displayHostname: String {
        hostname.hasSuffix(".localhost") ? String(hostname.dropLast(10)) : hostname
    }

    public init(hostname: String, port: UInt16, processId: Int32) {
        self.hostname = hostname
        self.port = port
        self.processId = processId
    }
}

extension PortlessRoute: Codable {
    enum CodingKeys: String, CodingKey {
        case hostname
        case port
        case processId
        case pid
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        hostname = try container.decode(String.self, forKey: .hostname)
        port = try container.decode(UInt16.self, forKey: .port)
        // Support both "processId" and "pid" field names
        if let pid = try? container.decode(Int32.self, forKey: .processId) {
            processId = pid
        } else {
            processId = try container.decode(Int32.self, forKey: .pid)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hostname, forKey: .hostname)
        try container.encode(port, forKey: .port)
        try container.encode(processId, forKey: .processId)
    }
}
