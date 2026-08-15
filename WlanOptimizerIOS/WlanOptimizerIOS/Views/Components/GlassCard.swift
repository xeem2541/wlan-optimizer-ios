import SwiftUI

public struct GlassCard<Content: View>: View {
    private let content: Content
    private let cornerRadius: CGFloat
    private let strokeColor: Color
    
    public init(
        cornerRadius: CGFloat = 16,
        strokeColor: Color = Color.white.opacity(0.12),
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.strokeColor = strokeColor
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(red: 16/255, green: 22/255, blue: 36/255).opacity(0.85))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [strokeColor, strokeColor.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
}

public struct NeonGlow: ViewModifier {
    public let color: Color
    public let radius: CGFloat
    
    public func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6), radius: radius / 2)
            .shadow(color: color.opacity(0.3), radius: radius)
    }
}

public extension View {
    func neonGlow(color: Color = Color(red: 0, green: 230/255, blue: 118/255), radius: CGFloat = 12) -> some View {
        modifier(NeonGlow(color: color, radius: radius))
    }
}
