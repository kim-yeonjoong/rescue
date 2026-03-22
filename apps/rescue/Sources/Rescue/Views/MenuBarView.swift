import SwiftUI
import RescueCore

struct MenuBarView: View {
    @Bindable var portListVM: PortListViewModel
    let dockerVM: DockerViewModel
    let actionQueue: ActionResultQueue
    @State private var sharedSearchText = ""
    @State private var searchDebounceTask: Task<Void, Never>?
    @State private var isManualRefreshing = false
    @State private var refreshRotation: Double = 0
    @AppStorage(AppStorageKey.pollingInterval) private var pollingInterval: Double = Constants.defaultPollingInterval
    @AppStorage(AppStorageKey.dockerEnabled) private var dockerEnabled: Bool = true
    @AppStorage(AppStorageKey.portlessEnabled) private var portlessEnabled: Bool = true
    @AppStorage(AppStorageKey.ignoredProcesses) private var ignoredProcessesRaw: String = ""
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Action result banner
            if let result = actionQueue.current {
                HStack(spacing: 6) {
                    LucideIconView(result.isError ? .circleAlert : .circleCheck, size: 12)
                    Text(result.message)
                        .font(.caption)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((result.isError ? Color.red : Color.green).opacity(0.12))
                .foregroundStyle(result.isError ? .red : .primary)
                .clipShape(Capsule())
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // Header
            HStack {
                Text("Rescue")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                if !portListVM.ports.isEmpty {
                    Text("\(portListVM.ports.count) port\(portListVM.ports.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Button {
                    guard !isManualRefreshing else { return }
                    isManualRefreshing = true
                    withAnimation(.linear(duration: 0.5)) {
                        refreshRotation += 360
                    }
                    Task {
                        defer { isManualRefreshing = false }
                        if dockerEnabled { await dockerVM.refresh() }
                        await portListVM.refresh()
                    }
                } label: {
                    LucideIconView(.refreshCw, size: 11)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(refreshRotation))
                }
                .buttonStyle(.plain)
                .disabled(isManualRefreshing)
                .help("Refresh now")
            }
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Search
            HStack(spacing: 6) {
                LucideIconView(.search, size: 11)
                    .foregroundStyle(.tertiary)
                TextField("Search ports or containers…", text: $sharedSearchText)
                    .textFieldStyle(.plain)
                    .font(.caption)
                if !sharedSearchText.isEmpty {
                    Button {
                        sharedSearchText = ""
                        portListVM.searchText = ""
                        dockerVM.searchText = ""
                    } label: {
                        LucideIconView(.xCircle, size: 11)
                            .foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.primary.opacity(0.03))
            .onChange(of: sharedSearchText) { _, newValue in
                searchDebounceTask?.cancel()
                searchDebounceTask = Task {
                    try? await Task.sleep(for: Constants.searchDebounceDelay)
                    if !Task.isCancelled {
                        portListVM.searchText = newValue
                        dockerVM.searchText = newValue
                    }
                }
            }

            Divider()

            // Content
            ScrollView {
                LazyVStack(spacing: 0) {
                    PortListView(viewModel: portListVM)
                    if portlessEnabled {
                        PortlessSectionView(viewModel: portListVM)
                    }
                    if dockerEnabled {
                        DockerSectionView(viewModel: dockerVM)
                    }
                }
            }

            Divider()

            // Footer
            HStack {
                Button {
                    openWindow(id: "settings")
                    NSApp.activate(ignoringOtherApps: true)
                } label: {
                    Label { Text("Settings") } icon: { LucideIconView(.settings) }
                }
                .buttonStyle(.plain)

                Spacer()

                Button {
                    NSApplication.shared.terminate(nil)
                } label: {
                    Label { Text("Quit") } icon: { LucideIconView(.power) }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .animation(.easeInOut(duration: 0.2), value: actionQueue.current?.id)
        .task {
            applyPortListSettings()
            portListVM.startPolling(interval: pollingInterval)
            if dockerEnabled {
                dockerVM.startPolling(interval: pollingInterval * Constants.dockerPollingMultiplier)
            }
        }
        .onChange(of: pollingInterval) { _, newValue in
            portListVM.startPolling(interval: newValue)
            if dockerEnabled {
                dockerVM.startPolling(interval: newValue * Constants.dockerPollingMultiplier)
            }
        }
        .onChange(of: dockerEnabled) { _, enabled in
            if enabled {
                dockerVM.startPolling(interval: pollingInterval * Constants.dockerPollingMultiplier)
            } else {
                dockerVM.stopPolling()
            }
        }
        .onChange(of: portlessEnabled) { _, _ in applyPortListSettings() }
        .onChange(of: dockerVM.containers) { _, _ in
            portListVM.reenrichPorts()
        }
        .onChange(of: ignoredProcessesRaw) { _, _ in applyPortListSettings() }
        .onDisappear {
            portListVM.stopPolling()
            dockerVM.stopPolling()
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.willSleepNotification)) { _ in
            portListVM.stopPolling()
            dockerVM.stopPolling()
        }
        .onReceive(NSWorkspace.shared.notificationCenter.publisher(for: NSWorkspace.didWakeNotification)) { _ in
            portListVM.startPolling(interval: pollingInterval)
            if dockerEnabled { dockerVM.startPolling(interval: pollingInterval * Constants.dockerPollingMultiplier) }
        }
    }

    private func applyPortListSettings() {
        portListVM.enricher.portlessEnabled = portlessEnabled
        portListVM.ignoredProcesses = Self.parseIgnored(ignoredProcessesRaw)
    }

    private static func parseIgnored(_ raw: String) -> Set<String> {
        Set(raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
            .filter { !$0.isEmpty })
    }
}
