import Foundation

public struct PingTarget: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let category: TargetCategory
    public let host: String
    public let port: Int
    public let iconName: String
    
    public enum TargetCategory: String, CaseIterable {
        case games = "Mobile Games"
        case dns = "Fast DNS"
        case global = "Global CDNs"
        case gateway = "Local Router"
    }
    
    public init(id: String, name: String, category: TargetCategory, host: String, port: Int = 80, iconName: String) {
        self.id = id
        self.name = name
        self.category = category
        self.host = host
        self.port = port
        self.iconName = iconName
    }
}

public extension PingTarget {
    static let defaults: [PingTarget] = [
        // Mobile Games
        PingTarget(id: "rov", name: "RoV / Arena of Valor (TH)", category: .games, host: "sg.garena.com", port: 443, iconName: "gamecontroller.fill"),
        PingTarget(id: "pubgm", name: "PUBG Mobile (SEA Server)", category: .games, host: "pubgmobile.com", port: 443, iconName: "flame.fill"),
        PingTarget(id: "freefire", name: "Free Fire (TH/SEA)", category: .games, host: "ff.garena.com", port: 443, iconName: "cross.fill"),
        PingTarget(id: "valorant_sg", name: "Valorant / Riot (Singapore)", category: .games, host: "sgp.valve.net", port: 27015, iconName: "target"),
        PingTarget(id: "genshin", name: "Genshin Impact (Asia)", category: .games, host: "osasiacheck.yuanshen.com", port: 443, iconName: "sparkles"),
        PingTarget(id: "roblox", name: "Roblox Global Server", category: .games, host: "roblox.com", port: 443, iconName: "cube.fill"),
        
        // Fast DNS & CDN
        PingTarget(id: "cloudflare", name: "Cloudflare Edge (1.1.1.1)", category: .dns, host: "1.1.1.1", port: 53, iconName: "bolt.fill"),
        PingTarget(id: "google", name: "Google Anycast (8.8.8.8)", category: .dns, host: "8.8.8.8", port: 53, iconName: "globe"),
        PingTarget(id: "fast_com", name: "Netflix Fast.com Speed CDN", category: .global, host: "fast.com", port: 443, iconName: "speedometer"),
        PingTarget(id: "apple", name: "Apple Services CDN", category: .global, host: "apple.com", port: 443, iconName: "apple.logo"),
        
        // Local Gateway
        PingTarget(id: "gateway", name: "Wi-Fi Router Gateway (192.168.1.1)", category: .gateway, host: "192.168.1.1", port: 80, iconName: "wifi.router")
    ]
}
