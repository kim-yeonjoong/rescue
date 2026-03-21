import SwiftUI
import ServiceManagement

enum AppStorageKey {
    static let appLanguage = "appLanguage"
    static let pollingInterval = "pollingInterval"
    static let portNotificationsEnabled = "portNotificationsEnabled"
    static let dockerEnabled = "dockerEnabled"
    static let portlessEnabled = "portlessEnabled"
    static let ignoredProcesses = "ignoredProcesses"
}

struct SettingsView: View {
    @AppStorage(AppStorageKey.appLanguage) private var appLanguage: String = "system"
    @AppStorage(AppStorageKey.pollingInterval) private var pollingInterval: Double = 2.5
    @AppStorage(AppStorageKey.portNotificationsEnabled) private var portNotificationsEnabled: Bool = true
    @AppStorage(AppStorageKey.dockerEnabled) private var dockerEnabled: Bool = true
    @AppStorage(AppStorageKey.portlessEnabled) private var portlessEnabled: Bool = true
    @AppStorage(AppStorageKey.ignoredProcesses) private var ignoredProcessesRaw: String = ""
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled
    @State private var launchAtLoginError: String?
    @State private var newIgnoreTerm: String = ""

    private var ignoredList: [String] {
        ignoredProcessesRaw
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
    }

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            filtersTab
                .tabItem {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                }

            integrationsTab
                .tabItem {
                    Label("Integrations", systemImage: "puzzlepiece")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 500, height: 340)
    }

    // MARK: - General

    private var generalTab: some View {
        Form {
            Section {
                Toggle(isOn: $launchAtLogin) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Launch at Login")
                        if let launchAtLoginError {
                            Text(launchAtLoginError)
                                .font(.caption2)
                                .foregroundStyle(.red)
                        } else {
                            Text("Start Rescue automatically when you log in")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .onChange(of: launchAtLogin) { _, enabled in
                    launchAtLoginError = nil
                    do {
                        if enabled {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        launchAtLogin = !enabled
                        launchAtLoginError = String(localized: "Needs a signed app bundle")
                    }
                }
            }

            Section {
                Toggle(isOn: $portNotificationsEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Port Notifications")
                        Text("Alerts you when a new port opens")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Section {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Refresh interval")
                        Spacer()
                        Text("\(pollingInterval, specifier: "%.1f")s")
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(.secondary)
                    }
                    Slider(value: $pollingInterval, in: 1...10, step: 0.5)
                    Text("How often to check for open ports")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Section {
                Picker("Language", selection: $appLanguage) {
                    Text("Use System Language").tag("system")
                    Text(verbatim: "English").tag("en")
                    Text(verbatim: "한국어").tag("ko")
                }
                .pickerStyle(.menu)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }

    // MARK: - Filters

    private var filtersTab: some View {
        Form {
            Section {
                if ignoredList.isEmpty {
                    Text("No hidden items yet")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                } else {
                    ForEach(ignoredList, id: \.self) { term in
                        HStack {
                            Text(term)
                                .font(.system(.caption, design: .monospaced))
                            Spacer()
                            Button {
                                removeTerm(term)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(.red)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } header: {
                Text("Processes / Ports to Hide")
            } footer: {
                Text("Add a process (e.g. node) or port (e.g. 5432) to hide from the list.")
                    .font(.caption2)
            }

            Section {
                HStack(spacing: 8) {
                    TextField("Process name or port", text: $newIgnoreTerm)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { addTerm() }
                    Button("Add") { addTerm() }
                        .disabled(newIgnoreTerm.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .formStyle(.grouped)
    }

    private func addTerm() {
        let term = newIgnoreTerm.trimmingCharacters(in: .whitespaces).lowercased()
        guard !term.isEmpty, !ignoredList.contains(term) else { return }
        var list = ignoredList
        list.append(term)
        ignoredProcessesRaw = list.joined(separator: ",")
        newIgnoreTerm = ""
    }

    private func removeTerm(_ term: String) {
        var list = ignoredList
        list.removeAll { $0 == term }
        ignoredProcessesRaw = list.joined(separator: ",")
    }

    // MARK: - Integrations

    private var integrationsTab: some View {
        Form {
            Section {
                Toggle(isOn: $dockerEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Docker")
                        Text("View and manage running containers")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                Toggle(isOn: $portlessEnabled) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("portless")
                        Text("Access local dev servers by name")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
        .formStyle(.grouped)
    }

    // MARK: - About

    private static var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            ?? Bundle.main.infoDictionary?["CFBundleVersion"] as? String
            ?? "0.1.0"
    }

    private var aboutTab: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "network")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            VStack(spacing: 4) {
                Text("Rescue")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Dev port manager for macOS")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text("v\(Self.appVersion)")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            Divider()
                .frame(width: 200)

            VStack(spacing: 4) {
                Text("Released under the MIT License")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("Icons by Simple Icons (CC0 1.0)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
