import Foundation
import Combine
import SwiftUI

public final class PingHUDViewModel: ObservableObject {
    @ObservedObject public var pingService = PingMonitorService.shared
    
    @Published public var availableTargets: [PingTarget] = PingTarget.defaults
    @Published public var selectedCategory: PingTarget.TargetCategory = .games
    
    public var filteredTargets: [PingTarget] {
        availableTargets.filter { $0.category == selectedCategory }
    }
    
    public init() {
        pingService.startMonitoring(target: availableTargets[0])
    }
    
    public func selectTarget(_ target: PingTarget) {
        pingService.startMonitoring(target: target)
    }
}
