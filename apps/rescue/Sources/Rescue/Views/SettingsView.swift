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
                    Label { Text("General") } icon: { LucideIconView(.settings) }
                }

            filtersTab
                .tabItem {
                    Label { Text("Filters") } icon: { LucideIconView(.slidersHorizontal) }
                }

            integrationsTab
                .tabItem {
                    Label { Text("Integrations") } icon: { LucideIconView(.puzzle) }
                }

            aboutTab
                .tabItem {
                    Label { Text("About") } icon: { LucideIconView(.info) }
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
                VStack(alignment: .leading, spacing: 8) {
                    Text("Add a process name or port number to hide from the list.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 6) {
                        TextField("", text: $newIgnoreTerm, prompt: Text("e.g. node, 5432"))
                            .textFieldStyle(.roundedBorder)
                            .onSubmit { addTerm() }
                        let isNewIgnoreTermEmpty = newIgnoreTerm.trimmingCharacters(in: .whitespaces).isEmpty
                        Button {
                            addTerm()
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white)
                                .frame(width: 22, height: 22)
                                .background(isNewIgnoreTermEmpty ? Color.secondary : Color.accentColor)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                        }
                        .buttonStyle(.plain)
                        .disabled(isNewIgnoreTermEmpty)
                    }
                }

                if ignoredList.isEmpty {
                    Text("No hidden items yet")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 4)
                } else {
                    ForEach(ignoredList, id: \.self) { term in
                        HStack(spacing: 6) {
                            Text(term)
                                .font(.system(.caption, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.primary.opacity(0.06))
                                .clipShape(Capsule())
                            Spacer()
                            Button {
                                withAnimation { removeTerm(term) }
                            } label: {
                                LucideIconView(.circleMinus, size: 14)
                                    .foregroundStyle(.red.opacity(0.7))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } header: {
                Text("Processes / Ports to Hide")
            }
        }
        .formStyle(.grouped)
        .labelsHidden()
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

            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 64, height: 64)

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

            if let githubURL = URL(string: "https://github.com/kim-yeonjoong/rescue") {
                Link(destination: githubURL) {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.right.square")
                        Text("View on GitHub")
                    }
                    .font(.caption)
                }
            }

            Divider()
                .frame(width: 200)

            VStack(spacing: 4) {
                Text("Released under the MIT License")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("Icons by Simple Icons (CC0 1.0)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Text("UI icons by Lucide (ISC)")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
