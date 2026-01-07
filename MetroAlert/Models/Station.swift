import Foundation

struct Station: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let line: String
    
    init(id: UUID = UUID(), name: String, line: String) {
        self.id = id
        self.name = name
        self.line = line
    }
}
