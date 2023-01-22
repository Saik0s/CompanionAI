import AppDevUtils
import Dependencies
import Foundation
import OpenAI

// MARK: - DataSourcesError

public enum DataSourcesError: Error {
  case noChoices
}

// MARK: - DataSources

public enum DataSources {
  static var openAI: OpenAI = {
    @Dependency(\.configClient) var configClient
    var config = try! configClient.getConfig()
    return OpenAI(apiToken: config.openAIKey)
  }()

  static func generateCompletion(for prompt: String, temperature: Double = 0.7, max_tokens: Int = 700) async throws -> String {
    let query = OpenAI.CompletionsQuery(
      model: .textDavinci_003,
      prompt: prompt,
      temperature: temperature,
      max_tokens: max_tokens,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0
    )

    log.verbose("Generating completion")
    let result = try await DataSources.openAI.completions(query: query)

    if let text = result.choices.first?.text {
      return text.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
      throw DataSourcesError.noChoices
    }
  }

  public static func getApplicationSupportURL() throws -> URL {
    let url = try FileManager.default
      .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appending(component: "CompanionAI")
    try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
    return url
  }
}

extension OpenAI {
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
