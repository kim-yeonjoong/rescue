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

    private enum PanelLayout {
        static let baseHeight: CGFloat = 120
        static let rowHeight: CGFloat = 32
        static let sectionHeader: CGFloat = 50
        static let tableHeader: CGFloat = 30
        static let portsLoading: CGFloat = 100
        static let portsEmpty: CGFloat = 120
        static let portlessInstall: CGFloat = 80
        static let dockerSectionHeader: CGFloat = 80 // section title + table header
        static let dockerNotRunning: CGFloat = 60
        static let minHeight: CGFloat = 200
        static let maxHeight: CGFloat = 580
    }

    private var panelHeight: CGFloat {
        var height = PanelLayout.baseHeight

        let portCount = portListVM.filteredPorts.count
        if portListVM.ports.isEmpty {
            height += portListVM.isLoading ? PanelLayout.portsLoading : PanelLayout.portsEmpty
        } else {
            height += PanelLayout.tableHeader + CGFloat(portCount) * PanelLayout.rowHeight
        }

        if portlessEnabled && portListVM.enricher.isPortlessAvailable {
            height += PanelLayout.sectionHeader
            if portListVM.enricher.portlessRoutes.isEmpty {
                height += PanelLayout.tableHeader
            } else {
                height += PanelLayout.tableHeader + CGFloat(portListVM.filteredPortlessRoutes.count) * PanelLayout.rowHeight
            }
        } else if portlessEnabled {
            height += PanelLayout.portlessInstall
        }

        if dockerEnabled {
            if dockerVM.isDockerAvailable {
                let dockerRows = dockerVM.filteredContainers.reduce(0) { $0 + max($1.ports.count, 1) }
                height += PanelLayout.dockerSectionHeader + CGFloat(dockerRows) * PanelLayout.rowHeight
            } else if !dockerVM.isLoading {
                height += PanelLayout.dockerNotRunning
            }
        }

        return min(max(height, PanelLayout.minHeight), PanelLayout.maxHeight)
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
