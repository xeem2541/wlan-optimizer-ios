import Foundation
import Network

public final class DNSOptimizerService: ObservableObject {
    public static let shared = DNSOptimizerService()
    
    @Published public var providers: [DNSProvider] = DNSProvider.presets
    @Published public var isBenchmarking: Bool = false
    @Published public var benchmarkProgress: Double = 0.0
    @Published public var activeProfileName: String? = nil
    
    private var localServerTask: Task<Void, Never>?
    private var localServerListener: NWListener?
    private var currentHostedMobileConfig: Data?
    
    public init() {}
    
    // MARK: - Benchmark All DNS Providers in Parallel
    public func runBenchmark() async {
        await MainActor.run {
            self.isBenchmarking = true
            self.benchmarkProgress = 0.0
        }
        
        var updatedProviders = providers
        let totalCount = Double(updatedProviders.count)
        var completedCount: Double = 0
        
        await withTaskGroup(of: (Int, Double?).self) { group in
            for (index, provider) in updatedProviders.enumerated() {
                group.addTask {
                    let latency = await self.measureLatency(for: provider)
                    return (index, latency)
                }
            }
            
            for await (index, latency) in group {
                updatedProviders[index].currentLatencyMs = latency
                completedCount += 1
                let progress = completedCount / totalCount
                await MainActor.run {
                    self.benchmarkProgress = progress
                }
            }
        }
        
        // Find fastest
        var lowestLatency: Double = 999999.0
        var fastestIndex: Int? = nil
        
        for (idx, p) in updatedProviders.enumerated() {
            if let lat = p.currentLatencyMs, lat < lowestLatency {
                lowestLatency = lat
                fastestIndex = idx
            }
        }
        
        for idx in 0..<updatedProviders.count {
            updatedProviders[idx].isFastest = (idx == fastestIndex)
        }
        
        // Sort by latency ascending
        updatedProviders.sort { (p1, p2) -> Bool in
            let l1 = p1.currentLatencyMs ?? 9999
            let l2 = p2.currentLatencyMs ?? 9999
            return l1 < l2
        }
        
        let finalProviders = updatedProviders
        await MainActor.run {
            self.providers = finalProviders
            self.isBenchmarking = false
        }
    }
    
    // MARK: - Measure Single Provider Latency
    public func measureLatency(for provider: DNSProvider) async -> Double? {
        guard let url = URL(string: provider.dohURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 2.5
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        var latencies: [Double] = []
        
        for _ in 0..<3 {
            let start = DispatchTime.now()
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                let end = DispatchTime.now()
                if let httpResponse = response as? HTTPURLResponse, (200...499).contains(httpResponse.statusCode) {
                    let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
                    let ms = Double(nanoTime) / 1_000_000.0
                    latencies.append(ms)
                }
            } catch {
                // If DoH probe fails, fallback to TCP timing on port 53
                let tcpMs = await measureTCPConnection(host: provider.primaryIPv4, port: 53)
                if let tcpMs = tcpMs {
                    latencies.append(tcpMs)
                }
            }
            try? await Task.sleep(nanoseconds: 100_000_000) // 100ms gap
        }
        
        guard !latencies.isEmpty else { return nil }
        return latencies.reduce(0.0, +) / Double(latencies.count)
    }
    
    private func measureTCPConnection(host: String, port: UInt16) async -> Double? {
        return await withCheckedContinuation { continuation in
            let nwHost = NWEndpoint.Host(host)
            guard let nwPort = NWEndpoint.Port(rawValue: port) else {
                continuation.resume(returning: nil)
                return
            }
            
            let connection = NWConnection(host: nwHost, port: nwPort, using: .tcp)
            let start = DispatchTime.now()
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    let end = DispatchTime.now()
                    let ms = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000.0
                    connection.cancel()
                    continuation.resume(returning: ms)
                case .failed, .cancelled:
                    connection.cancel()
                    continuation.resume(returning: nil)
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            DispatchQueue.global().asyncAfter(deadline: .now() + 2.0) {
                connection.cancel()
            }
        }
    }
    
