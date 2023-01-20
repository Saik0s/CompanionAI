import AppDevUtils
import Inject
import OpenAI
import SwiftUI

// MARK: - TextCompletion

struct TextCompletion: Codable {
  let id: String
  let object: String
  let created: Int
  let model: String
  let choices: [Choice]
  let usage: Usage

  struct Choice: Codable {
    let text: String
    let index: Int
    let logprobs: String?
    let finish_reason: String
  }

  struct Usage: Codable {
    let prompt_tokens: Int
    let completion_tokens: Int
    let total_tokens: Int
  }
}

// MARK: - ChatViewModel

@MainActor
class ChatViewModel: ObservableObject {
  @Published var conversation: Conversation = .init()
  @Published var currentInput: String = ""
  @Published var isLoading: Bool = false

  var openAI: OpenAI { Dependencies.openAI }

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

  func send(_ message: String) async {
    sendMessage(message)
    await askDavinci()
  }

  func sendMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .user(conversation.user), timestamp: Date().timeIntervalSince1970)
    conversation.messages.append(newMessage)
  }

  func receiveMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .bot(conversation.bot), timestamp: Date().timeIntervalSince1970)
    conversation.messages.append(newMessage)
  }

  private func askDavinci() async {
    let chat = conversation.messages
      .map { $0.participant.name + ": " + $0.text }
      .joined(separator: "\n\n")

    let prompt =
      """
      The following is a conversation with a product manager(PM) for a mobile application. The product manager is helpful, creative, clever, and very friendly.

      Client: Hello, who are you?
      PM: As a product manager, I am ready to take on the development of a new mobile app. I will be provided with a brief description of the app's features and target audience, and it is my responsibility to create a detailed plan for the app's development. This will include a marketing strategy, a development schedule, and a list of potential monetization options. I will also identify potential features and improvements that can be added to the app in the future. Additionally, I will be able to recognize potential risks and come up with a plan to mitigate them. My approach will be to provide clear and concise responses without any additional explanations. What will be my first task?
      \(chat)

      \(conversation.bot.name):
      """
    let query = OpenAI.CompletionsQuery(
      model: .textDavinci_003,
      prompt: prompt,
      temperature: 0.7,
      max_tokens: 700,
      top_p: 1,
      frequency_penalty: 0,
      presence_penalty: 0
    )
    let result = try! await openAI.completions(query: query)
    if let text = result.choices.first?.text {
      receiveMessage(text)
    } else {
      log("No choices")
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

private extension OpenAI {
  func completions(query: CompletionsQuery) async throws -> CompletionsResult {
    try await withCheckedThrowingContinuation { continuation in
      completions(query: query) { result in
        switch result {
        case let .success(result):
          continuation.resume(returning: result)
        case let .failure(error):
          continuation.resume(throwing: error)
        }
      }
    }
  }
}
