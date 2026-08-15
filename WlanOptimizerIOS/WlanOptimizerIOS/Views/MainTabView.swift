import SwiftUI
import UIKit

public struct MainTabView: View {
    @State private var selectedTab: Int = 0
    
    private let neonGreen = Color(red: 0, green: 230/255, blue: 118/255)
    private let neonCyan = Color(red: 0, green: 229/255, blue: 255/255)
    
    public init() {
        // Customize default UITabBar appearance
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 10/255, green: 14/255, blue: 26/255, alpha: 0.95)
        
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            TurboBoostView()
                .tabItem {
                    Image(systemName: "bolt.fill")
                    Text("Boost")
                }
                .tag(0)
            
            LivePingHUDView()
                .tabItem {
                    Image(systemName: "waveform.path.ecg")
                    Text("Live HUD")
                }
                .tag(1)
            
            DNSOptimizerView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Fast DNS")
                }
                .tag(2)
            
            BufferbloatView()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Bufferbloat")
                }
                .tag(3)
            
            PCBridgeView()
                .tabItem {
                    Image(systemName: "desktopcomputer")
                    Text("PC Remote")
                }
                .tag(4)
            
            NetworkDoctorView()
                .tabItem {
                    Image(systemName: "cross.case.fill")
                    Text("Doctor")
                }
                .tag(5)
                
            SpeedTestView()
                .tabItem {
                    Image(systemName: "speedometer")
                    Text("Speed")
                }
                .tag(6)
        }
        .accentColor(neonCyan)
    }
}