    // MARK: - Generate Apple Encrypted DNS .mobileconfig Payload
    public func generateMobileConfig(for provider: DNSProvider) -> Data? {
        let profileUUID = UUID().uuidString
        let payloadUUID = UUID().uuidString
        
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <dict>
            <key>PayloadContent</key>
            <array>
                <dict>
                    <key>DNSSettings</key>
                    <dict>
                        <key>DNSProtocol</key>
                        <string>HTTPS</string>
                        <key>ServerURL</key>
                        <string>\(provider.dohURL)</string>
                        <key>ServerAddresses</key>
                        <array>
                            <string>\(provider.primaryIPv4)</string>
                            <string>\(provider.secondaryIPv4)</string>
                        </array>
                    </dict>
                    <key>PayloadDescription</key>
                    <string>Configures high-speed encrypted DNS-over-HTTPS for \(provider.name)</string>
                    <key>PayloadDisplayName</key>
                    <string>\(provider.name) Turbo DNS</string>
                    <key>PayloadIdentifier</key>
                    <string>com.wlanoptimizer.dns.\(provider.id)</string>
                    <key>PayloadType</key>
                    <string>com.apple.dnsSettings.managed</string>
                    <key>PayloadUUID</key>
                    <string>\(payloadUUID)</string>
                    <key>PayloadVersion</key>
                    <integer>1</integer>
                    <key>ProhibitDisablement</key>
                    <false/>
                </dict>
            </array>
            <key>PayloadDescription</key>
            <string>Accelerates network latency and secures DNS resolution via \(provider.name)</string>
            <key>PayloadDisplayName</key>
            <string>WLAN Optimizer - \(provider.name)</string>
            <key>PayloadIdentifier</key>
            <string>com.wlanoptimizer.profile.\(provider.id)</string>
            <key>PayloadOrganization</key>
            <string>WLAN Optimizer Pro</string>
            <key>PayloadRemovalDisallowed</key>
            <false/>
            <key>PayloadType</key>
            <string>Configuration</string>
            <key>PayloadUUID</key>
            <string>\(profileUUID)</string>
            <key>PayloadVersion</key>
            <integer>1</integer>
        </dict>
        </plist>
        """
        
        return xml.data(using: .utf8)
    }
    
    // MARK: - Save and Open Profile in iOS Safari / Settings
    public func exportProfileToFile(for provider: DNSProvider) -> URL? {
        guard let data = generateMobileConfig(for: provider) else { return nil }
        
        let tempDir = FileManager.default.temporaryDirectory
        let fileName = "\(provider.id)_fast_dns.mobileconfig"
        let fileURL = tempDir.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to save mobileconfig: \(error)")
            return nil
        }
    }
    
    // MARK: - Local Micro-Server for 1-Tap Safari Profile Download
    public func startLocalProfileServer(for provider: DNSProvider, completion: @escaping (URL?) -> Void) {
        guard let configData = generateMobileConfig(for: provider) else {
            completion(nil)
            return
        }
        
        self.currentHostedMobileConfig = configData
        
        do {
            let port: NWEndpoint.Port = 8089
            let listener = try NWListener(using: .tcp, on: port)
            self.localServerListener = listener
            
            listener.newConnectionHandler = { [weak self] connection in
                self?.handleHTTPConnection(connection)
            }
            
            listener.stateUpdateHandler = { state in
                if case .ready = state {
                    let localURL = URL(string: "http://127.0.0.1:8089/install.mobileconfig")
                    DispatchQueue.main.async {
                        completion(localURL)
                    }
                }
            }
            
            listener.start(queue: .global())
        } catch {
            print("Failed to start local listener: \(error)")
            completion(nil)
        }
    }
    
    private func handleHTTPConnection(_ connection: NWConnection) {
        connection.start(queue: .global())
        
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { [weak self] (data, _, _, _) in
            guard let self = self, let configData = self.currentHostedMobileConfig else {
                connection.cancel()
                return
            }
            
            let httpHeader = """
            HTTP/1.1 200 OK\r
            Content-Type: application/x-apple-aspen-config\r
            Content-Disposition: attachment; filename="FastDNS.mobileconfig"\r
            Content-Length: \(configData.count)\r
            Connection: close\r
            \r\n
            """
            
            var responseData = httpHeader.data(using: .utf8)!
            responseData.append(configData)
            
            connection.send(content: responseData, completion: .contentProcessed({ _ in
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.0) {
                    connection.cancel()
                }
            }))
        }
    }
    
    public func stopLocalProfileServer() {
        localServerListener?.cancel()
        localServerListener = nil
    }
}
