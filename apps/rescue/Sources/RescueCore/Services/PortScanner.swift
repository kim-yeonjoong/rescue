import Foundation
import os

public struct PortScanner: Sendable {
    private let shell: any ShellExecuting

    public init(shell: any ShellExecuting) {
        self.shell = shell
    }

    public func scan() async -> [PortEntry] {
        let result = await shell.run(
            command: "lsof",
            arguments: ["-iTCP", "-sTCP:LISTEN", "-nP", "-F", "pcn"]
        )
        guard result.succeeded else {
            RescueLogger.portScanner.error("Port scan failed: \(result.stderr)")
            return []
        }
        return parse(result.stdout)
    }

    private func parse(_ output: String) -> [PortEntry] {
        var entries: [PortEntry] = []
        var seen: Set<String> = []

        var currentPID: Int32?
        var currentCommand: String?

        let lines = output.components(separatedBy: "\n")
        for line in lines {
            guard let prefix = line.first else { continue }
            let value = String(line.dropFirst())

            switch prefix {
            case "p":
                currentPID = Int32(value)
                // 'c' line follows 'p' in lsof -F output, reset command
                currentCommand = nil
            case "c":
                currentCommand = value
            case "n":
                guard let pid = currentPID, let command = currentCommand else { continue }
                if let port = extractPort(from: value) {
                    let key = "\(port)-\(pid)"
                    if !seen.contains(key) {
                        seen.insert(key)
                        entries.append(PortEntry(port: port, pid: pid, processName: command))
                    }
                }
            default:
                break
            }
        }

        return entries.sorted { $0.port < $1.port }
    }

    private func extractPort(from nameField: String) -> UInt16? {
        // Matches both IPv4 `*:3000` and IPv6 `[::]:3000` forms
        // Port is at end of string after last ':'
        guard let colonRange = nameField.range(of: ":", options: .backwards) else { return nil }
        let portString = String(nameField[colonRange.upperBound...])
        guard let port = UInt16(portString) else { return nil }
        return port
    }
}
