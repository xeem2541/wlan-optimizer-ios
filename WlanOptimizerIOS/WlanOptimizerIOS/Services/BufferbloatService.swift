import Foundation

public enum BufferbloatPhase: String {
    case idle = "Ready to Test"
    case testingUnloaded = "Phase 1/3: Measuring Idle Latency..."
    case testingDownload = "Phase 2/3: Measuring Download Load Latency..."
    case testingUpload = "Phase 3/3: Measuring Upload Load Latency..."
    case completed = "Test Completed"
}

public final class BufferbloatService: ObservableObject {
    public static let shared = BufferbloatService()
    
    @Published public var isRunning: Bool = false
    @Published public var phase: BufferbloatPhase = .idle
    @Published public var progress: Double = 0.0
    @Published public var livePing: Double = 0.0
    @Published public var result: BufferbloatResult?
    
    private let testHost = "1.1.1.1"
    private let testPort = 53
    
    public init() {}
    
    public func startTest() async {
        await MainActor.run {
            self.isRunning = true
            self.phase = .testingUnloaded
            self.progress = 0.0
            self.result = nil
        }
        
        // 1. Unloaded Ping (Idle)
        var unloadedSamples: [Double] = []
        for i in 1...6 {
            if let ping = await PingMonitorService.shared.pingSingle(host: testHost, port: testPort) {
                unloadedSamples.append(ping)
                await MainActor.run { self.livePing = ping }
            }
            await MainActor.run { self.progress = Double(i) / 24.0 }
            try? await Task.sleep(nanoseconds: 250_000_000)
        }
        let avgUnloaded = unloadedSamples.isEmpty ? 25.0 : (unloadedSamples.reduce(0, +) / Double(unloadedSamples.count))
        
        // 2. Download Loaded Ping
        await MainActor.run {
            self.phase = .testingDownload
        }
        
        let downloadWorker = Task {
            await self.simulateDownloadLoad()
        }
        
        var downloadSamples: [Double] = []
        for i in 7...15 {
            if let ping = await PingMonitorService.shared.pingSingle(host: testHost, port: testPort) {
                downloadSamples.append(ping)
                await MainActor.run { self.livePing = ping }
            }
            await MainActor.run { self.progress = Double(i) / 24.0 }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
        downloadWorker.cancel()
        let avgDownloadLoaded = downloadSamples.isEmpty ? avgUnloaded + 10 : (downloadSamples.reduce(0, +) / Double(downloadSamples.count))
        
        // 3. Upload Loaded Ping
        await MainActor.run {
            self.phase = .testingUpload
        }
        
        let uploadWorker = Task {
            await self.simulateUploadLoad()
        }
        
        var uploadSamples: [Double] = []
        for i in 16...24 {
            if let ping = await PingMonitorService.shared.pingSingle(host: testHost, port: testPort) {
                uploadSamples.append(ping)
                await MainActor.run { self.livePing = ping }
            }
            await MainActor.run { self.progress = Double(i) / 24.0 }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }
        uploadWorker.cancel()
        let avgUploadLoaded = uploadSamples.isEmpty ? avgUnloaded + 15 : (uploadSamples.reduce(0, +) / Double(uploadSamples.count))
        
        // Calculate result
        let testResult = BufferbloatResult(
            unloadedPing: avgUnloaded,
            downloadLoadedPing: avgDownloadLoaded,
            uploadLoadedPing: avgUploadLoaded
        )
        
        await MainActor.run {
            self.result = testResult
            self.phase = .completed
            self.isRunning = false
            self.progress = 1.0
        }
    }
    
    private func simulateDownloadLoad() async {
        let testURLs = [
            "https://speed.cloudflare.com/__down?bytes=15000000",
            "https://speed.cloudflare.com/__down?bytes=20000000",
            "https://speed.cloudflare.com/__down?bytes=25000000"
        ]
        
        await withTaskGroup(of: Void.self) { group in
            for str in testURLs {
                guard let url = URL(string: str) else { continue }
                group.addTask {
                    let req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 4.0)
                    _ = try? await URLSession.shared.data(for: req)
                }
            }
        }
    }
    
    private func simulateUploadLoad() async {
        guard let url = URL(string: "https://speed.cloudflare.com/__up") else { return }
        let dummyData = Data(repeating: 0x41, count: 5_000_000) // 5MB payload
        
        var request = URLRequest(url: url, timeoutInterval: 4.0)
        request.httpMethod = "POST"
        request.httpBody = dummyData
        
        _ = try? await URLSession.shared.data(for: request)
    }
}
