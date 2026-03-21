import SwiftUI
import RescueCore

struct PortlessSectionView: View {
    @Bindable var viewModel: PortListViewModel

    var body: some View {
        if viewModel.enricher.isPortlessAvailable {
            VStack(spacing: 0) {
                // Section title
                HStack {
                    Text("portless")
                        .font(.headline)
                    Spacer()
                    if !viewModel.enricher.portlessRoutes.isEmpty {
                        Text("\(viewModel.enricher.portlessRoutes.count) route\(viewModel.enricher.portlessRoutes.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 6)

                // Table header
                PortlessTableHeaderView(
                    sortOrder: viewModel.enricher.portlessSortOrder,
                    sortAscending: viewModel.enricher.portlessSortAscending,
                    onSort: { viewModel.enricher.togglePortlessSort($0) }
                )

                Divider()

                if viewModel.enricher.portlessRoutes.isEmpty {
                    Text("No routes yet")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(viewModel.filteredPortlessRoutes) { route in
                        PortlessRowView(route: route)
                        Divider()
                    }
                }
            }
        } else if viewModel.enricher.portlessEnabled {
            PortlessInstallView()
        }
    }
}

struct PortlessInstallView: View {
    @State private var showCopied = false
    @State private var copiedTask: Task<Void, Never>?

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                    .foregroundStyle(.secondary)
                Text("portless isn't installed")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text("Install portless to access servers by name")
                .font(.caption2)
                .foregroundStyle(.tertiary)
            Button {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString("brew install portless", forType: .string)
                withAnimation { showCopied = true }
                copiedTask?.cancel()
                copiedTask = Task {
                    try? await Task.sleep(for: Constants.feedbackDisplayDuration)
                    if !Task.isCancelled { withAnimation { showCopied = false } }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(showCopied ? "Copied!" : "brew install portless")
                        .font(.system(size: 10, design: .monospaced))
                    if !showCopied {
                        Image(systemName: "doc.on.doc")
                            .font(.system(size: 10))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.primary.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .foregroundStyle(showCopied ? Color.green : Color.secondary)
            }
            .buttonStyle(.plain)
            .help("Copy install command")
        }
        .padding()
    }
}

struct PortlessTableHeaderView: View {
    let sortOrder: PortEnricher.PortlessSortOrder
    let sortAscending: Bool
    let onSort: (PortEnricher.PortlessSortOrder) -> Void

    var body: some View {
        HStack(spacing: 0) {
            SortableColumnHeader(
                title: "Port",
                width: 55,
                isActive: sortOrder == .byPort,
                ascending: sortAscending
            ) {
                onSort(.byPort)
            }

            SortableColumnHeader(
                title: "Hostname",
                width: 160,
                isActive: sortOrder == .byHostname,
                ascending: sortAscending
            ) {
                onSort(.byHostname)
            }

            // URL label (not sortable)
            Text("URL")
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer()

            // Spacer for action area
            Color.clear.frame(width: 48, height: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.03))
    }
}

struct PortlessRowView: View {
    let route: PortlessRoute
    @State private var isBrowserHovered = false
    @State private var isCopyHovered = false
    @State private var showCopied = false
    @State private var copiedTask: Task<Void, Never>?

    var body: some View {
        HStack(spacing: 0) {
            // Port
            PortCell(port: route.port)

            // Hostname
            Text(route.displayHostname)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .frame(width: 160, alignment: .leading)

            // URL
            if showCopied {
                Text("Copied!")
                    .font(.caption2)
                    .foregroundStyle(.blue)
                    .transition(.opacity)
            } else {
                Text(route.url.replacingOccurrences(of: "http://", with: ""))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }

            Spacer()

            // Actions
            HStack(spacing: 6) {
                Button {
                    if let url = URL(string: route.url),
                       url.scheme == "http" || url.scheme == "https" {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Image(systemName: "arrow.up.right.square")
                        .font(.system(size: 12))
                        .foregroundStyle(isBrowserHovered ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
                .onHover { isBrowserHovered = $0 }
                .help("Open in Browser")
                .accessibilityLabel("Open \(route.hostname) in browser")

                Button {
                    copyURL()
                } label: {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 12))
                        .foregroundStyle(isCopyHovered ? Color.accentColor : Color.secondary)
                }
                .buttonStyle(.plain)
                .onHover { isCopyHovered = $0 }
                .help("Copy URL")
                .accessibilityLabel("Copy URL for \(route.hostname)")
            }
            .frame(width: 48, alignment: .trailing)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .hoverRowStyle()
    }

    private func copyURL() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(route.url, forType: .string)
        withAnimation { showCopied = true }
        copiedTask?.cancel()
        copiedTask = Task {
            try? await Task.sleep(for: Constants.feedbackDisplayDuration)
            if !Task.isCancelled { withAnimation { showCopied = false } }
        }
    }
}
