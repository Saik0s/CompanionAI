import ProjectDescription

let packages: [Package] = [
  .package(url: "https://github.com/Saik0s/AppDevUtils.git", .branch("main")),
  .package(url: "https://github.com/krzysztofzablocki/Inject.git", .branch("main")),
  .package(url: "https://github.com/Saik0s/OpenAI.git", .branch("main")),
]

let dependencies = Dependencies(
  swiftPackageManager: .init(packages),
  platforms: [.macOS]
)
