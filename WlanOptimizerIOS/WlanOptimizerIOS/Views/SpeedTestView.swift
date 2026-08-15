import SwiftUI
import UIKit

public struct SpeedTestView: View {
    @StateObject private var viewModel = SpeedTestViewModel()
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 10/255, green: 14/255, blue: 26/255),
                        Color(red: 5/255, green: 8/255, blue: 16/255)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 8) {
                        Text("CYBERPUNK")
                            .font(.system(size: 14, weight: .black, design: .monospaced))
                            .foregroundColor(neonCyan)
                            .tracking(3)
                        
                        Text("Speed Test Module")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 40)
                    
                    Spacer()
                    
                    // Dial Gauge
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 20)
                            .frame(width: 250, height: 250)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(viewModel.progress))
                            .stroke(
                                LinearGradient(colors: [neonCyan, neonGreen], startPoint: .leading, endPoint: .trailing),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 250, height: 250)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.1), value: viewModel.progress)
                        
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", viewModel.downloadSpeedMbps))
                                .font(.system(size: 54, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            
                            Text("Mbps")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Color.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Peak Speed
                    VStack(spacing: 8) {
                        Text("PEAK SPEED")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(.gray)
                        Text(String(format: "%.1f Mbps", viewModel.peakSpeed))
                            .font(.system(size: 24, weight: .bold, design: .monospaced))
                            .foregroundColor(neonGreen)
                    }
                    
                    Spacer()
                    
                    // Action Button
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        viewModel.toggleTest()
                    }) {
                        Text(viewModel.isTesting ? "STOP TEST" : "START SPEED TEST")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(viewModel.isTesting ? .white : .black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                viewModel.isTesting ? 
                                Color.red : neonCyan
                            )
                            .cornerRadius(12)
                            .shadow(color: (viewModel.isTesting ? Color.red : neonCyan).opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
