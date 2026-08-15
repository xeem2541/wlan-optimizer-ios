import Foundation
import Combine
import SwiftUI

public enum BoostMode: String, CaseIterable, Identifiable {
    case gaming = "Gaming Ultra"
    case adBlock = "Ad-Block Speed"
    case streaming = "Stream Stable"
    
    public var id: String { rawValue }
    
    public var subtitle: String {
        switch self {
        case .gaming: return "Cloudflare 1.1.1.1 Gaming Profile"
        case .adBlock: return "AdGuard Tracker & Bloat Stripper"
        case .streaming: return "Google Anycast Global Cache"
        }
    }
    
    public var iconName: String {
        switch self {
        case .gaming: return "bolt.shield.fill"
        case .adBlock: return "shield.lefthalf.filled"
        case .streaming: return "play.tv.fill"
        }
    }
    
    public var associatedProviderId: String {
        switch self {
        case .gaming: return "cloudflare"
        case .adBlock: return "adguard"
        case .streaming: return "google"
        }
    }
}

public final class TurboBoostViewModel: ObservableObject {
    @Published public var isBoostActive: Bool = false
    @Published public var selectedMode: BoostMode = .gaming
    @Published public var livePing: Double = 14.2
    @Published public var latencySavedPercent: Int = 42
    @Published public var dataSavedMB: Double = 128.5
    @Published public var isPreparingProfile: Bool = false
    @Published public var showSafariInstallAlert: Bool = false
    @Published public var profileInstallURL: URL? = nil
    
    private var pingTimer: Timer?
    
    public init() {
        startLivePingSimulation()
    }
    
    public func toggleBoost() {
        if isBoostActive {
            isBoostActive = false
            withAnimation(.spring()) {
                livePing = 38.0
            }
        } else {
            // Activate boost
            isPreparingProfile = true
            
            let providerId = selectedMode.associatedProviderId
            guard let provider = DNSOptimizerService.shared.providers.first(where: { $0.id == providerId }) else {
                isPreparingProfile = false
                return
            }
            
            DNSOptimizerService.shared.startLocalProfileServer(for: provider) { [weak self] url in
                guard let self = self else { return }
                self.isPreparingProfile = false
                self.isBoostActive = true
                self.profileInstallURL = url
                self.showSafariInstallAlert = true
                
                withAnimation(.spring()) {
                    self.livePing = 12.5
                }
            }
        }
    }
    
    private func startLivePingSimulation() {
        pingTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isBoostActive {
                let jitter = Double.random(in: -1.2...1.2)
                self.livePing = max(8.0, 13.5 + jitter)
            } else {
                let jitter = Double.random(in: -4.5...6.0)
                self.livePing = max(20.0, 39.0 + jitter)
            }
        }
    }
}
