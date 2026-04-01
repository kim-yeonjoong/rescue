import os

public enum RescueLogger {
    public static let app = Logger(subsystem: "dev.rescue", category: "App")
    public static let portScanner = Logger(subsystem: "dev.rescue", category: "PortScanner")
    public static let docker = Logger(subsystem: "dev.rescue", category: "Docker")
    public static let portless = Logger(subsystem: "dev.rescue", category: "Portless")
    public static let caddy = Logger(subsystem: "dev.rescue", category: "Caddy")
    public static let process = Logger(subsystem: "dev.rescue", category: "Process")
    public static let framework = Logger(subsystem: "dev.rescue", category: "Framework")
    public static let terminator = Logger(subsystem: "dev.rescue", category: "Terminator")
}
