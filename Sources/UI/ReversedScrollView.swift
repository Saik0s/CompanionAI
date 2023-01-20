import AppDevUtils
import SwiftUI

public struct ReversedScrollView<Content: View>: View {
  var content: Content

  public init(@ViewBuilder builder: () -> Content) {
    content = builder()
  }

  public var body: some View {
    GeometryReader { proxy in
      ScrollView(showsIndicators: false) {
        VStack(spacing: 0) {
          Spacer()
          content
        }
        .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
      }
    }
  }
}
