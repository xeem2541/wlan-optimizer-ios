import Foundation
import Combine
import SwiftUI

public final class PCBridgeViewModel: ObservableObject {
    @ObservedObject public var pcService = PCBridgeService.shared
    
    @Published public var inputIP: String = "192.168.1."
    @Published public var inputPort: String = "5050"
    
    public init() {
        self.inputIP = pcService.pcIPAddress
        self.inputPort = pcService.pcPort
    }
    
    public func connect() {
        pcService.connect(ip: inputIP, port: inputPort)
    }
    
    public func disconnect() {
        pcService.disconnect()
    }
    
    public func toggleStreaming() {
        Task {
            await pcService.togglePCStreamingMode()
        }
    }
    
    public func toggleScan() {
        Task {
            await pcService.togglePCBackgroundScan()
        }
    }
    
    public func useDemo() {
        pcService.enableDemoSimulation()
    }
}
