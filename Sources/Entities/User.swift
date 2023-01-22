import Foundation

// MARK: - User

public struct User: Hashable, Codable {
  public var name: String

  public init(name: String) {
    self.name = name
  }
}

#if DEBUG
  public extension User {
    static let fixture = User(name: "MockUser")
  }
#endif
