import AppKit
import ComposableArchitecture
import SwiftUI

@main
struct CompanionAIApp: App {
  var body: some Scene {
    WindowGroup {
      AppFeatureView(
        store: Store(
          initialState: AppFeature.State(),
          reducer: AppFeature()
        )
      )
      .preferredColorScheme(.light)
      // .task {
      //   NSApplication.shared.windows.first?.level = .floating
      // }
    }
    .defaultSize(width: 800, height: 600)
    .windowStyle(HiddenTitleBarWindowStyle())
  }
}
