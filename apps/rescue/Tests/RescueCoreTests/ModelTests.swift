import Foundation
import Testing
@testable import RescueCore

// MARK: - PortEntry

@Suite struct PortEntryTests {

    @Test func idComputedProperty() {
        let entry = PortEntry(port: 3000, pid: 1234, processName: "node")
        #expect(entry.id == "3000-1234")
    }
}

// MARK: - PortlessRoute

@Suite struct PortlessRouteTests {

    @Test func idComputedProperty() {
        let route = PortlessRoute(hostname: "myapp", port: 3000, processId: 100)
        #expect(route.id == "myapp-3000")
    }

    @Test func urlWithoutDotReturnsDotLocalhost() {
        let route = PortlessRoute(hostname: "myapp", port: 3000, processId: 100)
        #expect(route.url == "http://myapp.localhost")
    }

    @Test func urlWithDotReturnsPlainHostname() {
        let route = PortlessRoute(hostname: "myapp.example.com", port: 80, processId: 100)
        #expect(route.url == "http://myapp.example.com")
    }

    @Test func displayHostnameStripsLocalhost() {
        let route = PortlessRoute(hostname: "frontend.localhost", port: 3000, processId: 100)
        #expect(route.displayHostname == "frontend")
    }

    @Test func displayHostnameNoSuffix() {
        let route = PortlessRoute(hostname: "myapp", port: 3000, processId: 100)
        #expect(route.displayHostname == "myapp")
    }

    @Test func encodeToJSON() throws {
        let route = PortlessRoute(hostname: "api", port: 8080, processId: 999)
        let data = try JSONEncoder().encode(route)
        let dict = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(dict["hostname"] as? String == "api")
        #expect(dict["port"] as? Int == 8080)
        #expect(dict["processId"] as? Int == 999)
        #expect(dict["pid"] == nil)
    }

    @Test func decodeWithProcessIdKey() throws {
        let json = #"{"hostname":"svc","port":5000,"processId":42}"#
        let route = try JSONDecoder().decode(PortlessRoute.self, from: Data(json.utf8))
        #expect(route.hostname == "svc")
        #expect(route.port == 5000)
        #expect(route.processId == 42)
    }

    @Test func decodeWithPidFallbackKey() throws {
        let json = #"{"hostname":"svc","port":5000,"pid":77}"#
        let route = try JSONDecoder().decode(PortlessRoute.self, from: Data(json.utf8))
        #expect(route.hostname == "svc")
        #expect(route.port == 5000)
        #expect(route.processId == 77)
    }
}

// MARK: - DockerContainer

@Suite struct DockerContainerTests {

    @Test func displayStatusRunning() {
        let container = DockerContainer(id: "abc", name: "web", image: "nginx", status: .running, rawStatus: "Up 2 hours", ports: [])
        #expect(container.displayStatus == "Running")
    }

    // MARK: inferredFramework

    @Test func inferredFrameworkNextcloudNotNextjs() {
        let container = DockerContainer(id: "1", name: "cloud", image: "nextcloud/nextcloud", status: .running, rawStatus: "Up 1 hour", ports: [])
        #expect(container.inferredFramework != .nextjs)
    }

    @Test func inferredFrameworkNginx() {
        let container = DockerContainer(id: "2", name: "web", image: "nginx:latest", status: .running, rawStatus: "Up 1 hour", ports: [])
        #expect(container.inferredFramework == .nginx)
    }

    @Test func inferredFrameworkCaddy() {
        let container = DockerContainer(id: "c1", name: "proxy", image: "caddy:2-alpine", status: .running, rawStatus: "Up 1 hour", ports: [])
        #expect(container.inferredFramework == .caddy)
    }

    @Test func inferredFrameworkNilForGenericNode() {
        let container = DockerContainer(id: "3", name: "app", image: "node:18-alpine", status: .running, rawStatus: "Up 1 hour", ports: [])
        #expect(container.inferredFramework == nil)
    }

