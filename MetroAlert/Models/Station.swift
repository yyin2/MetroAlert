import Foundation

struct Station: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String            // Chinese name
    let nameEn: String          // English name
    let line: String            // Line name (e.g., "1号线")
    let city: String            // "北京" or "上海"
    
    init(id: UUID = UUID(), name: String, nameEn: String, line: String, city: String) {
        self.id = id
        self.name = name
        self.nameEn = nameEn
        self.line = line
        self.city = city
    }
}
