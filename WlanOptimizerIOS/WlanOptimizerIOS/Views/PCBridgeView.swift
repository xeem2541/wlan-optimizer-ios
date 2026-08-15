import SwiftUI
import UIKit

public struct PCBridgeView: View {
    @StateObject private var viewModel = PCBridgeViewModel()
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
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
                                Text("SECOND SCREEN HUD")
                                    .font(.system(size: 13, weight: .black, design: .monospaced))
                                    .foregroundColor(neonCyan)
                                    .tracking(2)
                                
                                Text("PC Companion Bridge")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Connection status
                            HStack(spacing: 6) {
                                Circle()
                                    .fill(viewModel.pcService.isConnected ? neonGreen : neonRed)
                                    .frame(width: 8, height: 8)
                                    .neonGlow(color: viewModel.pcService.isConnected ? neonGreen : neonRed, radius: 4)
                                
                                Text(viewModel.pcService.isConnected ? "PC LINKED" : "OFFLINE")
                                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                                    .foregroundColor(viewModel.pcService.isConnected ? neonGreen : .gray)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.white.opacity(0.06))
                            .cornerRadius(20)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Connection Input Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("CONNECT TO WLAN OPTIMIZER (PC)")
                                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                                    .foregroundColor(.gray)
                                
                                HStack(spacing: 8) {
                                    TextField("PC IP (เช่น 192.168.1.50)", text: $viewModel.inputIP)
                                        .padding(10)
                                        .background(Color.black.opacity(0.3))
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                        .keyboardType(.numbersAndPunctuation)
                                    
                                    Button(action: {
                                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        if viewModel.pcService.isConnected {
                                            viewModel.disconnect()
                                        } else {
                                            viewModel.connect()
                                        }
                                    }) {
                                        Text(viewModel.pcService.isConnected ? "Disconnect" : "Connect")
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 10)
                                            .background(viewModel.pcService.isConnected ? Color.red.opacity(0.8) : neonGreen)
                                            .foregroundColor(viewModel.pcService.isConnected ? .white : .black)
                                            .cornerRadius(8)
                                    }
                                }
                                
                                if let err = viewModel.pcService.lastErrorMessage {
                                    HStack {
                                        Text(err)
                                            .font(.system(size: 11))
                                            .foregroundColor(.yellow)
                                        
                                        Spacer()
                                        
                                        Button("ทดลองโหมดจำลอง (Demo)") {
                                            viewModel.useDemo()
                                        }
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(neonCyan)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Live PC Stats HUD (When Connected)
                        if viewModel.pcService.isConnected {
                            GlassCard {
                                VStack(spacing: 14) {
                                    HStack {
                                        Image(systemName: "desktopcomputer")
                                            .foregroundColor(neonCyan)
                                        Text(viewModel.pcService.pcAdapterName)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("Signal: \(viewModel.pcService.pcSignalQuality)%")
                                            .font(.system(size: 11, weight: .semibold))
                                            .foregroundColor(neonGreen)
                                    }
                                    
                                    Divider().background(Color.white.opacity(0.1))
                                    
                                    HStack(spacing: 12) {
                                        VStack(spacing: 4) {
                                            Text("PC PING")
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text(String(format: "%.1f ms", viewModel.pcService.pcPing))
                                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                                .foregroundColor(neonGreen)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        VStack(spacing: 4) {
                                            Text("PC JITTER")
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text(String(format: "%.1f ms", viewModel.pcService.pcJitter))
                                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                                .foregroundColor(neonCyan)
                                        }
                                        .frame(maxWidth: .infinity)
                                        
                                        VStack(spacing: 4) {
                                            Text("PC LOSS")
                                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                                .foregroundColor(.gray)
                                            Text(String(format: "%.0f %%", viewModel.pcService.pcLoss))
                                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                                .foregroundColor(viewModel.pcService.pcLoss > 0 ? neonRed : neonGreen)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            // Remote PC Controls
                            GlassCard {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("REMOTE PC CONTROLS")
                                        .font(.system(size: 11, weight: .bold, design: .monospaced))
                                        .foregroundColor(.gray)
                                    
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            viewModel.toggleStreaming()
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: "antenna.radiowaves.left.and.right")
                                                    .font(.system(size: 20))
                                                Text("Streaming Mode")
                                                    .font(.system(size: 11, weight: .bold))
                                                Text(viewModel.pcService.pcStreamingMode ? "ON" : "OFF")
                                                    .font(.system(size: 10, weight: .black))
                                                    .foregroundColor(viewModel.pcService.pcStreamingMode ? neonGreen : .gray)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.white.opacity(0.06))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(viewModel.pcService.pcStreamingMode ? neonGreen : Color.clear, lineWidth: 1)
                                            )
                                        }
                                        
                                        Button(action: {
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                            viewModel.toggleScan()
                                        }) {
                                            VStack(spacing: 6) {
                                                Image(systemName: "wifi.slash")
                                                    .font(.system(size: 20))
                                                Text("Disable Scan")
                                                    .font(.system(size: 11, weight: .bold))
                                                Text(viewModel.pcService.pcBackgroundScanDisabled ? "ON" : "OFF")
                                                    .font(.system(size: 10, weight: .black))
                                                    .foregroundColor(viewModel.pcService.pcBackgroundScanDisabled ? neonGreen : .gray)
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(Color.white.opacity(0.06))
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(viewModel.pcService.pcBackgroundScanDisabled ? neonGreen : Color.clear, lineWidth: 1)
                                            )
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Setup Info Card
                        GlassCard {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "ipad.and.iphone")
                                        .foregroundColor(neonCyan)
                                    Text("วาง iPhone เป็นหน้าจอเสริมข้างคีย์บอร์ด")
                                        .font(.system(size: 13, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                
                                Text("เมื่อเปิดแอปบน iPhone และเชื่อมต่อกับคอมพิวเตอร์ในวง Wi-Fi เดียวกัน คุณสามารถใช้ iPhone ดูค่า Ping ขณะเล่นเกม Full-screen และสั่งเปิดโหมด Optimizer ได้โดยไม่ต้องกด Alt+Tab ออกจากเกม")
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
