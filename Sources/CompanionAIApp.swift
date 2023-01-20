import AppKit
import SwiftUI

@main
struct CompanionAIApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView()
        .task {
          NSApplication.shared.windows.first?.level = .floating
        }
    }
      .defaultSize(width: 800, height: 600)
    .windowStyle(HiddenTitleBarWindowStyle())
  }
}
