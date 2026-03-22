import SwiftUI
import RescueCore

@main
struct RescueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @State private var portListVM: PortListViewModel
    @State private var dockerVM: DockerViewModel
    @State private var actionQueue: ActionResultQueue

    private static let defaultIgnoredProcesses = [
        "code helper", "cursor helper", "webstorm", "intellij",
        "google chrome", "chrome helper", "chromium",
        "safari", "firefox", "arc helper", "brave browser",
        "github desktop", "sourcetree",
        "electron helper", "electron",
        "slack helper"
    ]

    init() {
        // 최초 실행 시 기본 필터 목록 설정
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "ignoredProcessesInitialized") {
            defaults.set(Self.defaultIgnoredProcesses.joined(separator: ","), forKey: "ignoredProcesses")
            defaults.set(true, forKey: "ignoredProcessesInitialized")
        }

        let shell = ShellExecutor()
        let scanner = PortScanner(shell: shell)
        let detector = FrameworkDetector(shell: shell)
        let terminator = ProcessTerminator()
        let dockerManager = DockerManager(shell: shell)
        let portlessIntegrator = PortlessIntegrator(shell: shell)
        let queue = ActionResultQueue()
        let dockerVM = DockerViewModel(manager: dockerManager, actionQueue: queue)
        let enricher = PortEnricher(
            dockerVM: dockerVM,
            detector: detector,
            portlessIntegrator: portlessIntegrator
        )

        _actionQueue = State(initialValue: queue)
        _dockerVM = State(initialValue: dockerVM)
        _portListVM = State(initialValue: PortListViewModel(
            shell: shell,
            scanner: scanner,
            terminator: terminator,
            enricher: enricher,
            actionQueue: queue
        ))
    }

    @AppStorage("appLanguage") private var appLanguage: String = "system"
    @AppStorage(AppStorageKey.dockerEnabled) private var dockerEnabled: Bool = true
    @AppStorage(AppStorageKey.portlessEnabled) private var portlessEnabled: Bool = true

    private var appLocale: Locale {
        appLanguage == "system" ? .autoupdatingCurrent : Locale(identifier: appLanguage)
    }

    private var panelHeight: CGFloat {
        var height: CGFloat = 120 // header + search + dividers + footer

        let portCount = portListVM.filteredPorts.count
        if portListVM.ports.isEmpty {
            height += portListVM.isLoading ? 100 : 120
        } else {
            height += 30 + CGFloat(portCount) * 32
        }

        if portlessEnabled && portListVM.enricher.isPortlessAvailable {
            height += 50
            if portListVM.enricher.portlessRoutes.isEmpty {
                height += 30
            } else {
                height += 30 + CGFloat(portListVM.filteredPortlessRoutes.count) * 32
            }
        } else if portlessEnabled {
            height += 80
        }

        if dockerEnabled {
            if dockerVM.isDockerAvailable {
                let dockerRows = dockerVM.filteredContainers.reduce(0) { $0 + max($1.ports.count, 1) }
                height += 80 + CGFloat(dockerRows) * 32
            } else if !dockerVM.isLoading {
                height += 60
            }
        }

        return min(max(height, 200), 580)
    }

    private static let statusBarIcon: NSImage = {
        guard let url = Bundle.rescueResources.url(forResource: "statusbar-icon", withExtension: "svg"),
              let img = NSImage(contentsOf: url) else {
            return NSImage(systemSymbolName: "network", accessibilityDescription: nil)
                ?? NSImage()
        }
        img.size = NSSize(width: 18, height: 18)
        img.isTemplate = true
        return img
    }()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(portListVM: portListVM, dockerVM: dockerVM, actionQueue: actionQueue)
                .frame(width: 380, height: panelHeight)
                .environment(\.locale, appLocale)
        } label: {
            let count = portListVM.ports.count
            if count > 0 {
                Label {
                    Text("\(count)")
                } icon: {
                    Image(nsImage: Self.statusBarIcon)
                }
            } else {
                Label {
                    Text("Rescue")
                } icon: {
                    Image(nsImage: Self.statusBarIcon)
                }
            }
        }
        .menuBarExtraStyle(.window)

        Window("Rescue Settings", id: "settings") {
            SettingsView()
                .environment(\.locale, appLocale)
        }
        .defaultSize(width: 500, height: 340)
        .windowResizability(.contentSize)
    }
}
