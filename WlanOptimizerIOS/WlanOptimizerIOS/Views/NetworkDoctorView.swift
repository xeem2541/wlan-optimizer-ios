import SwiftUI

public struct NetworkDoctorView: View {
    @StateObject private var doctor = NetworkDoctorService.shared
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    private let neonYellow = Color(red: 255/255, green: 214/255, blue: 0)
    private let neonRed = Color(red: 255/255, green: 82/255, blue: 82/255)
    
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
                                Text("SYSTEM DIAGNOSTICS")
                                    .font(.system(size: 13, weight: .black, design: .monospaced))
                                    .foregroundColor(neonCyan)
                                    .tracking(2)
                                
                                Text("Network Doctor")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                doctor.runDiagnostics()
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "arrow.clockwise")
                                    Text("SCAN")
                                }
                                .font(.system(size: 11, weight: .bold, design: .monospaced))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Diagnostic Cards
                        VStack(spacing: 12) {
                            ForEach(doctor.diagnostics) { item in
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .top) {
                                            Image(systemName: item.status.icon)
                                                .font(.system(size: 20))
                                                .foregroundColor(Color(hex: item.status.colorHex))
                                                .padding(.top, 2)
                                            
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(item.title)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .foregroundColor(.white)
                                                
                                                Text(item.message)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.gray)
                                                    .lineSpacing(2)
                                            }
                                        }
                                        
                                        Divider().background(Color.white.opacity(0.08))
                                        
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text("ข้อแนะนำ:")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(neonCyan)
                                                Text(item.solution)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            
                                            Spacer()
                                            
                                            if let url = item.settingsURL {
                                                Button(action: {
                                                    doctor.openSettingsURL(url)
                                                }) {
                                                    Text("เปิด Settings")
                                                        .font(.system(size: 11, weight: .bold))
                                                        .padding(.horizontal, 10)
                                                        .padding(.vertical, 6)
                                                        .background(neonCyan.opacity(0.15))
                                                        .foregroundColor(neonCyan)
                                                        .cornerRadius(6)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Wi-Fi Quick Tips
                        GlassCard {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(neonYellow)
                                    Text("สูตรลับลดปิงสำหรับนักเล่นเกมบน iOS")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("1. เลือกเชื่อมต่อ Wi-Fi คลื่น 5GHz หรือ 6GHz แทน 2.4GHz เสมอ")
                                    Text("2. ปิด 'Wi-Fi Assist' ในเมนู Cellular เพื่อไม่ให้เน็ตสลับไปมาขณะเล่นเกม")
                                    Text("3. ติดตั้ง Encrypted DNS Profile จากแท็บ DNS Optimizer เพื่อลดเวลาตอบสนอง")
                                    Text("4. ปิดแอปที่อัปโหลดรูปภาพเบื้องหลัง เช่น Google Photos / iCloud Photos ชั่วคราว")
                                }
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
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
