import Foundation

public struct Config: Hashable, Codable {
  public var conversationStartingPrompt: String = "The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.\n"
  public var userStartingMessage: String = "Hello, who are you?"
  public var userName: String = "Client"

  public var isFloatingWindow: Bool = true
  public var isAvatarEnabled: Bool = true
  public var isContextIncludedInPrompt: Bool = true
  public var isEmbeddingCalculationEnabled: Bool = true
  public var countLatestMessagesInPrompt: Int = 7

  public var temperature: Double = 0.7

  public init() {}
}
