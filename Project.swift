import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

func target(name: String) -> Target {
  Target(
    name: name,
    platform: .macOS,
    product: .app,
    bundleId: "me.igortarasenko.\(name)",
    deploymentTarget: .macOS(targetVersion: "13.0"),
    infoPlist: .default,
    sources: .paths([.relativeToManifest("Sources/**")]),
    resources: [
      "Resources/**",
    ],
    dependencies: [
      .external(name: "AppDevUtils"),
    ],
    settings: .settings(base: ["CODE_SIGN_IDENTITY": "", "CODE_SIGNING_REQUIRED": "NO"]),
    environment: ["OPENAI_API_KEY": OPENAI_API_KEY]
  )
}

let project = Project(
  name: "App",
  targets: [target(name: "App")]
)
