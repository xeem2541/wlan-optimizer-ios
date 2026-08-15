import SwiftUI

public struct TurboBoostView: View {
    @StateObject private var viewModel = TurboBoostViewModel()
    @State private var pulseAnimation = false
    @State private var rotateRings = false
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    private let neonRed = Color(red: 255/255, green: 82/255, blue: 82/255)
    
    public var body: some View {
        NavigationView {
            ZStack {
                // Cyberpunk Dark Background
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
                    VStack(spacing: 24) {
                        
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("WLAN OPTIMIZER")
                                    .font(.system(size: 13, weight: .black, design: .monospaced))
                                    .foregroundColor(neonCyan)
                                    .tracking(2)
                                
                                Text("iOS Turbo Engine")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Status Badge
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(viewModel.isBoostActive ? neonGreen : neonRed)
                                    .frame(width: 8, height: 8)
                                    .neonGlow(color: viewModel.isBoostActive ? neonGreen : neonRed, radius: 6)
                                
                                Text(viewModel.isBoostActive ? "TURBO ACTIVE" : "STANDARD")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(viewModel.isBoostActive ? neonGreen : .gray)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(20)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Mode Selector
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("ACCELERATION PROFILE")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 8) {
                                    ForEach(BoostMode.allCases) { mode in
                                        Button(action: {
                                            withAnimation(.spring(response: 0.3)) {
                                                viewModel.selectedMode = mode
                                            }
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: mode.iconName)
                                                    .font(.system(size: 18))
                                                    .foregroundColor(viewModel.selectedMode == mode ? .black : .white)
                                                
                                                Text(mode.rawValue)
                                                    .font(.system(size: 11, weight: .bold))
                                                    .foregroundColor(viewModel.selectedMode == mode ? .black : .white.opacity(0.8))
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(
                                                viewModel.selectedMode == mode ?
                                                    LinearGradient(colors: [neonCyan, neonGreen], startPoint: .topLeading, endPoint: .bottomTrailing) :
                                                    LinearGradient(colors: [Color.white.opacity(0.05), Color.white.opacity(0.02)], startPoint: .top, endPoint: .bottom)
                                            )
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(viewModel.selectedMode == mode ? Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                                
                                Text(viewModel.selectedMode.subtitle)
                                    .font(.system(size: 12))
                                    .foregroundColor(neonCyan.opacity(0.9))
                            }
                        }
                        .padding(.horizontal)
                        
                        // Central Reactor Turbo Button
                        ZStack {
                            // Outer Pulsating Glow Rings
                            if viewModel.isBoostActive {
                                Circle()
                                    .stroke(neonGreen.opacity(0.15), lineWidth: 2)
                                    .frame(width: 250, height: 250)
                                    .scaleEffect(pulseAnimation ? 1.15 : 0.95)
                                    .opacity(pulseAnimation ? 0.2 : 0.8)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: pulseAnimation)
                                
                                Circle()
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [neonGreen, neonCyan, .clear, neonGreen]),
                                            center: .center
                                        ),
                                        lineWidth: 3
                                    )
                                    .frame(width: 220, height: 220)
                                    .rotationEffect(.degrees(rotateRings ? 360 : 0))
                                    .animation(.linear(duration: 6).repeatForever(autoreverses: false), value: rotateRings)
                            } else {
                                Circle()
                                    .stroke(Color.white.opacity(0.06), lineWidth: 2)
                                    .frame(width: 220, height: 220)
                            }
                            
                            // Center Button
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                                viewModel.toggleBoost()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: viewModel.isBoostActive ?
                                                    [Color(red: 0, green: 40/255, blue: 25/255), Color(red: 10/255, green: 20/255, blue: 30/255)] :
                                                    [Color(red: 30/255, green: 15/255, blue: 20/255), Color(red: 16/255, green: 16/255, blue: 24/255)],
                                                center: .center,
                                                startRadius: 10,
                                                endRadius: 90
                                            )
                                        )
                                        .frame(width: 175, height: 175)
                                        .overlay(
                                            Circle()
                                                .stroke(viewModel.isBoostActive ? neonGreen : Color.white.opacity(0.2), lineWidth: 3)
                                                .neonGlow(color: viewModel.isBoostActive ? neonGreen : .clear, radius: 16)
                                        )
                                    
                                    VStack(spacing: 8) {
                                        Image(systemName: viewModel.isBoostActive ? "bolt.fill" : "power")
                                            .font(.system(size: 38, weight: .bold))
                                            .foregroundColor(viewModel.isBoostActive ? neonGreen : .white.opacity(0.7))
                                            .neonGlow(color: viewModel.isBoostActive ? neonGreen : .clear, radius: 10)
                                        
                                        Text(viewModel.isBoostActive ? "TURBO ON" : "BOOST NOW")
                                            .font(.system(size: 14, weight: .black, design: .monospaced))
                                            .foregroundColor(viewModel.isBoostActive ? .white : .white.opacity(0.8))
                                            .tracking(1.5)
                                    }
                                }
                            }
                        }
                        .frame(height: 260)
                        .onAppear {
                            pulseAnimation = true
                            rotateRings = true
                        }
                        
                        // Live Metrics Row
                        HStack(spacing: 12) {
                            GlassCard {
                                VStack(spacing: 6) {
                                    Text("LIVE LATENCY")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(String(format: "%.1f", viewModel.livePing))
                                            .font(.system(size: 26, weight: .bold, design: .rounded))
                                            .foregroundColor(viewModel.isBoostActive ? neonGreen : .white)
                                        
                                        Text("ms")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            GlassCard {
                                VStack(spacing: 6) {
                                    Text("LAG REDUCTION")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.isBoostActive ? "-\(viewModel.latencySavedPercent)" : "0")
                                            .font(.system(size: 26, weight: .bold, design: .rounded))
                                            .foregroundColor(neonCyan)
                                        
                                        Text("%")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                            
                            GlassCard {
                                VStack(spacing: 6) {
                                    Text("BLOAT SAVED")
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    
                                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                                        Text(viewModel.isBoostActive ? String(format: "%.0f", viewModel.dataSavedMB) : "0")
                                            .font(.system(size: 26, weight: .bold, design: .rounded))
                                            .foregroundColor(Color(red: 255/255, green: 214/255, blue: 0))
                                        
                                        Text("MB")
                                            .font(.system(size: 12, weight: .semibold))
                                            .foregroundColor(.gray)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal)
                        
                        // How it works Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(neonCyan)
                                    Text("How Turbo Boost Works on iOS")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("ระบบจะเปิดใช้ DoH Fast DNS และกรองทราฟฟิกขยะเบื้องหลัง เพื่อลดเวลา DNS Lookup และแก้ปัญหา Ping แกว่งขณะเล่นเกมหรือใช้งานเน็ต")
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
            .alert(isPresented: $viewModel.showSafariInstallAlert) {
                Alert(
                    title: Text("ติดตั้ง Apple Encrypted DNS Profile"),
                    message: Text("iOS ต้องการให้ดาวน์โหลดโปรไฟล์ความเร็วสูง เมื่อกดตกลง ให้แตะ 'อนุญาต' จากนั้นไปที่ Settings > Profile Downloaded เพื่อเปิดใช้งาน"),
                    primaryButton: .default(Text("เปิดติดตั้งใน Safari")) {
                        if let url = viewModel.profileInstallURL {
                            UIApplication.shared.open(url)
                        }
                    },
                    secondaryButton: .cancel(Text("ภายหลัง"))
                )
            }
        }
    }
}
