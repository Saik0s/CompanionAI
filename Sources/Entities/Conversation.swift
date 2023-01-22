import Foundation

// MARK: - Conversation

public struct Conversation: Hashable, Codable {
  public var bot: Bot
  public var user: User
  public var startingPrompt: String
  public var messages: [Message]

  public init(bot: Bot, user: User, startingPrompt: String, messages: [Message] = []) {
    self.bot = bot
    self.user = user
    self.startingPrompt = startingPrompt
    self.messages = messages
  }
}

#if DEBUG
  public extension Conversation {
    static let fixture = Conversation(
      bot: .fixture,
      user: .fixture,
      startingPrompt: "You are talking to a bot. Say something to it.",
      messages: [
        Message(
          text: "Hello, I'm a bot.",
          participant: .bot(.fixture),
          timestamp: Date().timeIntervalSince1970
        ),
        Message(
          text: "Hello, I'm a user.",
          participant: .user(.fixture),
          timestamp: Date().timeIntervalSince1970
        ),
      ]
    )
  }
#endif
