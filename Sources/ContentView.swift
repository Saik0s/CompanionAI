import AppDevUtils
import Inject
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  @ObserveInjection var inject

  var body: some View {
    ChatView()
      .padding(.grid(1))
      .enableInjection()
  }
}

// MARK: - ContentView_Previews

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
