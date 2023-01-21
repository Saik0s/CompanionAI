import Foundation
import AppDevUtils

public struct Message: Hashable, Codable, Identifiable, Then {
  public var id: UUID = .init()
  let text: String
  let participant: Participant
  let timestamp: Double
  var canBeIncludedInPrompt: Bool = true
  var isEmbeddingCalculated: Bool = false
  var embedding: [Double] = []

  var dateString: String {
    let date = Date(timeIntervalSince1970: timestamp)
    return dateFormatter.string(from: date)
  }
}

let dateFormatter = DateFormatter().then { $0.dateFormat = "HH:mm:ss" }
