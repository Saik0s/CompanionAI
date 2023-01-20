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
      .external(name: "Inject"),
      .external(name: "OpenAI"),
    ],
    environment: ["OPENAI_API_KEY": OPENAI_API_KEY]
  )
}

let project = Project(
  name: "CompanionAI",
  options: .options(
    disableBundleAccessors: true,
    disableSynthesizedResourceAccessors: true,
    textSettings: .textSettings(
      indentWidth: 2,
      tabWidth: 2
    )
  ),
  settings: .settings(
    configurations: [
      .debug(name: "Debug", xcconfig: "//configs/Base.xcconfig"),
      .release(name: "Release", xcconfig: "//configs/Base.xcconfig"),
    ]
  ),
  targets: [target(name: "CompanionAI")]
)
