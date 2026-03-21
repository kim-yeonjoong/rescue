import Foundation

public struct DockerContainer: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let image: String
    public let status: ContainerStatus
    public let rawStatus: String
    public let ports: [PortMapping]

    public var displayStatus: String { status.displayText }

    /// "Up 37 hours (healthy)" → "37h", "Up 2 minutes" → "2m"
    public var uptimeString: String? {
        guard case .running = status else { return nil }
        guard rawStatus.hasPrefix("Up ") else { return nil }
        var rest = String(rawStatus.dropFirst(3))
        // Handle "About" prefix: "Up About an hour" → "an hour"
        if rest.lowercased().hasPrefix("about ") {
            rest = String(rest.dropFirst(6))
        }
        let parts = rest.split(separator: " ").map(String.init)
        guard parts.count >= 2 else { return nil }
        let rawValue = parts[0].lowercased()
        let unit = parts[1].lowercased()
        // Handle "a"/"an" articles: "an hour" → "1h", "a minute" → "1m"
        let value = (rawValue == "a" || rawValue == "an") ? "1" : parts[0]
        if unit.hasPrefix("second") { return value + "s" }
        if unit.hasPrefix("minute") { return value + "m" }
        if unit.hasPrefix("hour") { return value + "h" }
        if unit.hasPrefix("day") { return value + "d" }
        if unit.hasPrefix("week") { return value + "w" }
        return nil
    }

    public enum ContainerStatus: Sendable, Equatable {
        case running
        case exited
        case paused
        case other(String)

        public var displayText: String {
            switch self {
            case .running: return "Running"
            case .exited: return "Exited"
            case .paused: return "Paused"
            case .other(let s): return s
            }
        }

        public var isRunning: Bool {
            if case .running = self { return true }
            return false
        }

        public static func == (lhs: ContainerStatus, rhs: ContainerStatus) -> Bool {
            switch (lhs, rhs) {
            case (.running, .running), (.exited, .exited), (.paused, .paused): return true
            case (.other(let l), .other(let r)): return l == r
            default: return false
            }
        }
    }

    public struct PortMapping: Sendable, Hashable {
        public let hostPort: UInt16
        public let containerPort: UInt16
        public let proto: String  // "tcp" or "udp"

        public init(hostPort: UInt16, containerPort: UInt16, proto: String) {
            self.hostPort = hostPort
            self.containerPort = containerPort
            self.proto = proto
        }
    }

    /// 이미지 이름에서 프레임워크 감지
    public var inferredFramework: DevFramework? {
        let img = image.lowercased()
        if img.contains("nestjs") || img.contains("nest-") { return .nestjs }
        if img.contains("nextjs") || img.contains("next-") || img.contains("next.js") { return .nextjs }
        if img.contains("nuxt") { return .nuxt }
        if img.contains("fastapi") { return .fastapi }
        if img.contains("fastify") { return .fastify }
        if img.contains("vite") { return .vite }
        if img.contains("angular") { return .angular }
        if img.contains("svelte") { return .sveltekit }
        if img.contains("remix") { return .remix }
        if img.contains("astro") { return .astro }
        if img.contains("django") { return .django }
        if img.contains("flask") { return .flask }
        if img.contains("rails") { return .rails }
        if img.contains("express") && !img.contains("express-") { return .express }
        if img.contains("spring-boot") || img.contains("springboot") { return .springBoot }
        if img.contains("phoenix") { return .phoenix }
        if img.contains("jupyter") { return .jupyter }
        if img.contains("hugo") { return .hugo }
        if img.contains("storybook") { return .storybook }
        if img.contains("hono") { return .hono }
        if img.contains("redis") { return .redis }
        if img.contains("postgres") || img.contains("postgresql") { return .postgresql }
        if img.contains("mysql") || img.contains("mariadb") { return .mysql }
        if img.contains("mongo") { return .mongodb }
        if img.contains("nginx") { return .nginx }
        if img.contains("rabbitmq") { return .rabbitmq }
        if img.contains("kafka") { return .kafka }
        if img.contains("elasticsearch") || img.contains("elastic") { return .elasticsearch }
        if img.contains("minio") { return .minio }
        return nil
    }

    public static func == (lhs: DockerContainer, rhs: DockerContainer) -> Bool {
        lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.image == rhs.image
        && lhs.status == rhs.status
        && lhs.rawStatus == rhs.rawStatus
        && lhs.ports == rhs.ports
    }

    public init(
        id: String, name: String, image: String,
        status: ContainerStatus, rawStatus: String, ports: [PortMapping]
    ) {
        self.id = id
        self.name = name
        self.image = image
        self.status = status
        self.rawStatus = rawStatus
        self.ports = ports
    }

    /// Parses Docker's port string format, e.g.:
    /// "0.0.0.0:3000->3000/tcp, :::3000->3000/tcp, 0.0.0.0:5432->5432/tcp"
    /// Deduplicates by (hostPort, containerPort, proto) to collapse IPv4/IPv6 duplicates.
    public static func parsePorts(_ portsString: String) -> [PortMapping] {
        guard !portsString.isEmpty else { return [] }
        var seen = Set<PortMapping>()
        var result: [PortMapping] = []
        for segment in portsString.components(separatedBy: ", ") {
            for mapping in parseSegment(segment.trimmingCharacters(in: .whitespaces))
                where seen.insert(mapping).inserted {
                result.append(mapping)
            }
        }
        return result
    }

    /// Parses a single port segment like "0.0.0.0:3000->3000/tcp" or "0.0.0.0:9000-9001->9000-9001/tcp"
    private static func parseSegment(_ trimmed: String) -> [PortMapping] {
        guard !trimmed.isEmpty,
              let arrowRange = trimmed.range(of: "->") else { return [] }
        let leftPart = String(trimmed[trimmed.startIndex..<arrowRange.lowerBound])
        let rightPart = String(trimmed[arrowRange.upperBound...])
        guard let lastColon = leftPart.range(of: ":", options: .backwards) else { return [] }
        let hostPortString = String(leftPart[lastColon.upperBound...])
        let rightComponents = rightPart.components(separatedBy: "/")
        guard rightComponents.count == 2 else { return [] }
        let proto = rightComponents[1]
        if hostPortString.contains("-") {
            let hParts = hostPortString.components(separatedBy: "-")
            let cParts = rightComponents[0].components(separatedBy: "-")
            guard hParts.count >= 2, cParts.count >= 2,
                  let hStart = UInt16(hParts[0]), let hEnd = UInt16(hParts[1]),
                  let cStart = UInt16(cParts[0]), hEnd >= hStart else { return [] }
            let rangeCount = Int(hEnd) - Int(hStart)
            guard Int(cStart) + rangeCount <= Int(UInt16.max) else { return [] }
            return (0...rangeCount).map { offset in
                PortMapping(hostPort: hStart + UInt16(offset), containerPort: cStart + UInt16(offset), proto: proto)
            }
        }
        guard let hostPort = UInt16(hostPortString),
              let containerPort = UInt16(rightComponents[0]) else { return [] }
        return [PortMapping(hostPort: hostPort, containerPort: containerPort, proto: proto)]
    }
}
