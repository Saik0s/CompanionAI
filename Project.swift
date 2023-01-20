import Foundation
import ProjectDescription
import ProjectDescriptionHelpers

let projectSettings: SettingsDictionary = [
  "GCC_TREAT_WARNINGS_AS_ERRORS": "YES",
  "SWIFT_TREAT_WARNINGS_AS_ERRORS": "YES",
  "OTHER_SWIFT_FLAGS[config=Debug][sdk=*][arch=*]": "-D DEBUG $(inherited) -Xfrontend -warn-long-function-bodies=500 -Xfrontend -warn-long-expression-type-checking=500 -Xfrontend -debug-time-function-bodies -Xfrontend -enable-actor-data-race-checks",
  "OTHER_LDFLAGS[config=Debug][sdk=*][arch=*]": "$(inherited) -Xlinker -interposable -all_load",
  "CODE_SIGN_IDENTITY": "",
  "CODE_SIGNING_REQUIRED": "NO",
]

func target(name: String) -> Target {
  Target(
    name: name,
    platform: .macOS,
    product: .app,
    bundleId: "me.igortarasenko.\(name)",
    deploymentTarget: .macOS(targetVersion: "13.0"),
    infoPlist: .extendingDefault(with: [
      "UIUserInterfaceStyle": "Light",
    ]),
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
  settings: .settings(configurations: [
    .debug(name: "Debug", settings: projectSettings, xcconfig: nil),
    .release(name: "Release", settings: projectSettings, xcconfig: nil),
  ]),
  targets: [target(name: "CompanionAI")]
)
