import Dependencies
import Foundation
import OpenAI
import AppDevUtils

// MARK: - ChatClient

public struct ChatClient {
  public var generateAnswerForConversation: (Conversation) async throws -> String
  public var calculateEmbeddingForMessage: (Message) async throws -> [Double]
  public var cosineSimilarity: ([Double], [Double]) -> Double
}

// MARK: - ChatClientError

public enum ChatClientError: Error {
  case noChoices
}

// MARK: - ChatClient + DependencyKey

extension ChatClient: DependencyKey {
  public static let liveValue: Self = {
    let openAI = OpenAI(apiToken: ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!)

    return Self(
      generateAnswerForConversation: { conversation in
        let chat = conversation.messages
          .map { $0.participant.name + ": " + $0.text }
          .joined(separator: "\n\n")

        let prompt =
          """
          The following is a conversation with a product manager(PM) for a mobile application. The product manager is helpful, creative, clever, and very friendly.

          Client: Hello, who are you?
          PM: As a product manager, I am ready to take on the development of a new mobile app. I will be provided with a brief description of the app's features and target audience, and it is my responsibility to create a detailed plan for the app's development. This will include a marketing strategy, a development schedule, and a list of potential monetization options. I will also identify potential features and improvements that can be added to the app in the future. Additionally, I will be able to recognize potential risks and come up with a plan to mitigate them. My approach will be to provide clear and concise responses without any additional explanations. What will be my first task?
          \(chat)

          \(conversation.bot.name):
          """
        let query = OpenAI.CompletionsQuery(
          model: .textDavinci_003,
          prompt: prompt,
          temperature: 0.7,
          max_tokens: 700,
          top_p: 1,
          frequency_penalty: 0,
          presence_penalty: 0
        )

        let result = try await openAI.completions(query: query)

        if let text = result.choices.first?.text {
          return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
          throw ChatClientError.noChoices
        }
      },
      calculateEmbeddingForMessage: { message in
        let query = OpenAI.EmbeddingsQuery(model: .textEmbeddingAda, input: message.text)
        let result = try await openAI.embeddings(query: query)
        return result.data.first?.embedding ?? []
      },
      cosineSimilarity: Vector.cosineSimilarity(a:b:)
    )
  }()
}

extension DependencyValues {
  var chatClient: ChatClient {
    get { self[ChatClient.self] }
    set { self[ChatClient.self] = newValue }
  }
}

private extension OpenAI {
  func completions(query: CompletionsQuery) async throws -> CompletionsResult {
    try await withCheckedThrowingContinuation { continuation in
      completions(query: query) { result in
        switch result {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func embeddings(query: EmbeddingsQuery) async throws -> EmbeddingsResult {
    try await withCheckedThrowingContinuation { continuation in
      embeddings(query: query) { result in
        switch result {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }

  func images(query: ImagesQuery) async throws -> ImagesResult {
    try await withCheckedThrowingContinuation { continuation in
      images(query: query) { result in
        switch result {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
