import Foundation

public struct BufferbloatResult: Identifiable {
    public let id = UUID()
    public let unloadedPing: Double
    public let downloadLoadedPing: Double
    public let uploadLoadedPing: Double
    public let downloadIncrease: Double
    public let uploadIncrease: Double
    public let grade: BufferbloatGrade
    public let recommendation: String
    public let timestamp: Date
    
    public enum BufferbloatGrade: String {
        case aPlus = "A+"
        case a = "A"
        case b = "B"
        case c = "C"
        case d = "D"
        case f = "F"
        
        public var title: String {
            switch self {
            case .aPlus: return "Ultra Flawless (No Lag Spikes)"
            case .a: return "Great (Minimal Latency Under Load)"
            case .b: return "Good (Occasional Gaming Stutters)"
            case .c: return "Fair (Noticeable Lag Spikes During Video/Downloads)"
            case .d: return "Poor (High Lag Under Moderate Network Traffic)"
            case .f: return "Severe Bufferbloat (Severe Game Freezes)"
            }
        }
        
        public var colorHex: String {
            switch self {
            case .aPlus: return "#00E676"
            case .a: return "#00E5FF"
            case .b: return "#76FF03"
            case .c: return "#FFD600"
            case .d: return "#FF9100"
            case .f: return "#FF5252"
            }
        }
    }
    
    public init(
        unloadedPing: Double,
        downloadLoadedPing: Double,
        uploadLoadedPing: Double
    ) {
        self.unloadedPing = max(1.0, unloadedPing)
        self.downloadLoadedPing = max(unloadedPing, downloadLoadedPing)
        self.uploadLoadedPing = max(unloadedPing, uploadLoadedPing)
        self.downloadIncrease = max(0, self.downloadLoadedPing - self.unloadedPing)
        self.uploadIncrease = max(0, self.uploadLoadedPing - self.unloadedPing)
        self.timestamp = Date()
        
        let maxDelta = max(self.downloadIncrease, self.uploadIncrease)
        
        if maxDelta < 5 {
            self.grade = .aPlus
            self.recommendation = "การเชื่อมต่อของคุณสมบูรณ์แบบมาก เหมาะสำหรับการเล่นเกมระดับโปรและสตรีมมิ่งพร้อมกัน"
        } else if maxDelta < 15 {
            self.grade = .a
            self.recommendation = "ความเสถียรอยู่ในเกณฑ์ยอดเยี่ยม ค่า Ping แทบไม่ขยับแม้มีคนอื่นในบ้านใช้งานเน็ต"
        } else if maxDelta < 40 {
            self.grade = .b
            self.recommendation = "ใช้งานได้ดี แนะนำให้เปิด DoH Fast DNS บน iPhone เพื่อช่วยประหยัดเวลา Query ข้อมูล"
        } else if maxDelta < 100 {
            self.grade = .c
            self.recommendation = "เริ่มมีอาการแลคเมื่อมีคนดาวน์โหลดไฟล์ แนะนำให้ต่อ Wi-Fi คลื่น 5GHz หรือเปิดฟังก์ชัน SQM (Smart Queue) บนเราเตอร์"
        } else if maxDelta < 250 {
            self.grade = .d
            self.recommendation = "มีปัญหา Bufferbloat สูง แนะนำให้รีสตาร์ทเราเตอร์ และเปิดใช้ Fast DNS Profile เพื่อลดความหน่วง"
        } else {
            self.grade = .f
            self.recommendation = "เราเตอร์มีปัญหาคิวข้อมูลล้นอย่างรุนแรง (Severe Bufferbloat) แนะนำให้ตรวจสอบสายแลนและตั้งค่า QoS บนเราเตอร์"
        }
    }
}
