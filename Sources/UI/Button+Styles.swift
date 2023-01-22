import SwiftUI

// MARK: - ActionButtonStyle

public struct ActionButtonStyle: ButtonStyle {
  public func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .foregroundColor(.white)
      .background {
        RoundedRectangle(cornerRadius: .grid(2))
          .fill(Color.systemBlue)
      }
      .opacity(configuration.isPressed ? 0.5 : 1)
      .shadow(color: .black.opacity(0.3), radius: configuration.isPressed ? 0 : 10, y: 5)
      .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
  }
}

public extension Button {
  func actionButtonStyle() -> some View {
    buttonStyle(ActionButtonStyle())
  }
}
