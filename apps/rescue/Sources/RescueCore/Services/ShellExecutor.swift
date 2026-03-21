import Foundation

public protocol ShellExecuting: Sendable {
    func run(command: String, arguments: [String]) async -> ShellResult
}

public actor ShellExecutor: ShellExecuting {
    public init() {}

    public func run(command: String, arguments: [String]) async -> ShellResult {
        await Process.run(command: command, arguments: arguments)
    }
}
