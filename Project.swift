import ProjectDescription

func target(name: String) -> Target {
  Target(
    name: name,
    platform: .macOS,
    product: .app,
    bundleId: "me.igortarasenko.\(name)",
    infoPlist: .default,
    sources: .paths([.relativeToManifest("Sources/**")]),
    resources: [
      "Resources/**",
    ],
    dependencies: [
      .external(name: "AppDevUtils"),
    ],
    settings: .settings(base: ["CODE_SIGN_IDENTITY": "", "CODE_SIGNING_REQUIRED": "NO"])
  )
}

let project = Project(
  name: "App",
  targets: [target(name: "App")]
)