    // MARK: uptimeString

    @Test func uptimeString37Hours() {
        let container = DockerContainer(id: "4", name: "app", image: "node", status: .running, rawStatus: "Up 37 hours", ports: [])
        #expect(container.uptimeString == "37h")
    }

    @Test func uptimeStringAboutAnHour() {
        let container = DockerContainer(id: "5", name: "app", image: "node", status: .running, rawStatus: "Up About an hour", ports: [])
        #expect(container.uptimeString == "1h")
    }

    @Test func uptimeString5Minutes() {
        let container = DockerContainer(id: "6", name: "app", image: "node", status: .running, rawStatus: "Up 5 minutes", ports: [])
        #expect(container.uptimeString == "5m")
    }

    @Test func uptimeString2Days() {
        let container = DockerContainer(id: "7", name: "app", image: "node", status: .running, rawStatus: "Up 2 days", ports: [])
        #expect(container.uptimeString == "2d")
    }

    @Test func uptimeStringNilWhenNotRunning() {
        let container = DockerContainer(id: "8", name: "app", image: "node", status: .exited, rawStatus: "Exited (0) 1 hour ago", ports: [])
        #expect(container.uptimeString == nil)
    }

    @Test func statusDisplayTextRunning() {
        #expect(DockerContainer.ContainerStatus.running.displayText == "Running")
    }

    @Test func statusDisplayTextExited() {
        #expect(DockerContainer.ContainerStatus.exited.displayText == "Exited")
    }

    @Test func statusDisplayTextPaused() {
        #expect(DockerContainer.ContainerStatus.paused.displayText == "Paused")
    }

    @Test func statusDisplayTextOther() {
        #expect(DockerContainer.ContainerStatus.other("Restarting").displayText == "Restarting")
    }
}

// MARK: - DevFramework

@Suite struct DevFrameworkTests {

    @Test func displayNames() {
        let expectations: [(DevFramework, String)] = [
            (.nextjs, "Next.js"),
            (.vite, "Vite"),
            (.angular, "Angular"),
            (.vueCli, "Vue CLI"),
            (.nuxt, "Nuxt"),
            (.remix, "Remix"),
            (.astro, "Astro"),
            (.sveltekit, "SvelteKit"),
            (.django, "Django"),
            (.flask, "Flask"),
            (.fastapi, "FastAPI"),
            (.rails, "Rails"),
            (.express, "Express"),
            (.nestjs, "NestJS"),
            (.fastify, "Fastify"),
            (.springBoot, "Spring Boot"),
            (.phoenix, "Phoenix"),
            (.hugo, "Hugo"),
            (.jupyter, "Jupyter"),
            (.storybook, "Storybook"),
            (.hono, "Hono"),
            (.docker, "Docker"),
            (.redis, "Redis"),
            (.postgresql, "Postgres"),
            (.mysql, "MySQL"),
            (.mongodb, "MongoDB"),
            (.nginx, "Nginx"),
            (.caddy, "Caddy"),
            (.rabbitmq, "RabbitMQ"),
            (.kafka, "Kafka"),
            (.elasticsearch, "Elasticsearch"),
            (.minio, "MinIO"),
        ]
        for (framework, expected) in expectations {
            #expect(framework.displayName == expected, "displayName for \(framework) should be \(expected)")
        }
    }

