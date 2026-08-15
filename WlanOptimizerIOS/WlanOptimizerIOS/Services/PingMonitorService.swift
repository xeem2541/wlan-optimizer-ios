import Foundation
import Network
import Combine

public struct LatencySample: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let latencyMs: Double
    public let isDropped: Bool
    
    public init(timestamp: Date = Date(), latencyMs: Double, isDropped: Bool = false) {
        self.timestamp = timestamp
        self.latencyMs = latencyMs
        self.isDropped = isDropped
    }
}

public final class PingMonitorService: ObservableObject {
    public static let shared = PingMonitorService()
    
    @Published public var selectedTarget: PingTarget = PingTarget.defaults[0]
    @Published public var isMonitoring: Bool = false
    @Published public var stats = NetworkStats()
    @Published public var latencyHistory: [LatencySample] = []
    
    private let maxHistoryLength = 40
    private var monitorTask: Task<Void, Never>?
    private var previousLatency: Double?
    
    public init() {}
    
    public func startMonitoring(target: PingTarget? = nil) {
        if let target = target {
            self.selectedTarget = target
        }
        
        stopMonitoring()
        stats.reset()
        latencyHistory.removeAll()
        isMonitoring = true
        
        monitorTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self, self.isMonitoring else { break }
                
                let target = self.selectedTarget
                let latency = await self.pingSingle(host: target.host, port: target.port)
                
                await MainActor.run {
                    let prev = self.previousLatency
                    self.stats.recordSample(latency: latency, previousLatency: prev)
                    self.previousLatency = latency
                    
                    let sample = LatencySample(
                        latencyMs: latency ?? 0,
                        isDropped: (latency == nil)
                    )
                    
                    self.latencyHistory.append(sample)
                    if self.latencyHistory.count > self.maxHistoryLength {
                        self.latencyHistory.removeFirst()
                    }
                }
                
                // Sleep 700ms between pings
                try? await Task.sleep(nanoseconds: 700_000_000)
            }
        }
    }
    
    public func stopMonitoring() {
        isMonitoring = false
        monitorTask?.cancel()
        monitorTask = nil
    }
    
    // MARK: - High precision TCP / HTTP Ping
    public func pingSingle(host: String, port: Int) async -> Double? {
        return await withCheckedContinuation { continuation in
            let nwHost = NWEndpoint.Host(host)
            guard let nwPort = NWEndpoint.Port(rawValue: UInt16(port)) else {
                continuation.resume(returning: nil)
                return
            }
            
            let tcpOptions = NWProtocolTCP.Options()
            tcpOptions.connectionTimeout = 2 // 2 seconds timeout
            tcpOptions.enableFastOpen = true
            
            let params = NWParameters(tls: nil, tcp: tcpOptions)
            params.prohibitExpensivePaths = false
            
            let connection = NWConnection(host: nwHost, port: nwPort, using: params)
            let startTime = DispatchTime.now()
            
            var didResume = false
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    guard !didResume else { return }
                    didResume = true
                    let endTime = DispatchTime.now()
                    let nanoDiff = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
                    let ms = Double(nanoDiff) / 1_000_000.0
                    connection.cancel()
                    continuation.resume(returning: ms)
                    
                case .failed, .cancelled:
                    guard !didResume else { return }
                    didResume = true
                    connection.cancel()
                    continuation.resume(returning: nil)
                    
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            // Safety timeout
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                if !didResume {
                    didResume = true
                    connection.cancel()
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
