import Foundation
import Combine

public struct PCStatusResponse: Codable {
    public let isStreamingModeOn: Bool
    public let isBackgroundScanDisabled: Bool
    public let isAutoStartEnabled: Bool
    public let pcPing: Double
    public let pcJitter: Double
    public let pcPacketLoss: Double
    public let adapterName: String
    public let signalQuality: Int
    public let bssid: String
}

public final class PCBridgeService: ObservableObject {
    public static let shared = PCBridgeService()
    
    @Published public var isConnected: Bool = false
    @Published public var pcIPAddress: String = "192.168.1.100"
    @Published public var pcPort: String = "5050"
    @Published public var isConnecting: Bool = false
    @Published public var lastErrorMessage: String? = nil
    
    // Live PC Telemetry
    @Published public var pcStreamingMode: Bool = false
    @Published public var pcBackgroundScanDisabled: Bool = false
    @Published public var pcPing: Double = 0.0
    @Published public var pcJitter: Double = 0.0
    @Published public var pcLoss: Double = 0.0
    @Published public var pcAdapterName: String = "Intel Wi-Fi 6E AX211"
    @Published public var pcSignalQuality: Int = 98
    
    private var syncTask: Task<Void, Never>?
    
    public init() {}
    
    public func connect(ip: String, port: String) {
        self.pcIPAddress = ip
        self.pcPort = port
        self.isConnecting = true
        self.lastErrorMessage = nil
        
        syncTask?.cancel()
        syncTask = Task { [weak self] in
            while !Task.isCancelled {
                guard let self = self else { break }
                await self.fetchPCStatus()
                try? await Task.sleep(nanoseconds: 1_000_000_000) // Poll every 1s
            }
        }
    }
    
    public func disconnect() {
        syncTask?.cancel()
        syncTask = nil
        isConnected = false
        isConnecting = false
    }
    
    private func fetchPCStatus() async {
        guard let url = URL(string: "http://\(pcIPAddress):\(pcPort)/api/status") else {
            await MainActor.run {
                self.isConnecting = false
                self.isConnected = false
                self.lastErrorMessage = "Invalid IP or Port"
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 1.8
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decoded = try JSONDecoder().decode(PCStatusResponse.self, from: data)
                await MainActor.run {
                    self.isConnected = true
                    self.isConnecting = false
                    self.pcStreamingMode = decoded.isStreamingModeOn
                    self.pcBackgroundScanDisabled = decoded.isBackgroundScanDisabled
                    self.pcPing = decoded.pcPing
                    self.pcJitter = decoded.pcJitter
                    self.pcLoss = decoded.pcPacketLoss
                    self.pcAdapterName = decoded.adapterName
                    self.pcSignalQuality = decoded.signalQuality
                    self.lastErrorMessage = nil
                }
            }
        } catch {
            await MainActor.run {
                // If demo mode or initial connection
                if !self.isConnected {
                    self.isConnecting = false
                    self.lastErrorMessage = "ไม่พบ WLAN Optimizer บน PC (ตรวจสอบว่าเปิดโปรแกรมบนคอมแล้ว)"
                }
            }
        }
    }
    
    public func togglePCStreamingMode() async {
        guard let url = URL(string: "http://\(pcIPAddress):\(pcPort)/api/toggle-streaming") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
    }
    
    public func togglePCBackgroundScan() async {
        guard let url = URL(string: "http://\(pcIPAddress):\(pcPort)/api/toggle-scan") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        _ = try? await URLSession.shared.data(for: request)
    }
    
    // Demo Mode for UI testing when offline from PC
    public func enableDemoSimulation() {
        self.isConnected = true
        self.isConnecting = false
        self.pcStreamingMode = true
        self.pcBackgroundScanDisabled = true
        self.pcPing = 12.4
        self.pcJitter = 0.8
        self.pcLoss = 0.0
        self.pcAdapterName = "Intel Wi-Fi 6 AX200 (PC)"
        self.pcSignalQuality = 99
        self.lastErrorMessage = nil
    }
}
