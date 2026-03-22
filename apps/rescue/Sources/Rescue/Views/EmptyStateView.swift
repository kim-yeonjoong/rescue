import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            LucideIconView(.unplug, size: 32)
                .foregroundStyle(.secondary)
                .opacity(0.6)
            Text("No open ports")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("Start a dev server to see its ports here")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .accessibilityElement(children: .combine)
    }
}
