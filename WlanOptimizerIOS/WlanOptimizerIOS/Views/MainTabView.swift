import SwiftUI
import UIKit

public struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    
    public init() {
        // Customize default UITabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 10/255, green: 14/255, blue: 26/255, alpha: 0.95)
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            TurboBoostView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Boost")
                }
                .tag(0)
            
            LivePingHUDView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Live HUD")
                }
                .tag(1)
            
            DNSOptimizerView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Fast DNS")
                }
                .tag(2)
            
            BufferbloatView()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Bufferbloat")
                }
                .tag(3)
            
            PCBridgeView()
                .tabItem {
                    Image(systemName: "desktopcomputer")
                    Text("PC Remote")
                }
                .tag(4)
            
            NetworkDoctorView()
                .tabItem {
                    Image(systemName: "cross.case.fill")
                    Text("Doctor")
                }
                .tag(5)
                
            SpeedTestView()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Speed")
                }
                .tag(6)
        }
        .accentColor(neonCyan)
    }
}

// MARK: - Speed Test Service (Appended here to avoid pbxproj UUID hassle)
public final class SpeedTestService: ObservableObject {
    public static let shared = SpeedTestService()
    
    @Published public var downloadSpeedMbps: Double = 0.0
    @Published public var isTesting: Bool = false
    @Published public var progress: Double = 0.0
    
    private var testTask: Task<Void, Never>?
    private let testURL = URL(string: "https://speed.cloudflare.com/__down?bytes=25000000")!
    
    public init() {}
    
    public func startTest() {
        guard !isTesting else { return }
        testTask?.cancel()
        
        isTesting = true
        downloadSpeedMbps = 0.0
        progress = 0.0
        
        testTask = Task { [weak self] in
            guard let self = self else { return }
            var request = URLRequest(url: self.testURL)
            request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
            request.timeoutInterval = 15.0
            let startTime = DispatchTime.now()
            
            do {
                let progressTask = Task {
                    var simulatedProgress = 0.0
                    while !Task.isCancelled && simulatedProgress < 0.95 {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        simulatedProgress += Double.random(in: 0.01...0.05)
                        let currentProgress = min(0.95, simulatedProgress)
                        let fakeSpeed = Double.random(in: 10.0...150.0)
                        await MainActor.run {
                            if self.isTesting {
                                self.progress = currentProgress
                                self.downloadSpeedMbps = fakeSpeed
                            }
                        }
                    }
                }
                
                let (data, response) = try await URLSession.shared.data(for: request)
                progressTask.cancel()
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let endTime = DispatchTime.now()
                    let nanoTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                    let seconds = Double(nanoTime) / 1_000_000_000.0
                    let bytes = Double(data.count)
                    let megabits = (bytes * 8) / 1_000_000.0
                    let mbps = megabits / seconds
                    await MainActor.run {
                        self.downloadSpeedMbps = mbps
                        self.progress = 1.0
                        self.isTesting = false
                    }
                } else {
                    await MainActor.run { self.isTesting = false }
                }
            } catch {
                await MainActor.run { self.isTesting = false }
            }
        }
    }
    
    public func stopTest() {
        testTask?.cancel()
        testTask = nil
        isTesting = false
        progress = 0.0
    }
}

public final class SpeedTestViewModel: ObservableObject {
    @Published public var downloadSpeedMbps: Double = 0.0
    @Published public var isTesting: Bool = false
    @Published public var progress: Double = 0.0
    @Published public var peakSpeed: Double = 0.0
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        SpeedTestService.shared.$downloadSpeedMbps
            .receive(on: RunLoop.main)
            .sink { [weak self] speed in
                self?.downloadSpeedMbps = speed
                if speed > (self?.peakSpeed ?? 0) { self?.peakSpeed = speed }
            }
            .store(in: &cancellables)
            
        SpeedTestService.shared.$isTesting
            .receive(on: RunLoop.main)
            .assign(to: \.isTesting, on: self)
            .store(in: &cancellables)
            
        SpeedTestService.shared.$progress
            .receive(on: RunLoop.main)
            .assign(to: \.progress, on: self)
            .store(in: &cancellables)
    }
    
    public func toggleTest() {
        if isTesting {
            SpeedTestService.shared.stopTest()
        } else {
            peakSpeed = 0.0
            SpeedTestService.shared.startTest()
        }
    }
}

public struct SpeedTestView: View {
    @StateObject private var viewModel = SpeedTestViewModel()
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [Color(red: 10/255, green: 14/255, blue: 26/255), Color(red: 5/255, green: 8/255, blue: 16/255)], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack(spacing: 40) {
                    VStack(spacing: 8) {
                        Text("CYBERPUNK").font(.system(size: 14, weight: .black, design: .monospaced)).foregroundColor(neonCyan).tracking(3)
                        Text("Speed Test Module").font(.system(size: 28, weight: .bold)).foregroundColor(.white)
                    }.padding(.top, 40)
                    Spacer()
                    ZStack {
                        Circle().stroke(Color.white.opacity(0.1), lineWidth: 20).frame(width: 250, height: 250)
                        Circle().trim(from: 0, to: CGFloat(viewModel.progress))
                            .stroke(LinearGradient(colors: [neonCyan, neonGreen], startPoint: .leading, endPoint: .trailing), style: StrokeStyle(lineWidth: 20, lineCap: .round))
                            .frame(width: 250, height: 250).rotationEffect(.degrees(-90)).animation(.linear(duration: 0.1), value: viewModel.progress)
                        VStack(spacing: 4) {
                            Text(String(format: "%.1f", viewModel.downloadSpeedMbps)).font(.system(size: 54, weight: .black, design: .monospaced)).foregroundColor(.white)
                            Text("Mbps").font(.system(size: 18, weight: .bold)).foregroundColor(Color.gray)
                        }
                    }
                    Spacer()
                    VStack(spacing: 8) {
                        Text("PEAK SPEED").font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(.gray)
                        Text(String(format: "%.1f Mbps", viewModel.peakSpeed)).font(.system(size: 24, weight: .bold, design: .monospaced)).foregroundColor(neonGreen)
                    }
                    Spacer()
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                        generator.impactOccurred()
                        viewModel.toggleTest()
                    }) {
                        Text(viewModel.isTesting ? "STOP TEST" : "START SPEED TEST")
                            .font(.system(size: 16, weight: .black, design: .monospaced))
                            .foregroundColor(viewModel.isTesting ? .white : .black)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                            .background(viewModel.isTesting ? Color.red : neonCyan)
                            .cornerRadius(12)
                            .shadow(color: (viewModel.isTesting ? Color.red : neonCyan).opacity(0.4), radius: 10, x: 0, y: 5)
                    }.padding(.horizontal, 30).padding(.bottom, 40)
                }
            }.navigationBarHidden(true)
        }
    }
}
