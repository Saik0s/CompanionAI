import AppDevUtils
import Combine
import ComposableArchitecture
import Dependencies
import Foundation

// MARK: - ConfigClient

public struct ConfigClient {
  public var config: AnyPublisher<Config, Error>
  public var getConfig: () throws -> Config
  public var saveConfig: (Config) throws -> Void
}

// MARK: - ConfigClientError

public enum ConfigClientError: Error {
  case configNotFound
}

// MARK: - ConfigClient + DependencyKey

extension ConfigClient: DependencyKey {
  public static var liveValue: Self = {
    let subject: CodableValueSubject<Config>?
    do {
      let configURL = try getConfigURL()
      log.verbose("Config URL: \(configURL.absoluteString)")
      let encoder = JSONEncoder().then { $0.outputFormatting = .prettyPrinted }

      do {
        let _ = try Config(fromFile: configURL)
      } catch {
        let config = Config()
        try config.write(toFile: configURL, encoder: encoder)
      }

      subject = CodableValueSubject<Config>(fileURL: configURL, encoder: encoder)
    } catch {
      log.error(error)
      subject = nil
    }

    return Self(
      config: subject?.eraseToAnyPublisher()
        ?? Fail(error: ConfigClientError.configNotFound).eraseToAnyPublisher(),
      getConfig: {
        guard let subject, let value = subject.value else { throw ConfigClientError.configNotFound }
        return value
      },
      saveConfig: { config in
        guard let subject else { throw ConfigClientError.configNotFound }
        subject.value = config
      }
    )
  }()

  private static func getConfigURL() throws -> URL {
    let appSupportURL = try DataSources.getApplicationSupportURL()
    let configURL = appSupportURL.appendingPathComponent("config.json")
    return configURL
  }
}

public extension DependencyValues {
  var configClient: ConfigClient {
    get { self[ConfigClient.self] }
    set { self[ConfigClient.self] = newValue }
  }
}
