import AppDevUtils
import ComposableArchitecture
import Foundation

// MARK: - BotClient

public struct BotClient {
  public var createBot: (_ profession: String) async throws -> Bot
  public var getBots: () async throws -> [Bot]
  public var deleteBot: (Bot.ID) async throws -> Void
}

// MARK: - BotClientError

public enum BotClientError: Error {
  case professionIsEmpty
}

// MARK: - BotClient + DependencyKey

extension BotClient: DependencyKey {
  public static var liveValue: Self = .init(
    createBot: { profession in
      guard profession.isNotEmpty else { throw BotClientError.professionIsEmpty }

      @Dependency(\.configClient) var configClient
      var config = try configClient.getConfig()
      let promptFileURL = Files.Resources.personaPromptsITxt.url
      var prompt = try String(contentsOf: promptFileURL)
      prompt += "Who: \(profession)\n"
      prompt += "Prompt:\n"
      let completion = try await DataSources.generateCompletion(for: prompt, temperature: 1, max_tokens: 500)
      var name: String = profession.capitalized
        .split(separator: " ")
        .compactMap { $0.first.map(String.init) }
        .joined(separator: "")

      if name.isEmpty { name = "AI" }

      let bot = Bot(name: name, who: profession, greeting: completion, avatarURL: "")
      config.bots.append(bot)
      try configClient.saveConfig(config)
      return bot
    },
    getBots: {
      @Dependency(\.configClient) var configClient
      let config = try configClient.getConfig()
      return config.bots
    },
    deleteBot: { id in
      @Dependency(\.configClient) var configClient
      var config = try configClient.getConfig()
      config.bots.removeAll(where: { $0.id == id })
      try configClient.saveConfig(config)
    }
  )
}

public extension DependencyValues {
  var botClient: BotClient {
    get { self[BotClient.self] }
    set { self[BotClient.self] = newValue }
  }
}
