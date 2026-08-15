import Foundation
import Combine

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
                if speed > (self?.peakSpeed ?? 0) {
                    self?.peakSpeed = speed
                }
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
