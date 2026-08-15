import Foundation

public struct DNSProvider: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let providerDescription: String
    public let iconName: String
    public let primaryIPv4: String
    public let secondaryIPv4: String
    public let dohURL: String
    public let dotServerName: String
    public let tag: String
    public var currentLatencyMs: Double?
    public var isFastest: Bool = false
    
    public init(
        id: String,
        name: String,
        providerDescription: String,
        iconName: String,
        primaryIPv4: String,
        secondaryIPv4: String,
        dohURL: String,
        dotServerName: String,
        tag: String,
        currentLatencyMs: Double? = nil,
        isFastest: Bool = false
    ) {
        self.id = id
        self.name = name
        self.providerDescription = providerDescription
        self.iconName = iconName
        self.primaryIPv4 = primaryIPv4
        self.secondaryIPv4 = secondaryIPv4
        self.dohURL = dohURL
        self.dotServerName = dotServerName
        self.tag = tag
        self.currentLatencyMs = currentLatencyMs
        self.isFastest = isFastest
    }
}

public extension DNSProvider {
    static let presets: [DNSProvider] = [
        DNSProvider(
            id: "cloudflare",
            name: "Cloudflare 1.1.1.1",
            providerDescription: "Lowest latency worldwide, privacy-focused Anycast DNS",
            iconName: "bolt.fill",
            primaryIPv4: "1.1.1.1",
            secondaryIPv4: "1.0.0.1",
            dohURL: "https://cloudflare-dns.com/dns-query",
            dotServerName: "one.one.one.one",
            tag: "Ultra Low Latency"
        ),
        DNSProvider(
            id: "google",
            name: "Google Public DNS",
            providerDescription: "Massive global cache, ultra-fast for YouTube & Google Services",
            iconName: "globe.asia.australia.fill",
            primaryIPv4: "8.8.8.8",
            secondaryIPv4: "8.8.4.4",
            dohURL: "https://dns.google/dns-query",
            dotServerName: "dns.google",
            tag: "Global Speed"
        ),
        DNSProvider(
            id: "adguard",
            name: "AdGuard Ad-Block DNS",
            providerDescription: "Blocks intrusive ads, mobile popups & telemetry trackers",
            iconName: "shield.lefthalf.filled",
            primaryIPv4: "94.140.14.14",
            secondaryIPv4: "94.140.15.15",
            dohURL: "https://dns.adguard-dns.com/dns-query",
            dotServerName: "dns.adguard-dns.com",
            tag: "Ad & Tracker Shield"
        ),
        DNSProvider(
            id: "quad9",
            name: "Quad9 Security DNS",
            providerDescription: "Blocks malicious domains, phishing, and scam links automatically",
            iconName: "lock.shield.fill",
            primaryIPv4: "9.9.9.9",
            secondaryIPv4: "149.112.112.112",
            dohURL: "https://dns.quad9.net/dns-query",
            dotServerName: "dns.quad9.net",
            tag: "Malware Defense"
        ),
        DNSProvider(
            id: "nextdns",
            name: "NextDNS",
            providerDescription: "Cloud-based personal firewall with ultra-low latency routing",
            iconName: "slider.horizontal.3",
            primaryIPv4: "45.90.28.0",
            secondaryIPv4: "45.90.30.0",
            dohURL: "https://dns.nextdns.io",
            dotServerName: "dns.nextdns.io",
            tag: "Customizable"
        ),
        DNSProvider(
            id: "opendns",
            name: "Cisco OpenDNS",
            providerDescription: "Enterprise grade reliability with smart phishing protection",
            iconName: "server.rack",
            primaryIPv4: "208.67.222.222",
            secondaryIPv4: "208.67.220.220",
            dohURL: "https://doh.opendns.com/dns-query",
            dotServerName: "dns.opendns.com",
            tag: "High Stability"
        )
    ]
}
