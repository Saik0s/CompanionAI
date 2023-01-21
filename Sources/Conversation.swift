import Foundation

public struct Conversation: Hashable, Codable {
  var bot: Bot = .init(name: "PM")
  var user: User = .init(name: "Client")
  var messages: [Message] = []

  public init() {}
}
