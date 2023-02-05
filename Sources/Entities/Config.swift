import Foundation

public struct Config: Hashable, Codable {
  public var openAIKey: String = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

  public var conversationStartingPrompt: String = "You are ChatGPT, a large language model trained by OpenAI. Answer conversationally. Do not answer as the user."
  public var userStartingMessage: String = "Define your responsibilities."
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
