import Foundation

struct Alarm: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var message: String
    var memo: String
}
