import SwiftUI

struct GlassmorphicStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
                    .background(
                        Group {
                            if #available(iOS 15.0, *) {
                                Blur(style: .systemUltraThinMaterialDark)
                            } else {
                                Blur(style: .dark)
                            }
                        }
                        .cornerRadius(20)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

struct Blur: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

extension View {
    func glassmorphic() -> some View {
        self.modifier(GlassmorphicStyle())
    }
}

struct MetroColors {
    static let background = Color(red: 0.05, green: 0.05, blue: 0.15)
    static let primary = Color(red: 0.2, green: 0.8, blue: 1.0)
    static let accent = Color(red: 0.6, green: 0.2, blue: 1.0)
}
