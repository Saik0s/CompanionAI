import Foundation

// MARK: - Bot

public struct Bot: Hashable, Codable {
  let name: String
}

// MARK: - User

public struct User: Hashable, Codable {
  let name: String
}

// MARK: - Participant

public enum Participant: Hashable, Codable {
  case bot(Bot)
  case user(User)
}

// MARK: - Message

public struct Message: Hashable, Codable, Identifiable {
  public var id: UUID = .init()
  let text: String
  let participant: Participant
  let timestamp: Double

  var dateString: String {
    let date = Date(timeIntervalSince1970: timestamp)
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm:ss"
    return dateFormatter.string(from: date)
  }
}

// MARK: - Conversation

public struct Conversation: Hashable, Codable {
  var bot: Bot = .init(name: "PM")
  var user: User = .init(name: "Client")
  var messages: [Message] = []

  public init() {}

  public init?(rawValue: String) {
    guard let data = rawValue.data(using: .utf8) else { return nil }
    guard let conversation = try? JSONDecoder().decode(Conversation.self, from: data) else { return nil }
    self = conversation
  }

  public var rawValue: String {
    guard let data = try? JSONEncoder().encode(self) else { return "" }
    return String(data: data, encoding: .utf8) ?? ""
  }
}

extension Participant {
  var name: String {
    switch self {
    case let .bot(bot):
      return bot.name
    case let .user(user):
      return user.name
    }
  }

  var isBot: Bool {
    switch self {
    case .bot:
      return true
    case .user:
      return false
    }
  }

  var isUser: Bool {
    switch self {
    case .bot:
      return false
    case .user:
      return true
    }
  }
}
