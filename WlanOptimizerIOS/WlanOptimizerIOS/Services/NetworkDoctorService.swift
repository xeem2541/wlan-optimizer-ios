import Foundation
import Network
import UIKit

public struct DiagnosticItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let status: DiagnosticStatus
    public let message: String
    public let solution: String
    public let settingsURL: String?
    
    public enum DiagnosticStatus {
        case optimal
        case warning
        case critical
        
        public var icon: String {
            switch self {
            case .optimal: return "checkmark.seal.fill"
            case .warning: return "exclamationmark.triangle.fill"
            case .critical: return "xmark.octagon.fill"
            }
        }
        
        public var colorHex: String {
            switch self {
            case .optimal: return "#00E676"
            case .warning: return "#FFD600"
            case .critical: return "#FF5252"
            }
        }
    }
}

public final class NetworkDoctorService: ObservableObject {
    public static let shared = NetworkDoctorService()
    
    @Published public var isWiFiConnected: Bool = false
    @Published public var isCellularConnected: Bool = false
    @Published public var isExpensivePath: Bool = false
    @Published public var isConstrained: Bool = false
    @Published public var diagnostics: [DiagnosticItem] = []
    
    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "com.wlanoptimizer.pathmonitor")
    
    public init() {
        startMonitoring()
    }
    
    private func startMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isWiFiConnected = path.usesInterfaceType(.wifi)
                self?.isCellularConnected = path.usesInterfaceType(.cellular)
                self?.isExpensivePath = path.isExpensive
                self?.isConstrained = path.isConstrained
                self?.runDiagnostics()
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }
    
    public func runDiagnostics() {
        var list: [DiagnosticItem] = []
        
        // 1. Connection Type Check
        if isWiFiConnected {
            list.append(DiagnosticItem(
                title: "Wi-Fi High Speed Connection",
                status: .optimal,
                message: "เชื่อมต่อ Wi-Fi เรียบร้อยแล้ว สัญญาณพร้อมสำหรับเปิดโหมดความเร็วสูง",
                solution: "เชื่อมต่อคลื่น 5GHz หรือ 6GHz เพื่อลดสัญญาณรบกวน",
                settingsURL: "App-Prefs:root=WIFI"
            ))
        } else if isCellularConnected {
            list.append(DiagnosticItem(
                title: "Cellular 4G/5G Network",
                status: isExpensivePath ? .warning : .optimal,
                message: "กำลังใช้งานสัญญาณเน็ตมือถือ (Cellular Data)",
                solution: "หากต้องการค่า Ping ต่ำพิเศษ แนะนำให้ต่อ Wi-Fi ที่รองรับ 5GHz",
                settingsURL: "App-Prefs:root=MOBILE_DATA_SETTINGS_ID"
            ))
        } else {
            list.append(DiagnosticItem(
                title: "No Internet Connection",
                status: .critical,
                message: "ไม่พบการเชื่อมต่อเครือข่าย",
                solution: "กรุณาเปิด Wi-Fi หรือ Cellular ในการตั้งค่าเครื่อง",
                settingsURL: "App-Prefs:root=WIFI"
            ))
        }
        
        // 2. Low Data Mode (Constrained)
        if isConstrained {
            list.append(DiagnosticItem(
                title: "Low Data Mode กำลังเปิดอยู่",
                status: .warning,
                message: "iOS กำลังจำกัดการส่งข้อมูลเบื้องหลัง ซึ่งอาจทำให้การตอบสนองของเกมล่าช้า",
                solution: "เข้าไปที่ Settings > Wi-Fi > แตะเครื่องหมาย (i) ข้างชื่อ Wi-Fi แล้วปิด 'Low Data Mode'",
                settingsURL: "App-Prefs:root=WIFI"
            ))
        } else {
            list.append(DiagnosticItem(
                title: "Full Bandwidth Mode Active",
                status: .optimal,
                message: "ไม่ได้เปิดโหมดประหยัดข้อมูล แบนด์วิดท์ทำงานได้เต็มสปีด 100%",
                solution: "ยอดเยี่ยม! สปีดพร้อมใช้งานเต็มกำลัง",
                settingsURL: nil
            ))
        }
        
        // 3. Encrypted DNS / DoH Status
        list.append(DiagnosticItem(
            title: "Encrypted DNS-over-HTTPS (DoH)",
            status: .optimal,
            message: "รองรับการเข้ารหัส DNS Query ระดับระบบผ่าน Apple .mobileconfig",
            solution: "ไปที่แท็บ 'DNS Optimizer' เพื่อทดสอบและติดตั้งโปรไฟล์ความเร็วสูง",
            settingsURL: nil
        ))
        
        // 4. Private Wi-Fi Address Advice
        list.append(DiagnosticItem(
            title: "Private Wi-Fi Address (คำแนะนำเราเตอร์)",
            status: .optimal,
            message: "ฟังก์ชันสุ่ม MAC Address ของ Apple ช่วยเรื่องความเป็นส่วนตัว",
            solution: "หากเราเตอร์ที่บ้านมีการจำกัด Bandwidth ตาม MAC ให้ลองปิด Private Address สำหรับ Wi-Fi บ้าน",
            settingsURL: "App-Prefs:root=WIFI"
        ))
        
        self.diagnostics = list
    }
    
    public func openSettingsURL(_ urlString: String) {
        guard let url = URL(string: urlString) else {
            if let fallback = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(fallback)
            }
            return
        }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else if let fallback = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(fallback)
        }
    }
}
