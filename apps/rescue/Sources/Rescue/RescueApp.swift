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

    private var appLocale: Locale {
        appLanguage == "system" ? .autoupdatingCurrent : Locale(identifier: appLanguage)
    }

    private static let statusBarIcon: NSImage = {
        guard let url = Bundle.module.url(forResource: "statusbar-icon", withExtension: "svg"),
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
                .frame(width: 380, height: 500)
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
