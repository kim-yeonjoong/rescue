import SwiftUI
import RescueCore

struct PortRowView: View {
    let entry: PortEntry
    let viewModel: PortListViewModel
    @State private var pendingKill = false
    @State private var pendingKillTask: Task<Void, Never>?
    @State private var showCopied = false
    @State private var showKilled = false
    @State private var isBrowserHovered = false
    @State private var isStopHovered = false
    @State private var copiedTask: Task<Void, Never>?
    @State private var killFeedbackTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: 0) {
            // Port column
            PortCell(port: entry.port)

            // Process column
            VStack(alignment: .leading, spacing: 1) {
                Text(viewModel.enricher.displayProcessName(for: entry))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let uptime = viewModel.uptimeString(for: entry.port) {
                    Text(uptime)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(width: 140, alignment: .leading)

            // Framework column
            if let fw = viewModel.enricher.effectiveFramework(for: entry) {
                HStack(spacing: 3) {
                    FrameworkIconView(framework: fw, color: fw.color)
                    Text(fw.displayName)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .lineLimit(1)
                }
                .padding(.horizontal, 5)
                .padding(.vertical, 2)
                .background(fw.color.opacity(0.12))
                .foregroundStyle(fw.color)
                .clipShape(Capsule())
            }

            Spacer()

            // Feedback
            if showKilled {
                Text("Killed")
                    .font(.caption2)
                    .foregroundStyle(.red)
                    .transition(.opacity)
            } else if showCopied {
                Text("Copied")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                    .transition(.opacity)
            }

            // Actions
            HStack(spacing: 6) {
                if !pendingKill {
                    Button {
                        viewModel.openInBrowser(entry: entry)
                    } label: {
                        LucideIconView(.externalLink, size: 12)
                            .foregroundStyle(isBrowserHovered ? Color.accentColor : Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .onHover { isBrowserHovered = $0 }
                    .help("Open in Browser")
                    .accessibilityLabel("Open in browser")
                }

                if viewModel.isKilling.contains(entry.id) {
                    ProgressView()
                        .controlSize(.mini)
                        .frame(width: 12)
                } else if pendingKill {
                    Button {
                        pendingKill = false
                        killFeedbackTask?.cancel()
                        killFeedbackTask = Task {
                            await viewModel.killProcess(entry: entry)
                            withAnimation { showKilled = true }
                            try? await Task.sleep(for: Constants.feedbackDisplayDuration)
                            if !Task.isCancelled { withAnimation { showKilled = false } }
                        }
                    } label: {
                        Text("sure?")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.red)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .help("Confirm Stop")
                    .accessibilityLabel("Confirm stop process on port \(entry.port)")
                } else {
                    Button {
                        pendingKill = true
                        pendingKillTask?.cancel()
                        pendingKillTask = Task {
                            try? await Task.sleep(for: Constants.killConfirmTimeout)
                            if !Task.isCancelled { pendingKill = false }
                        }
                    } label: {
                        LucideIconView(.trash2, size: 12)
                            .foregroundStyle(isStopHovered ? Color.red : Color.secondary)
                    }
                    .buttonStyle(.plain)
                    .onHover { isStopHovered = $0 }
                    .help("Stop Process")
                    .accessibilityLabel("Stop process \(entry.processName) on port \(entry.port)")
                }
            }
            .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .hoverRowStyle()
        .onChange(of: entry.id) { _, _ in
            pendingKillTask?.cancel()
            pendingKill = false
            pendingKillTask = nil
            copiedTask?.cancel()
            copiedTask = nil
            killFeedbackTask?.cancel()
            killFeedbackTask = nil
        }
        .onDisappear {
            pendingKillTask?.cancel()
            copiedTask?.cancel()
            killFeedbackTask?.cancel()
        }
        .contextMenu {
            Button("Copy Port") {
                viewModel.copyPort(entry)
                triggerCopied()
            }
            Button("Copy URL") {
                viewModel.copyURL(entry)
                triggerCopied()
            }
            Divider()
            Button("Open in Browser") { viewModel.openInBrowser(entry: entry) }
            Divider()
            Button("Stop Process", role: .destructive) {
                pendingKill = true
                pendingKillTask?.cancel()
                pendingKillTask = Task {
                    try? await Task.sleep(for: Constants.killConfirmTimeout)
                    if !Task.isCancelled { pendingKill = false }
                }
            }
        }
    }

    private func triggerCopied() {
        copiedTask?.cancel()
        withAnimation { showCopied = true }
        copiedTask = Task {
            try? await Task.sleep(for: Constants.feedbackDisplayDuration)
            if !Task.isCancelled { withAnimation { showCopied = false } }
        }
    }

}
