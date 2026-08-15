import Foundation

public struct NetworkStats {
    public var currentPing: Double = 0.0
    public var minPing: Double = 999.0
    public var maxPing: Double = 0.0
    public var avgPing: Double = 0.0
    public var jitter: Double = 0.0
    public var packetLossPercent: Double = 0.0
    public var totalPacketsSent: Int = 0
    public var totalPacketsReceived: Int = 0
    public var stabilityScore: Int = 100
    
    public init() {}
    
    public mutating func recordSample(latency: Double?, previousLatency: Double?) {
        totalPacketsSent += 1
        
        if let latency = latency, latency >= 0 {
            totalPacketsReceived += 1
            currentPing = latency
            if latency < minPing { minPing = latency }
            if latency > maxPing { maxPing = latency }
            
            // Calculate running average
            avgPing = ((avgPing * Double(totalPacketsReceived - 1)) + latency) / Double(totalPacketsReceived)
            
            // RFC 3550 Jitter calculation
            if let prev = previousLatency, prev >= 0 {
                let diff = abs(latency - prev)
                jitter = jitter + (diff - jitter) / 16.0
            }
        }
        
        // Calculate packet loss
        if totalPacketsSent > 0 {
            let lost = totalPacketsSent - totalPacketsReceived
            packetLossPercent = (Double(lost) / Double(totalPacketsSent)) * 100.0
        }
        
        // Compute stability score (0-100)
        let pingPenalty = min(40.0, avgPing * 0.4)
        let jitterPenalty = min(30.0, jitter * 1.5)
        let lossPenalty = min(30.0, packetLossPercent * 3.0)
        let score = 100.0 - (pingPenalty + jitterPenalty + lossPenalty)
        stabilityScore = max(0, min(100, Int(score)))
    }
    
    public mutating func reset() {
        currentPing = 0.0
        minPing = 999.0
        maxPing = 0.0
        avgPing = 0.0
        jitter = 0.0
        packetLossPercent = 0.0
        totalPacketsSent = 0
        totalPacketsReceived = 0
        stabilityScore = 100
    }
}
