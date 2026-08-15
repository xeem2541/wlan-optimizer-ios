import SwiftUI

public struct BufferbloatView: View {
    @StateObject private var viewModel = BufferbloatViewModel()
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    private let neonYellow = Color(red: 255/255, green: 214/255, blue: 0)
    
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
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("BUFFERBLOAT LAB")
                                    .font(.system(size: 13, weight: .black, design: .monospaced))
                                    .foregroundColor(neonCyan)
                                    .tracking(2)
                                
                                Text("Network Stress Test")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Test Status Card
                        GlassCard {
                            VStack(spacing: 16) {
                                Text(viewModel.service.phase.rawValue)
                                    .font(.system(size: 13, weight: .bold, design: .monospaced))
                                    .foregroundColor(viewModel.service.isRunning ? neonCyan : .gray)
                                
                                if viewModel.service.isRunning {
                                    ProgressView(value: viewModel.service.progress)
                                        .accentColor(neonGreen)
                                        .scaleEffect(x: 1, y: 2, anchor: .center)
                                    
                                    HStack {
                                        Text("Live Probe:")
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                        Text(String(format: "%.1f ms", viewModel.service.livePing))
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundColor(neonGreen)
                                    }
                                } else {
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        viewModel.startTest()
                                    }) {
                                        HStack(spacing: 8) {
                                            Image(systemName: "bolt.horizontal.circle.fill")
                                                .font(.system(size: 18))
                                            Text("START BUFFERBLOAT TEST")
                                                .font(.system(size: 13, weight: .black, design: .monospaced))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(LinearGradient(colors: [neonCyan, neonGreen], startPoint: .leading, endPoint: .trailing))
                                        .foregroundColor(.black)
                                        .cornerRadius(12)
                                        .neonGlow(color: neonGreen, radius: 8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Grade Result Card (if completed)
                        if let res = viewModel.service.result {
                            GlassCard {
                                VStack(spacing: 16) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("BUFFERBLOAT GRADE")
                                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text(res.grade.title)
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                        
                                        Spacer()
                                        
                                        Text(res.grade.rawValue)
                                            .font(.system(size: 48, weight: .black, design: .rounded))
                                            .foregroundColor(Color(hex: res.grade.colorHex))
                                            .neonGlow(color: Color(hex: res.grade.colorHex), radius: 10)
                                    }
                                    
                                    Divider().background(Color.white.opacity(0.1))
                                    
                                    // 3 Metrics comparison
                                    HStack(spacing: 10) {
                                        VStack(spacing: 4) {
                                            Text("IDLE PING")
                                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text(String(format: "%.1f ms", res.unloadedPing))
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(neonGreen)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        VStack(spacing: 4) {
                                            Text("DOWNLOAD LOAD")
                                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text("+\(String(format: "%.0f", res.downloadIncrease)) ms")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(neonCyan)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        VStack(spacing: 4) {
                                            Text("UPLOAD LOAD")
                                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text("+\(String(format: "%.0f", res.uploadIncrease)) ms")
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(neonYellow)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    
                                    // Advice
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("คำแนะนำการปรับปรุง:")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundColor(neonCyan)
                                        Text(res.recommendation)
                                            .font(.system(size: 12))
                                            .foregroundColor(.gray)
                                            .lineSpacing(2)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.3))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Educational Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "questionmark.circle.fill")
                                        .foregroundColor(neonCyan)
                                    Text("ทำไม Bufferbloat ถึงทำให้เล่นเกมแลค?")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("Bufferbloat คืออาการที่เราเตอร์สะสมคิวส่งข้อมูลจนแน่น เมื่อคนในบ้านดาวน์โหลดไฟล์หรือดูวิดีโอ ข้อมูลของเกมจะถูกกักไว้ในคิว ทำให้ Ping ดีดขึ้นจาก 15ms เป็น 200ms+ ทันที การทดสอบนี้ช่วยชี้จุดที่ต้องปรับแต่งสัญญาณ Wi-Fi ได้ตรงจุด")
                                    .font(.system(size: 12))
                                    .foregroundColor(.gray)
                                    .lineSpacing(3)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// Color Hex Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
