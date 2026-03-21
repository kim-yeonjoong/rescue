import SwiftUI
import RescueCore

struct PortListView: View {
    @Bindable var viewModel: PortListViewModel

    var body: some View {
        if viewModel.isLoading && viewModel.ports.isEmpty {
            VStack(spacing: 12) {
                ProgressView()
                Text("Looking for open ports…")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else if viewModel.ports.isEmpty {
            EmptyStateView()
        } else {
            VStack(spacing: 0) {
                // Table header
                PortTableHeaderView(
                    sortOrder: viewModel.sortOrder,
                    sortAscending: viewModel.sortAscending,
                    onSort: { viewModel.toggleSort($0) }
                )

                Divider()

                // Rows
                ForEach(viewModel.filteredPorts) { entry in
                    PortRowView(entry: entry, viewModel: viewModel)
                    Divider()
                }
            }
            .animation(.default, value: viewModel.ports.count)
        }
    }
}

struct PortTableHeaderView: View {
    let sortOrder: PortListViewModel.SortOrder
    let sortAscending: Bool
    let onSort: (PortListViewModel.SortOrder) -> Void

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
                title: "Process",
                width: 140,
                isActive: sortOrder == .byName,
                ascending: sortAscending
            ) {
                onSort(.byName)
            }

            SortableColumnHeader(
                title: "Framework",
                width: nil,
                isActive: sortOrder == .byFramework,
                ascending: sortAscending
            ) {
                onSort(.byFramework)
            }

            Spacer()

            // Spacer for action buttons area
            Color.clear.frame(width: 48, height: 1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.primary.opacity(0.03))
    }
}

struct SortableColumnHeader: View {
    let title: String
    let width: CGFloat?
    let isActive: Bool
    let ascending: Bool
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 3) {
                Text(title)
                    .font(.caption)
                    .fontWeight(isActive ? .semibold : .regular)
                    .foregroundStyle(isActive ? .primary : .secondary)
                Image(systemName: ascending ? "chevron.up" : "chevron.down")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(isActive ? Color.primary : Color.primary.opacity(0.25))
            }
            .frame(width: width, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovered = $0 }
        .opacity(isHovered && !isActive ? 0.7 : 1.0)
    }
}
