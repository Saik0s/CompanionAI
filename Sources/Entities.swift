//
// Created by Igor Tarasenko on 20/01/2023.
//

import Foundation

// MARK: - Bot

public struct Bot: Hashable {
  let name: String
}

// MARK: - User

public struct User: Hashable {
  let name: String
}

// MARK: - Participant

public enum Participant: Hashable {
  case bot(Bot)
  case user(User)

  var name: String {
    switch self {
    case let .bot(bot):
      return bot.name
    case let .user(user):
      return user.name
    }
  }
}

// MARK: - Message

public struct Message: Hashable, Identifiable {
  public let id: UUID = .init()
  let text: String
  let participant: Participant
  let timestamp: Double
}

// MARK: - Conversation

public struct Conversation: Hashable {
  var participants: [Participant] = []
  var messages: [Message] = []
}
