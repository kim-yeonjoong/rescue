import SwiftUI
import RescueCore

struct FrameworkIconView: View {
    let framework: DevFramework
    let color: Color
    @State private var nsImage: NSImage?

    var body: some View {
        Group {
            if let nsImage {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            } else {
                // Fallback: empty space while loading
                Color.clear
            }
        }
        .frame(width: 10, height: 10)
        .onAppear { loadIcon() }
    }

    private func loadIcon() {
        if let url = Bundle.rescueResources.url(forResource: framework.iconResource, withExtension: "svg"),
           let image = NSImage(contentsOf: url) {
            image.isTemplate = true
            nsImage = image
        } else if let image = NSImage(systemSymbolName: framework.icon, accessibilityDescription: nil) {
            nsImage = image
        }
    }
}
