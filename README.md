<p align="right">
  <a href="README.ko.md">한국어</a>
</p>

# Rescue

<p align="center">
  <img src="logo.svg" width="96" alt="Rescue" />
</p>

<p align="center">
  <strong>Find and manage the dev processes you forgot you started.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="macOS 14+" />
  <img src="https://img.shields.io/badge/swift-6.0%2B-orange?style=flat-square" alt="Swift 6.0+" />
  <a href="LICENSE"><img src="https://img.shields.io/github/license/kim-yeonjoong/rescue?style=flat-square" alt="MIT License" /></a>
</p>

<br />

> *You started it. Then forgot about it.*

Every dev session leaves behind orphaned processes: a Vite server from last night, a PostgreSQL container from last week, a Redis instance that should have been dead hours ago. They eat memory, hold ports hostage, and cause mysterious conflicts.

Rescue surfaces them all — so you can deal with them before they become a problem.

<p align="center">
  <img src="screenshots/screenshot1.png" width="360" alt="Rescue — Port list" />
  &nbsp;&nbsp;
  <img src="screenshots/screenshot2.png" width="360" alt="Rescue — Docker & portless" />
</p>

---

## Installation

### Download

1. Download `Rescue-macos.zip` from the [latest release](https://github.com/kim-yeonjoong/rescue/releases/latest)
2. Unzip and move `Rescue.app` to `/Applications`
3. On first launch, macOS will block the app because it is not signed with an Apple Developer ID. To allow it:
   ```bash
   xattr -d com.apple.quarantine /Applications/Rescue.app
   ```
   Or go to **System Settings → Privacy & Security → Security** and click **Open Anyway**.

### Build from source

```bash
git clone https://github.com/kim-yeonjoong/rescue.git
cd rescue/apps/rescue
swift build -c release
```

The built binary is at `.build/arm64-apple-macosx/release/Rescue`.

---

## Usage

Rescue lives in the menu bar.

Click the icon to open the panel:

- **Port list** — each row shows port, process name, framework icon, and uptime
  - Click the link icon to open in browser
  - Click the trash icon to stop the process (requires confirmation)
  - Right-click for more options (copy port, copy URL)
- **portless section** — shows hostname routes registered with [portless](https://github.com/vercel-labs/portless) (requires portless to be installed)
- **Docker section** — shows all containers; click to start / stop / restart
- **Search bar** — filters all sections simultaneously
- **Footer** — settings (gear) and quit (power) buttons

## Features

- **Port scanning** — lists all TCP LISTEN ports via `lsof`, updated on a configurable interval
- **Framework detection** — identifies 31 frameworks from process command line and port/name heuristics
- **Docker integration** — shows running containers with mapped ports; start, stop, and restart from the menu bar
- **portless integration** — displays hostname aliases from [portless](https://github.com/vercel-labs/portless) alongside each port
- **Process control** — kill any process directly from the menu bar
- **Browser open** — open `localhost:<port>` (or portless URL) in the default browser
- **Copy** — copy port number or full URL via right-click context menu
- **Port notifications** — system notification when a new port opens
- **Uptime tracking** — shows how long each port has been open
- **Search** — filter by port number, process name, framework, or URL
- **Sort** — sort by port, process name, or framework
- **Filters** — permanently hide specific processes or port numbers
- **Sleep / wake** — polling pauses on system sleep and resumes on wake

## Supported Frameworks

| Category | Frameworks |
| --- | --- |
| Frontend | Next.js, Vite, Angular, Vue CLI, Nuxt, Remix, Astro, SvelteKit, Storybook |
| Backend | Express, NestJS, Fastify, Hono, Django, Flask, FastAPI, Rails, Spring Boot, Phoenix |
| Infrastructure | Docker, Redis, PostgreSQL, MySQL, MongoDB, Nginx, RabbitMQ, Kafka, Elasticsearch, MinIO |
| Other | Hugo, Jupyter |

## Settings

| Setting | Default | Description |
| --- | --- | --- |
| Launch at Login | Off | Start Rescue automatically on login |
| Port Notifications | On | System alert when a new port opens |
| Refresh Interval | 2.5s | How often to scan for open ports (1–10s) |
| Language | System | English or Korean |
| Docker | On | Enable Docker container panel |
| portless | On | Enable portless hostname panel |
| Filters | — | Process names or port numbers to hide from the list |

Default hidden processes: `code helper`, `cursor helper`, `webstorm`, `intellij`, `google chrome`, `chromium`, `safari`, `firefox`, `arc helper`, `brave browser`, `github desktop`, `sourcetree`, `electron`, `slack helper`.

---

## Requirements

- macOS 14 Sonoma or later
- Xcode 16 or later (to build from source)
- Swift 6.0 or later

## Contributing

Contributions are welcome. Please open an issue before submitting a pull request for large changes.

```bash
cd apps/rescue

# Build
swift build

# Test
swift test

# Lint (requires SwiftLint)
swiftlint lint
```

### Project structure

```
apps/rescue/
  Sources/
    Rescue/          # SwiftUI app, views, view models, AppDelegate
    RescueCore/      # Models, services, shell executor (no UI dependency)
  Tests/
    RescueCoreTests/ # Unit tests for core services
```

`RescueCore` is a separate library target so services can be tested without the UI.

## License

[MIT License](LICENSE) © 2026 kim-yeonjoong
