import Foundation
import Combine
import SwiftUI

public final class DNSBenchmarkViewModel: ObservableObject {
    @ObservedObject public var dnsService = DNSOptimizerService.shared
    @Published public var selectedProviderForInstall: DNSProvider?
    @Published public var showInstallSheet: Bool = false
    @Published public var hostedInstallURL: URL?
    
    public init() {}
    
    public func startRace() {
        Task {
            await dnsService.runBenchmark()
        }
    }
    
    public func prepareInstall(for provider: DNSProvider) {
        self.selectedProviderForInstall = provider
        dnsService.startLocalProfileServer(for: provider) { [weak self] url in
            DispatchQueue.main.async {
                self?.hostedInstallURL = url
                self?.showInstallSheet = true
            }
        }
    }
}
