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
    currentInput = ""
    withAnimation {
      isLoading = true
    }
    Task {
      await send(oldInput)
      withAnimation {
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
    withAnimation {
      conversation.messages.append(newMessage)
    }
  }

  private func receiveMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .bot(conversation.bot), timestamp: Date().timeIntervalSince1970)
    withAnimation {
      conversation.messages.append(newMessage)
    }
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
      ReversedScrollView {
        VStack(spacing: .grid(4)) {
          ForEach(viewModel.conversation.messages, content: { message in
            MessageView(message: message)
              .frame(maxWidth: .infinity, alignment: message.participant.isBot ? .leading : .trailing)
              .transition(.move(edge: message.participant.isBot ? .leading : .trailing))
          })
          if viewModel.isLoading {
            WithInlineState(initialValue: ".") { text in
              MessageView(message: .init(text: text.wrappedValue, participant: .bot(viewModel.conversation.bot),
                                         timestamp: Date().timeIntervalSince1970))
                .frame(maxWidth: .infinity, alignment: .leading)
                .animateForever(using: .easeInOut(duration: 1)) {
                  text.wrappedValue = text.wrappedValue == "..." ? "." : "..."
                }
            }
              .transition(.move(edge: .leading))
          }
        }
      }
        .padding(.horizontal, .grid(6))

      ZStack {
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
            TextField(
              "free_form",
              text: $viewModel.currentInput,
              prompt: Text("Type your message..."),
              axis: .vertical
            )
              .lineLimit(1...)
              .textFieldStyle(.plain)
              // .onSubmit { viewModel.currentInput += "\n" }
              .onSubmit { viewModel.sendButtonTap() }
              .foregroundColor(.black)
              .font(.DS.bodyL)
              .padding(.vertical, .grid(2))

            Button { viewModel.sendButtonTap() } label: {
              Image(systemName: "paperplane.fill")
                .resizable()
                .frame(width: 20, height: 20)
                .foregroundColor(.white)
                .frame(width: 34, height: 34)
                .background {
                  RoundedRectangle(cornerRadius: .grid(2))
                    .fill(Color.systemBlue)
                }
            }
              .buttonStyle(.borderless)
              .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
          }
            .padding(.horizontal, .grid(2))
            .frame(minHeight: 50)
            .background {
              RoundedRectangle(cornerRadius: .grid(2))
                .fill(Color.white)
                .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
            }
            .matchedGeometryEffect(id: "input", in: namespace)
        }
      }
        .padding([.horizontal, .bottom], .grid(6))
        .frame(maxWidth: .infinity)
    }
    .background {
      RoundedRectangle(cornerRadius: .grid(2))
        .fill(Color.white)
    }
    .enableInjection()
  }
}

// MARK: - ReversedScrollView

public struct ReversedScrollView<Content: View>: View {
  var content: Content

  public init(@ViewBuilder builder: () -> Content) {
    content = builder()
  }

  public var body: some View {
    GeometryReader { proxy in
      ScrollView(showsIndicators: false) {
        VStack {
          Spacer()
          content
        }
        .frame(minWidth: proxy.size.width, minHeight: proxy.size.height)
      }
    }
  }
}
