import Foundation

public struct Bot: Hashable, Codable, Identifiable {
  public var id: UUID = .init()
  let name: String
  var who: String = ""
  var greeting: String = ""
  var avatarURL: String = ""
}

#if DEBUG
public extension Bot {
  static let fixture = Bot(
    name: "MockBot",
    who: "MockBot",
    greeting: "Hello, I'm a bot.",
    avatarURL: ""
  )
}
#endif
