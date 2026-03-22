import SwiftUI
import RescueCore

struct DockerRowView: View {
    let container: DockerContainer
    let portMapping: DockerContainer.PortMapping?
    let viewModel: DockerViewModel
    @State private var isPlayHovered = false
    @State private var isStopHovered = false
    @State private var isRestartHovered = false

    var body: some View {
        HStack(spacing: 4) {
            // Port column
            PortCell(port: portMapping?.hostPort)

            // Name column
            VStack(alignment: .leading, spacing: 1) {
                Text(container.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let uptime = container.uptimeString {
                    Text(uptime)
                        .font(.system(size: 9))
                        .foregroundStyle(.tertiary)
                }
            }
            .frame(width: 90, alignment: .leading)

            // Framework badge / image fallback — fixed width based on "Elasticsearch"
            Group {
                if let fw = container.inferredFramework {
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
                } else {
                    Text(container.image)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
            }
            .frame(width: 90, alignment: .leading)

            Spacer()

            // Status pill
            Text(container.displayStatus)
                .font(.caption2)
                .fontWeight(.medium)
                .lineLimit(1)
                .padding(.horizontal, 5)
                .padding(.vertical, 1)
                .background(statusColor.opacity(0.12))
                .foregroundStyle(statusColor)
                .clipShape(Capsule())
                .fixedSize(horizontal: true, vertical: false)

            // Actions
            if viewModel.operatingContainers.contains(container.id) {
                ProgressView()
                    .controlSize(.mini)
                    .frame(width: 48, alignment: .trailing)
            } else {
                HStack(spacing: 6) {
                    if !container.status.isRunning {
                        Button {
                            guard !viewModel.operatingContainers.contains(container.id) else { return }
                            Task { await viewModel.start(container) }
                        } label: {
                            LucideIconView(.play, size: 12)
                                .foregroundStyle(isPlayHovered ? Color.green : Color.secondary)
                        }
                        .buttonStyle(.plain)
                        .onHover { isPlayHovered = $0 }
                        .help("Start")
                        .accessibilityLabel("Start container \(container.name)")
                    }

                    if container.status.isRunning {
                        Button {
                            guard !viewModel.operatingContainers.contains(container.id) else { return }
                            Task { await viewModel.stop(container) }
                        } label: {
                            LucideIconView(.square, size: 12)
                                .foregroundStyle(isStopHovered ? Color.red : Color.secondary)
                        }
                        .buttonStyle(.plain)
                        .onHover { isStopHovered = $0 }
                        .help("Stop")
                        .accessibilityLabel("Stop container \(container.name)")

                        Button {
                            guard !viewModel.operatingContainers.contains(container.id) else { return }
                            Task { await viewModel.restart(container) }
                        } label: {
                            LucideIconView(.refreshCw, size: 12)
                                .foregroundStyle(isRestartHovered ? Color.accentColor : Color.secondary)
                        }
                        .buttonStyle(.plain)
                        .onHover { isRestartHovered = $0 }
                        .help("Restart")
                        .accessibilityLabel("Restart container \(container.name)")
                    }
                }
                .frame(width: 48, alignment: .trailing)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 5)
        .hoverRowStyle()
    }

    private var statusColor: Color {
        switch container.status {
        case .running: return .green
        case .exited: return .red
        case .paused: return .yellow
        case .other: return .gray
        }
    }
}
