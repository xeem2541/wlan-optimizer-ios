import Foundation
import Combine
import SwiftUI

public final class BufferbloatViewModel: ObservableObject {
    @ObservedObject public var service = BufferbloatService.shared
    
    public init() {}
    
    public func startTest() {
        Task {
            await service.startTest()
        }
    }
}
