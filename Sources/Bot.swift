import Foundation

public struct Bot: Hashable, Codable, Identifiable {
  public var id: UUID = .init()
  let name: String
  var who: String = ""
  var greeting: String = ""
}
