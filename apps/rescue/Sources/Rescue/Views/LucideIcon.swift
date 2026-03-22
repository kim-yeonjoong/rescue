import SwiftUI

enum LucideIcon: String {
    case circleAlert = "circle-alert"
    case circleCheck = "circle-check"
    case refreshCw = "refresh-cw"
    case search
    case xCircle = "x-circle"
    case play
    case square
    case externalLink = "external-link"
    case trash2 = "trash-2"
    case circleMinus = "circle-minus"
    case globe
    case packageBox = "package"
    case chevronUp = "chevron-up"
    case chevronDown = "chevron-down"
    case link
    case copy
    case unplug
    case settings
    case power
    case slidersHorizontal = "sliders-horizontal"
    case puzzle
    case info
}

struct LucideIconView: View {
    let icon: LucideIcon
    let size: CGFloat

    init(_ icon: LucideIcon, size: CGFloat = 14) {
        self.icon = icon
        self.size = size
    }

    var body: some View {
        Group {
            if let nsImage = Self.loadImage(icon) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
            }
        }
        .frame(width: size, height: size)
    }

    @MainActor
    private static var cache: [LucideIcon: NSImage] = [:]

    @MainActor
    private static func loadImage(_ icon: LucideIcon) -> NSImage? {
        if let cached = cache[icon] { return cached }
        guard let url = Bundle.rescueResources.url(forResource: icon.rawValue, withExtension: "svg"),
              let image = NSImage(contentsOf: url) else { return nil }
        image.isTemplate = true
        cache[icon] = image
        return image
    }
}
