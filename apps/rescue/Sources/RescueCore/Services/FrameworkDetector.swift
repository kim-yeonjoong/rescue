import Foundation
import os

public struct FrameworkDetector: Sendable {
    private let shell: any ShellExecuting

    public init(shell: any ShellExecuting) {
        self.shell = shell
    }

    public func detect(port: UInt16, pid: Int32, processName: String) async -> DevFramework? {
        // Stage 1: command-based detection
        let result = await shell.run(command: "ps", arguments: ["-p", "\(pid)", "-o", "command="])
        if result.succeeded {
            let rawCommand = result.stdout
            let command = rawCommand.lowercased()
            if let framework = matchCommand(command) {
                RescueLogger.framework.debug("Detected \(String(describing: framework)) for port \(port)")
                return framework
            }
            // Stage 1.5: compiled NestJS (dist/main) — check for nest-cli.json
            if command.contains("dist/main"), isNestJsProject(command: rawCommand) {
                RescueLogger.framework.debug("Detected NestJS (compiled) for port \(port)")
                return .nestjs
            }
        }

        // Stage 2: port + process name fallback
        let processNameLower = processName.lowercased()
        RescueLogger.framework.debug("No command match, using port-based fallback for :\(port)/\(processNameLower)")
        return fallback(port: port, processName: processNameLower)
    }

    private func isNestJsProject(command: String) -> Bool {
        // Split by spaces and find the argument that contains /dist/
        let args = command.components(separatedBy: " ").filter { !$0.isEmpty }
        guard let distArg = args.first(where: { $0.contains("/dist/") }),
              let distRange = distArg.range(of: "/dist/") else { return false }
        let projectDir = String(distArg[distArg.startIndex..<distRange.lowerBound])
        let resolved = NSString(string: projectDir).standardizingPath
        guard !resolved.contains("..") else { return false }
        return FileManager.default.fileExists(atPath: resolved + "/nest-cli.json")
    }

    // MARK: - Private

    // Order matters: first match wins. Place more specific patterns before generic ones
    // (e.g. "nestjs" before "node_modules/express").
    private static let commandPatterns: [(String, DevFramework)] = [
        (".bin/next", .nextjs), ("node_modules/next/", .nextjs),
        ("svelte-kit", .sveltekit), ("sveltekit", .sveltekit),
        ("angular", .angular), ("ng serve", .angular),
        ("vue-cli", .vueCli), ("@vue/cli", .vueCli),
        ("nuxt", .nuxt),
        ("remix", .remix),
        ("astro", .astro),
        ("vite", .vite),
        ("manage.py", .django),
        ("flask", .flask),
        ("uvicorn", .fastapi), ("fastapi", .fastapi),
        ("rails", .rails), ("puma", .rails),
        ("nestjs", .nestjs), (".bin/nest", .nestjs),
        ("fastify", .fastify),
        ("node_modules/express", .express), (".bin/express", .express),
        ("spring", .springBoot), ("bootrun", .springBoot),
        ("phoenix", .phoenix), ("mix phx", .phoenix),
        ("hugo", .hugo),
        ("jupyter", .jupyter),
        ("storybook", .storybook),
        ("hono", .hono),
    ]

    private func matchCommand(_ command: String) -> DevFramework? {
        // Skip JVM processes to prevent false positives (e.g. "express" in classpath)
        if command.hasPrefix("java ") || (command.hasPrefix("/") && command.contains("/java ")) ||
           command.contains(" -jar ") || command.contains(" -cp ") || command.contains(" -classpath ") {
            // Allow Spring Boot detection even for JVM processes
            if command.contains("spring") || command.contains("bootrun") {
                return .springBoot
            }
            return nil
        }
        return Self.commandPatterns.first { command.contains($0.0) }?.1
    }

    private func fallback(port: UInt16, processName: String) -> DevFramework? {
        switch (port, processName) {
        case (4200, "node"):   return .angular
        case (5173, "node"):   return .vite
        case (8000, "python"): return .django
        case (5000, "python"): return .flask
        case (8888, "python"): return .jupyter
        case (4000, "beam"):   return .phoenix
        case (1313, "hugo"):   return .hugo
        case (6006, "node"):   return .storybook
        default:               return nil
        }
    }
}
