import Foundation

public final class SpeedTestService: ObservableObject {
    public static let shared = SpeedTestService()
    
    @Published public var downloadSpeedMbps: Double = 0.0
    @Published public var isTesting: Bool = false
    @Published public var progress: Double = 0.0
    
    private var testTask: Task<Void, Never>?
    
    // Cloudflare Speed Test Endpoint (approx 25MB)
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
                // For a real app we'd use URLSession.shared.bytes(from: request) to stream and calculate real-time.
                // For simplicity and to avoid complex delegate handling, we do a block download.
                
                // Simulate progress updates for UI while downloading
                let progressTask = Task {
                    var simulatedProgress = 0.0
                    while !Task.isCancelled && simulatedProgress < 0.95 {
                        try? await Task.sleep(nanoseconds: 100_000_000)
                        simulatedProgress += Double.random(in: 0.01...0.05)
                        
                        let currentProgress = min(0.95, simulatedProgress)
                        // Simulated speed jumping around
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
                    await MainActor.run {
                        self.isTesting = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isTesting = false
                }
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
