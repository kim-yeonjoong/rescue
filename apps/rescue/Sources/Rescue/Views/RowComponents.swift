import SwiftUI
import RescueCore

extension DevFramework {
    var color: Color {
        guard let hex = brandHex else { return .primary }
        return Color(hex: hex)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var rgb: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgb)
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

/// 포트 번호 표시 컬럼 (세 섹션 공통)
struct PortCell: View {
    let port: UInt16?

    var body: some View {
        Group {
            if let port {
                Text(":" + String(port))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
            } else {
                Text("—")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(width: 55, alignment: .leading)
        .accessibilityLabel(port.map { "Port \($0)" } ?? "No port")
    }
}

/// Row hover 배경 스타일 (세 섹션 공통)
struct HoverRowModifier: ViewModifier {
    @State private var isHovered = false

    func body(content: Content) -> some View {
        content
            .background(isHovered ? Color.primary.opacity(0.08) : Color.clear)
            .contentShape(Rectangle())
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .onHover { isHovered = $0 }
    }
}

extension View {
    func hoverRowStyle() -> some View {
        modifier(HoverRowModifier())
    }
}
