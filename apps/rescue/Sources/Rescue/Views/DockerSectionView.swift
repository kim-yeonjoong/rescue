import SwiftUI
import RescueCore

struct DockerSectionView: View {
    @Bindable var viewModel: DockerViewModel
    @AppStorage(AppStorageKey.dockerSectionCollapsed) private var isCollapsed: Bool = false

    var body: some View {
        if viewModel.isDockerAvailable {
            VStack(spacing: 0) {
                // Section title
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { isCollapsed.toggle() }
                } label: {
                    HStack {
                        Text("Docker")
                            .font(.headline)
                        Spacer()
                        if !isCollapsed && !viewModel.containers.isEmpty {
                            Text("\(viewModel.containers.count) container\(viewModel.containers.count == 1 ? "" : "s")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        LucideIconView(isCollapsed ? .chevronDown : .chevronUp, size: 11)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 12)
                    .padding(.bottom, 6)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if !isCollapsed {
                    // Table header
                    DockerTableHeaderView(
                        sortOrder: viewModel.sortOrder,
                        sortAscending: viewModel.sortAscending,
                        onSort: { viewModel.toggleSort($0) }
                    )

                    Divider()

                    // Rows: 포트마다 별도 행으로 표시
                    ForEach(viewModel.filteredContainers) { container in
                        if container.ports.isEmpty {
                            DockerRowView(container: container, portMapping: nil, viewModel: viewModel)
                            Divider()
                        } else {
                            ForEach(container.ports, id: \.hostPort) { mapping in
                                DockerRowView(container: container, portMapping: mapping, viewModel: viewModel)
                                Divider()
                            }
                        }
                    }
                }
            }
        } else if viewModel.isLoading {
            // Don't show anything while still checking
        } else {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    LucideIconView(.packageBox)
                        .foregroundStyle(.secondary)
                    Text("Docker isn't running")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text("Start Docker to see containers here")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding()
        }
    }
}

struct DockerTableHeaderView: View {
    let sortOrder: DockerViewModel.SortOrder
    let sortAscending: Bool
    let onSort: (DockerViewModel.SortOrder) -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("Port")
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 55, alignment: .leading)

            SortableColumnHeader(
                title: "Name",
                width: 90,
                isActive: sortOrder == .byName,
                ascending: sortAscending
            ) {
                onSort(.byName)
            }

            SortableColumnHeader(
                title: "Image",
                width: 90,
                isActive: sortOrder == .byImage,
                ascending: sortAscending
            ) {
                onSort(.byImage)
            }

            Spacer()

            SortableColumnHeader(
                title: "Status",
                width: nil,
                isActive: sortOrder == .byStatus,
                ascending: sortAscending
            ) {
                onSort(.byStatus)
            }

            // Spacer for action buttons area
            Color.clear.frame(width: 48, height: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.03))
    }
}
