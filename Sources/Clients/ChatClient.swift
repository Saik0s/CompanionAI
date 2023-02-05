import AppDevUtils
import Dependencies
import Foundation
import OpenAI

// MARK: - ChatClient

public struct ChatClient {
  public var getConversationWithBot: (Bot) async throws -> Conversation
  public var saveConversation: (Conversation) async throws -> Void
  public var generateAnswerForConversation: (Conversation) async throws -> String
  public var calculateEmbeddingForMessage: (Message) async throws -> [Double]
  public var cosineSimilarity: ([Double], [Double]) -> Double
}

// MARK: DependencyKey

extension ChatClient: DependencyKey {
  public static let liveValue: Self = .init(
    getConversationWithBot: { bot in
      let appSupportURL = try DataSources.getApplicationSupportURL()
      let conversationURL = appSupportURL.appendingPathComponent("\(bot.id.uuidString).json")
      log.verbose("Conversation URL: \(conversationURL.absoluteString)")

      if let conversation = try? Conversation(fromFile: conversationURL) {
        return conversation
      }

      @Dependency(\.configClient) var configClient
      var config = try configClient.getConfig()
      var user = User(name: config.userName)
      var conversation = Conversation(bot: bot, user: user, startingPrompt: config.conversationStartingPrompt)

      conversation.messages = [
        Message(text: config.userStartingMessage, participant: .user(user), timestamp: Date().timeIntervalSince1970),
        Message(text: bot.greeting, participant: .bot(bot), timestamp: Date().timeIntervalSince1970),
      ]

      try conversation.write(toFile: conversationURL)
      return conversation
    },
    saveConversation: { conversation in
      let appSupportURL = try DataSources.getApplicationSupportURL()
      let conversationURL = appSupportURL.appendingPathComponent("\(conversation.bot.id.uuidString).json")
      try conversation.write(toFile: conversationURL)
    },
    generateAnswerForConversation: { conversation in
      @Dependency(\.configClient) var configClient
      var config = try configClient.getConfig()
      var promptMessages: [Message] = []
      var messages = conversation.messages

      if messages.count > config.firstMessagesForContextCount + config.lastMessagesForContextCount {
        promptMessages.append(contentsOf: messages.prefix(config.firstMessagesForContextCount))
        messages.removeFirst(config.firstMessagesForContextCount)
        promptMessages.append(contentsOf: messages.prefix(config.lastMessagesForContextCount))
        messages.removeFirst(config.lastMessagesForContextCount)
      } else {
        promptMessages = messages
      }

      while promptMessages.map(\.text).joined().count > 8000 {
        promptMessages.remove(at: promptMessages.count / 2)
      }

      let chat = conversation.messages
        .map { "ChatGPT: " + $0.text }
        .joined(separator: "\n\n\n\n")

      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "YYYY-MM-dd"

      let prompt =
        """
        \(conversation.startingPrompt) Current date: \(dateFormatter.string(from: Date()))

        \(chat)



        \(conversation.bot.name):
        """

      let completion = try await DataSources.generateCompletion(for: prompt, temperature: 0.5, max_tokens: 700, frequency_penalty: 0.6)
      return completion
    },
    calculateEmbeddingForMessage: { message in
      log.verbose("Calculating embedding for message: \(message.id)")
      let query = OpenAI.EmbeddingsQuery(model: .textEmbeddingAda, input: message.text)
      let result = try await DataSources.openAI.embeddings(query: query)
      return result.data.first?.embedding ?? []
    },
    cosineSimilarity: Vector.cosineSimilarity(a:b:)
  )
}

extension DependencyValues {
  var chatClient: ChatClient {
    get { self[ChatClient.self] }
    set { self[ChatClient.self] = newValue }
  }
}
