import AppDevUtils
import Inject
import SwiftUI

// MARK: - ChatViewModel

@MainActor
class ChatViewModel: ObservableObject {
  @Published var conversation: Conversation = .init()
  @Published var currentInput: String = ""
  @Published var isLoading: Bool = false

  var chatClient: ChatClient { ChatClient.liveValue }

  func sendButtonTap() {
    guard !currentInput.isEmpty, !isLoading else { return }
    let oldInput = currentInput
    withAnimation {
      currentInput = ""
      isLoading = true
      Task {
        await send(oldInput)
        isLoading = false
      }
    }
  }

  private func send(_ message: String) async {
    sendMessage(message)
    await askDavinci()
  }

  private func sendMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .user(conversation.user), timestamp: Date().timeIntervalSince1970)
    conversation.messages.append(newMessage)
  }

  private func receiveMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .bot(conversation.bot), timestamp: Date().timeIntervalSince1970)
    conversation.messages.append(newMessage)
  }

  private func askDavinci() async {
    do {
      let answer = try await chatClient.generateAnswerForConversation(conversation)
      receiveMessage(answer)
    } catch {
      receiveMessage("I'm sorry, I'm having trouble understanding you. Can you rephrase?")
      log.error(error)
    }
  }
}

// MARK: - ChatView

struct ChatView: View {
  @ObserveInjection var inject

  @ObservedObject var viewModel = ChatViewModel()
  @Namespace var namespace

  var body: some View {
    VStack(spacing: .grid(4)) {
      ScrollView {
        VStack(spacing: .grid(4)) {
          ForEach(viewModel.conversation.messages.reversed(), content: { message in
            MessageView(message: message)
              .frame(maxWidth: .infinity, alignment: message.participant.isBot ? .leading : .trailing)
          })
          if viewModel.isLoading {
            MessageView(message: .init(text: "...", participant: .bot(viewModel.conversation.bot), timestamp: Date().timeIntervalSince1970))
          }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
      }

      if viewModel.isLoading {
        ActivityIndicator()
          .foregroundColor(.black)
          .frame(width: 20, height: 20)
          .padding(.grid(2))
          .background {
            RoundedRectangle(cornerRadius: .grid(2))
              .fill(Color.white)
              .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
          }
          .matchedGeometryEffect(id: "input", in: namespace)
      } else {
        HStack(spacing: .grid(2)) {
          TextField("Message", text: $viewModel.currentInput.removeDuplicates(), onCommit: {
            viewModel.sendButtonTap()
          })
          .textFieldStyle(.plain)
          .foregroundColor(.black)
          Button { viewModel.sendButtonTap() } label: {
            Image(systemName: "paperplane.fill")
              .font(.title)
              .foregroundColor(.white)
              .padding(.grid(1))
              .background {
                RoundedRectangle(cornerRadius: .grid(2))
                  .fill(Color.systemBlue)
                  .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
              }
          }
          .buttonStyle(.plain)
        }
        .padding(.vertical, .grid(2))
        .padding(.horizontal, .grid(2))
        .background {
          RoundedRectangle(cornerRadius: .grid(2))
            .fill(Color.white)
            .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
        }
        .matchedGeometryEffect(id: "input", in: namespace)
      }
    }
    .padding(.grid(6))
    .background {
      RoundedRectangle(cornerRadius: .grid(2))
        .fill(Color.white)
    }
    .padding(.grid(2))
    .enableInjection()
  }
}
