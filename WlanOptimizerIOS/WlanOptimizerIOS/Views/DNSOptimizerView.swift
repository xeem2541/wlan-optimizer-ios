import SwiftUI

public struct DNSOptimizerView: View {
    @StateObject private var viewModel = DNSBenchmarkViewModel()
    
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
                                Text("DNS SPEED RACE")
                                    .font(.system(size: 13, weight: .black, design: .monospaced))
                                    .foregroundColor(neonCyan)
                                    .tracking(2)
                                
                                Text("DoH Turbo Engine")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                            
                            // Benchmark Race Button
                            Button(action: {
                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                viewModel.startRace()
                            }) {
                                HStack(spacing: 6) {
                                    if viewModel.dnsService.isBenchmarking {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: "flag.checkered")
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    
                                    Text(viewModel.dnsService.isBenchmarking ? "TESTING..." : "BENCHMARK")
                                        .font(.system(size: 11, weight: .black, design: .monospaced))
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .foregroundColor(.black)
                                .background(LinearGradient(colors: [neonCyan, neonGreen], startPoint: .leading, endPoint: .trailing))
                                .cornerRadius(20)
                                .neonGlow(color: neonGreen, radius: 8)
                            }
                            .disabled(viewModel.dnsService.isBenchmarking)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Progress bar if benchmarking
                        if viewModel.dnsService.isBenchmarking {
                            VStack(alignment: .leading, spacing: 6) {
                                ProgressView(value: viewModel.dnsService.benchmarkProgress)
                                    .accentColor(neonGreen)
                                    .scaleEffect(x: 1, y: 2, anchor: .center)
                                
                                Text("Testing parallel DoH queries to global Anycast endpoints...")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                        }
                        
                        // DNS Providers List
                        VStack(spacing: 12) {
                            ForEach(viewModel.dnsService.providers) { provider in
                                GlassCard {
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack(alignment: .top) {
                                            ZStack {
                                                Circle()
                                                    .fill(provider.isFastest ? neonGreen.opacity(0.2) : Color.white.opacity(0.08))
                                                    .frame(width: 42, height: 42)
                                                
                                                Image(systemName: provider.iconName)
                                                    .font(.system(size: 18))
                                                    .foregroundColor(provider.isFastest ? neonGreen : .white)
                                            }
                                            
                                            VStack(alignment: .leading, spacing: 3) {
                                                HStack {
                                                    Text(provider.name)
                                                        .font(.system(size: 15, weight: .bold))
                                                        .foregroundColor(.white)
                                                    
                                                    if provider.isFastest {
                                                        Text("FASTEST")
                                                            .font(.system(size: 9, weight: .black, design: .monospaced))
                                                            .padding(.horizontal, 6)
                                                            .padding(.vertical, 2)
                                                            .background(neonGreen)
                                                            .foregroundColor(.black)
                                                            .cornerRadius(4)
                                                    }
                                                }
                                                
                                                Text(provider.providerDescription)
                                                    .font(.system(size: 11))
                                                    .foregroundColor(.gray)
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            // Latency Badge
                                            VStack(alignment: .trailing, spacing: 2) {
                                                if let latency = provider.currentLatencyMs {
                                                    Text(String(format: "%.1f", latency))
                                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                                        .foregroundColor(provider.isFastest ? neonGreen : .white)
                                                    Text("ms")
                                                        .font(.system(size: 10))
                                                        .foregroundColor(.gray)
                                                } else {
                                                    Text("--")
                                                        .font(.system(size: 16, weight: .bold))
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                        }
                                        
                                        Divider()
                                            .background(Color.white.opacity(0.1))
                                        
                                        HStack {
                                            Text(provider.tag)
                                                .font(.system(size: 10, weight: .semibold))
                                                .foregroundColor(neonCyan)
                                                .padding(.horizontal, 8)
                                                .padding(.vertical, 4)
                                                .background(neonCyan.opacity(0.12))
                                                .cornerRadius(6)
                                            
                                            Spacer()
                                            
                                            // Install Profile Button
                                            Button(action: {
                                                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                                viewModel.prepareInstall(for: provider)
                                            }) {
                                                HStack(spacing: 4) {
                                                    Image(systemName: "arrow.down.doc.fill")
                                                        .font(.system(size: 11))
                                                    Text("Install Profile")
                                                        .font(.system(size: 11, weight: .bold))
                                                }
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 6)
                                                .background(Color.white.opacity(0.1))
                                                .foregroundColor(.white)
                                                .cornerRadius(8)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $viewModel.showInstallSheet) {
                if let provider = viewModel.selectedProviderForInstall {
                    ZStack {
                        Color(red: 16/255, green: 22/255, blue: 36/255).ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 60))
                                .foregroundColor(neonGreen)
                                .neonGlow(color: neonGreen, radius: 12)
                                .padding(.top, 30)
                            
                            Text("ติดตั้ง \(provider.name)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text("ระบบจะเปิดหน้าดาวน์โหลด Apple Encrypted DNS Profile บน Safari เพื่อให้คุณเปิดใช้งานในการตั้งค่าของ iPhone ทันที")
                                .font(.system(size: 13))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(spacing: 8) {
                                    Text("1").bold().foregroundColor(neonCyan)
                                    Text("แตะ 'ดาวน์โหลดโปรไฟล์' แล้วเลือก 'อนุญาต'").foregroundColor(.white.opacity(0.9))
                                }
                                HStack(spacing: 8) {
                                    Text("2").bold().foregroundColor(neonCyan)
                                    Text("เปิด Settings > Profile Downloaded").foregroundColor(.white.opacity(0.9))
                                }
                                HStack(spacing: 8) {
                                    Text("3").bold().foregroundColor(neonCyan)
                                    Text("แตะ 'Install' ที่มุมขวาบน เพื่อเปิดใช้งานทันที").foregroundColor(.white.opacity(0.9))
                                }
                            }
                            .font(.system(size: 12))
                            .padding()
                            .background(Color.black.opacity(0.3))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            
                            Spacer()
                            
                            Button(action: {
                                if let url = viewModel.hostedInstallURL {
                                    UIApplication.shared.open(url)
                                }
                                viewModel.showInstallSheet = false
                            }) {
                                Text("ดาวน์โหลดโปรไฟล์ทันที")
                                    .font(.system(size: 15, weight: .bold))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(LinearGradient(colors: [neonCyan, neonGreen], startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.black)
                                    .cornerRadius(14)
                                    .neonGlow(color: neonGreen, radius: 8)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
        }
    }
}
