public enum DevFramework: String, Sendable, CaseIterable {
    case nextjs, vite, angular, vueCli, nuxt, remix, astro, sveltekit
    case django, flask, fastapi, rails, express, nestjs, fastify, springBoot
    case phoenix, hugo, jupyter, storybook, hono, docker, redis
    case postgresql, mysql, mongodb, nginx, rabbitmq, kafka, elasticsearch, minio

    public var displayName: String { info.displayName }
    /// Resource filename for Simple Icons SVG (without extension)
    public var iconResource: String { info.iconResource }
    /// SF Symbol fallback icon
    public var icon: String { info.icon }
    /// Color hint for UI rendering
    /// Brand hex color from Simple Icons (nil for black/near-black brands → uses .primary)
    public var brandHex: String? { info.brandHex }

    private var info: FrameworkInfo {
        switch self {
        case .nextjs:        return FrameworkInfo("Next.js",       "nextjs",        "triangle.fill",          nil)
        case .vite:          return FrameworkInfo("Vite",          "vite",          "bolt.fill",              "#646CFF")
        case .angular:       return FrameworkInfo("Angular",       "angular",       "shield.fill",            nil)
        case .vueCli:        return FrameworkInfo("Vue CLI",       "vuecli",        "v.circle.fill",          "#4FC08D")
        case .nuxt:          return FrameworkInfo("Nuxt",          "nuxt",          "n.circle.fill",          "#00DC82")
        case .remix:         return FrameworkInfo("Remix",         "remix",         "r.circle.fill",          nil)
        case .astro:         return FrameworkInfo("Astro",         "astro",         "star.fill",              "#BC52EE")
        case .sveltekit:     return FrameworkInfo("SvelteKit",     "sveltekit",     "flame.fill",             "#FF3E00")
        case .django:        return FrameworkInfo("Django",        "django",        "d.circle.fill",          nil)
        case .flask:         return FrameworkInfo("Flask",         "flask",         "flask.fill",             nil)
        case .fastapi:       return FrameworkInfo("FastAPI",       "fastapi",       "gauge.high",             "#009688")
        case .rails:         return FrameworkInfo("Rails",         "rails",         "train.side.front.car",   "#D30001")
        case .express:       return FrameworkInfo("Express",       "express",       "e.circle.fill",          nil)
        case .nestjs:        return FrameworkInfo("NestJS",        "nestjs",        "cat.fill",               "#E0234E")
        case .fastify:       return FrameworkInfo("Fastify",       "fastify",       "hare.fill",              nil)
        case .springBoot:    return FrameworkInfo("Spring Boot",   "springboot",    "leaf.fill",              "#6DB33F")
        case .phoenix:       return FrameworkInfo("Phoenix",       "phoenix",       "bird.fill",              "#FD4F00")
        case .hugo:          return FrameworkInfo("Hugo",          "hugo",          "h.circle.fill",          "#FF4088")
        case .jupyter:       return FrameworkInfo("Jupyter",       "jupyter",       "j.circle.fill",          "#F37626")
        case .storybook:     return FrameworkInfo("Storybook",     "storybook",     "book.fill",              "#FF4785")
        case .hono:          return FrameworkInfo("Hono",          "hono",          "flame",                  "#E36002")
        case .docker:        return FrameworkInfo("Docker",        "docker",        "shippingbox.fill",       "#2496ED")
        case .redis:         return FrameworkInfo("Redis",         "redis",         "memorychip.fill",        "#FF4438")
        case .postgresql:    return FrameworkInfo("Postgres",      "postgresql",    "externaldrive.fill",     "#4169E1")
        case .mysql:         return FrameworkInfo("MySQL",         "mysql",         "externaldrive.fill",     "#4479A1")
        case .mongodb:       return FrameworkInfo("MongoDB",       "mongodb",       "leaf.fill",              "#47A248")
        case .nginx:         return FrameworkInfo("Nginx",         "nginx",         "server.rack",            "#009639")
        case .rabbitmq:      return FrameworkInfo("RabbitMQ",      "rabbitmq",      "envelope.fill",          "#FF6600")
        case .kafka:         return FrameworkInfo("Kafka",         "apachekafka",   "arrow.triangle.branch",  nil)
        case .elasticsearch: return FrameworkInfo("Elasticsearch", "elasticsearch", "magnifyingglass",        "#005571")
        case .minio:         return FrameworkInfo("MinIO",         "minio",         "externaldrive.fill",     "#C72E49")
        }
    }
}

private struct FrameworkInfo {
    let displayName: String
    let iconResource: String
    let icon: String
    let brandHex: String?

    init(_ displayName: String, _ iconResource: String, _ icon: String, _ brandHex: String?) {
        self.displayName = displayName
        self.iconResource = iconResource
        self.icon = icon
        self.brandHex = brandHex
    }
}
