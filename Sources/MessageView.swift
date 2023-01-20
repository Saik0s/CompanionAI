import AppDevUtils
import Inject
import SwiftUI

// MARK: - MessageView

struct MessageView: View {
  @ObserveInjection var inject

  var message: Message

  var body: some View {
    VStack(alignment: message.participant.isBot ? .leading : .trailing, spacing: .grid(2)) {
      HStack(spacing: .grid(2)) {
        if message.participant.isUser {
          Text(message.dateString)
            .foregroundColor(.systemGray)
        }

        Text(message.participant.name)
          .foregroundColor(.black)

        if message.participant.isBot {
          Text(message.dateString)
            .foregroundColor(.systemGray)
        }
      }
      .font(.caption)

      Text(message.text)
        .font(.body)
        .foregroundColor(.black)
        .padding(.grid(2))
        .background(
          Rectangle()
            .fill(
              message.participant.isBot
                ? Color(.systemGray).lighten(by: 0.3)
                : Color(.systemPurple).lighten(by: 0.3)
            )
            .roundedCorners(
              radius: .grid(2),
              corners: message.participant.isBot ? [.topRight, .bottomLeft, .bottomRight] : [.topLeft, .bottomLeft, .bottomRight]
            )
        )
    }
    .multilineTextAlignment(.leading)
    .enableInjection()
  }
}
