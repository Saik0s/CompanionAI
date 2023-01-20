import AppDevUtils
import Inject
import SwiftUI

struct MessageView: View {
  @ObserveInjection var inject

  var message: Message

  var body: some View {
    VStack(spacing: .grid(2)) {
      HStack(spacing: .grid(2)) {
        if message.participant.isUser {
          Text(message.dateString)
            .font(.caption)
            .foregroundColor(.gray)
        }

        Text(message.participant.name)
          .font(.caption)
          .foregroundColor(.black)

        if message.participant.isBot {
          Text(message.dateString)
            .font(.caption)
            .foregroundColor(.gray)
        }
      }
      .frame(maxWidth: .infinity, alignment: message.participant.isBot ? .leading : .trailing)

      Text(message.text)
        .font(.body)
        .foregroundColor(.black)
        .padding(.grid(2))
        .background(
          RoundedRectangle(cornerRadius: .grid(2))
            .fill(message.participant.isBot
              ? Color(.systemGray).lighten(by: 0.1)
              : Color(.systemPurple).lighten(by: 0.2))
        )
        .frame(maxWidth: .infinity, alignment: message.participant.isBot ? .leading : .trailing)
    }
    .multilineTextAlignment(.leading)
    .enableInjection()
  }
}
