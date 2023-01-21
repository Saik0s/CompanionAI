import Foundation

// MARK: - Participant

public enum Participant: Hashable, Codable {
  case bot(Bot)
  case user(User)
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