    @Test func iconResources() {
        let expectations: [(DevFramework, String)] = [
            (.nextjs, "nextjs"),
            (.vite, "vite"),
            (.angular, "angular"),
            (.vueCli, "vuecli"),
            (.nuxt, "nuxt"),
            (.remix, "remix"),
            (.astro, "astro"),
            (.sveltekit, "sveltekit"),
            (.django, "django"),
            (.flask, "flask"),
            (.fastapi, "fastapi"),
            (.rails, "rails"),
            (.express, "express"),
            (.nestjs, "nestjs"),
            (.fastify, "fastify"),
            (.springBoot, "springboot"),
            (.phoenix, "phoenix"),
            (.hugo, "hugo"),
            (.jupyter, "jupyter"),
            (.storybook, "storybook"),
            (.hono, "hono"),
            (.docker, "docker"),
            (.redis, "redis"),
            (.postgresql, "postgresql"),
            (.mysql, "mysql"),
            (.mongodb, "mongodb"),
            (.nginx, "nginx"),
            (.caddy, "caddy"),
            (.rabbitmq, "rabbitmq"),
            (.kafka, "apachekafka"),
            (.elasticsearch, "elasticsearch"),
            (.minio, "minio"),
        ]
        for (framework, expected) in expectations {
            #expect(framework.iconResource == expected, "iconResource for \(framework) should be \(expected)")
        }
    }

    @Test func allCasesCovered() {
        #expect(DevFramework.allCases.count == 32)
    }

    @Test func icons() {
        let expectations: [(DevFramework, String)] = [
            (.nextjs, "triangle.fill"),
            (.vite, "bolt.fill"),
            (.angular, "shield.fill"),
            (.vueCli, "v.circle.fill"),
            (.nuxt, "n.circle.fill"),
            (.remix, "r.circle.fill"),
            (.astro, "star.fill"),
            (.sveltekit, "flame.fill"),
            (.django, "d.circle.fill"),
            (.flask, "flask.fill"),
            (.fastapi, "gauge.high"),
            (.rails, "train.side.front.car"),
            (.express, "e.circle.fill"),
            (.nestjs, "cat.fill"),
            (.fastify, "hare.fill"),
            (.springBoot, "leaf.fill"),
            (.phoenix, "bird.fill"),
            (.hugo, "h.circle.fill"),
            (.jupyter, "j.circle.fill"),
            (.storybook, "book.fill"),
            (.hono, "flame"),
            (.docker, "shippingbox.fill"),
            (.redis, "memorychip.fill"),
            (.postgresql, "externaldrive.fill"),
            (.mysql, "externaldrive.fill"),
            (.mongodb, "leaf.fill"),
            (.nginx, "server.rack"),
            (.caddy, "server.rack"),
            (.rabbitmq, "envelope.fill"),
            (.kafka, "arrow.triangle.branch"),
            (.elasticsearch, "magnifyingglass"),
            (.minio, "externaldrive.fill"),
        ]
        for (framework, expected) in expectations {
            #expect(framework.icon == expected, "icon for \(framework) should be \(expected)")
        }
    }
}

// MARK: - CaddyRoute

@Suite struct CaddyRouteTests {

    @Test func idComputedProperty() {
        let route = CaddyRoute(hostname: "app.localhost", upstreamPort: 3000)
        #expect(route.id == "app.localhost-3000")
    }

    @Test func urlWithDotReturnsHttps() {
        let route = CaddyRoute(hostname: "app.example.com", upstreamPort: 3000)
        #expect(route.url == "https://app.example.com")
    }

    @Test func urlWithoutDotReturnsDotLocalhost() {
        let route = CaddyRoute(hostname: "myapp", upstreamPort: 3000)
        #expect(route.url == "https://myapp.localhost")
    }

    @Test func displayHostnameStripsLocalhost() {
        let route = CaddyRoute(hostname: "frontend.localhost", upstreamPort: 3000)
        #expect(route.displayHostname == "frontend")
    }

    @Test func displayHostnameNoSuffix() {
        let route = CaddyRoute(hostname: "myapp", upstreamPort: 3000)
        #expect(route.displayHostname == "myapp")
    }

    @Test func defaultUpstreamHostIsLocalhost() {
        let route = CaddyRoute(hostname: "api", upstreamPort: 8080)
        #expect(route.upstreamHost == "localhost")
    }

    @Test func customUpstreamHost() {
        let route = CaddyRoute(hostname: "api", upstreamPort: 8080, upstreamHost: "backend")
        #expect(route.upstreamHost == "backend")
    }
}
