import ProjectDescription

let packages: [Package] = [
  .package(url: "https://github.com/Saik0s/AppDevUtils.git", from: "0.0.1"),
]

let dependencies = Dependencies(
  swiftPackageManager: .init(packages),
  platforms: [.macOS]
)
