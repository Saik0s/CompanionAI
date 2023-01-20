import AppKit
import ComposableArchitecture
import SwiftUI

@main
struct CompanionAIApp: App {
  var body: some Scene {
    WindowGroup {
      AppFeatureView(
        store: Store(
          initialState: UserDefaults.standard.appState ?? AppFeature.State(),
          reducer: AppFeature()
        )
      )
      .task {
        NSApplication.shared.windows.first?.level = .floating
      }
    }
    .defaultSize(width: 800, height: 600)
    .windowStyle(HiddenTitleBarWindowStyle())
  }
}
