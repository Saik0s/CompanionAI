//
// Created by Igor Tarasenko on 20/01/2023.
//

import SwiftUI
import Inject

struct MessageView: View {
  @ObserveInjection var inject

  var message: Message

  var body: some View {
    ZStack {
      HStack(alignment: .top, spacing: 0) {
        Text(message.participant.name + ": ")
          .font(.caption)
          .foregroundColor(.gray)
        Text(message.text)
          .font(.body)
      }
        .foregroundColor(.black)
        .padding(.grid(2))
        .background(
          RoundedRectangle(cornerRadius: .grid(2))
            .fill(message.participant == .bot(Bot(name: "PM"))
                    ? Color(.systemGray).lighten(by: 0.1)
                    : Color(.systemPurple).lighten(by: 0.2))
        )
        .frame(maxWidth: .infinity,
               alignment: message.participant == .bot(Bot(name: "PM")) ? .leading : .trailing)
    }
      .multilineTextAlignment(.leading)
      .enableInjection()
  }
}
