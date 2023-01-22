import Foundation

public struct Config: Hashable, Codable {
  public var conversationStartingPrompt: String =
    "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.\n"
  public var userStartingMessage: String = "Hello, how can you help me?"
  public var userName: String = "User"

  // public var isFloatingWindow: Bool = true
  // public var isAvatarEnabled: Bool = true
  // public var isContextIncludedInPrompt: Bool = true
  // public var isEmbeddingCalculationEnabled: Bool = true
  public var firstMessagesForContextCount: Int = 7
  public var lastMessagesForContextCount: Int = 7

  // public var creationTemperature: Double = 0.7
  // public var chatTemperature: Double = 0.7

  public var bots: [Bot] = []

  public init() {}
}
