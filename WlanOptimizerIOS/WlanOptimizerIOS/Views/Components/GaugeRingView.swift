import SwiftUI

public struct GaugeRingView: View {
    public let value: Double
    public let maxValue: Double
    public let title: String
    public let unit: String
    public let primaryColor: Color
    public let size: CGFloat
    
    public init(
        value: Double,
        maxValue: Double = 100,
        title: String,
        unit: String,
        primaryColor: Color = Color(red: 0, green: 230/255, blue: 118/255),
        size: CGFloat = 110
    ) {
        self.value = value
        self.maxValue = maxValue
        self.title = title
        self.unit = unit
        self.primaryColor = primaryColor
        self.size = size
    }
    
    private var progress: Double {
        return min(1.0, max(0.0, value / maxValue))
    }
    
    public var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Background Track
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 8)
                    .frame(width: size, height: size)
                
                // Active Progress Ring
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [primaryColor.opacity(0.6), primaryColor]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: size, height: size)
                    .animation(.easeOut(duration: 0.6), value: progress)
                
                // Value text
                VStack(spacing: 0) {
                    Text(String(format: "%.1f", value))
                        .font(.system(size: size * 0.22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(unit)
                        .font(.system(size: size * 0.12, weight: .medium))
                        .foregroundColor(.gray)
                }
            }
            
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
        }
    }
}
