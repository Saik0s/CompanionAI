// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/Saik0s/AppDevUtils.git", branch: "main"),
        .package(url: "https://github.com/krzysztofzablocki/Inject.git", branch: "main"),
        .package(url: "https://github.com/Saik0s/OpenAI.git", branch: "main"),
    ]
)