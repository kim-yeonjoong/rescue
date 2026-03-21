import RescueCore

public actor MockShellExecutor: ShellExecuting {
    private var responses: [String: ShellResult] = [:]

    public init() {}

    public func register(command: String, result: ShellResult) {
        responses[command] = result
    }

    public func run(command: String, arguments: [String]) async -> ShellResult {
        let key = ([command] + arguments).joined(separator: " ")
        return responses[key] ?? ShellResult(
            exitCode: 1,
            stdout: "",
            stderr: "No mock registered for: \(key)"
        )
    }
}
