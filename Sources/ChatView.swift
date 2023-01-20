//
// Created by Igor Tarasenko on 20/01/2023.
//

import SwiftUI
import Inject
import AppDevUtils


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

// MARK: - ContentViewModel

@MainActor
class ChatViewModel: ObservableObject {
  @Published var bot: Bot = .init(name: "PM")
  @Published var user: User = .init(name: "Client")
  @Published var conversation: Conversation = .init()
  @Published var currentInput: String = ""

  init() {
    conversation.participants = [.bot(bot), .user(user)]
  }

  func sendButtonTap() {
    guard !currentInput.isEmpty else { return }
    Task {
      await send(currentInput)
      currentInput = ""
    }
  }

  func send(_ message: String) async {
    sendMessage(message)
    await askDavinci()
  }

  func sendMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .user(user), timestamp: Date().timeIntervalSince1970)
    conversation.messages.append(newMessage)
  }

  func receiveMessage(_ message: String) {
    let newMessage = Message(text: message, participant: .bot(bot), timestamp: Date().timeIntervalSince1970)
    conversation.messages.append(newMessage)
  }

  private func askDavinci() async {
    let apiURL = URL(string: "https://api.openai.com/v1/completions")!
    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"]!

    let chat = conversation.messages
      .map { $0.participant.name + ": " + $0.text }
      .joined(separator: "\n\n")

    let prompt =
      """
      The following is a conversation with a product manager(PM) for a mobile application. The product manager is helpful, creative, clever, and very friendly.

      Client: Hello, who are you?
      PM: As a product manager, I am ready to take on the development of a new mobile app. I will be provided with a brief description of the app's features and target audience, and it is my responsibility to create a detailed plan for the app's development. This will include a marketing strategy, a development schedule, and a list of potential monetization options. I will also identify potential features and improvements that can be added to the app in the future. Additionally, I will be able to recognize potential risks and come up with a plan to mitigate them. My approach will be to provide clear and concise responses without any additional explanations. What will be my first task?
      \(chat)

      \(bot.name):
      """

    let body: [String: Any] = [
      "model": "text-davinci-003",
      "prompt": prompt + "\n",
      "temperature": 0.7,
      "max_tokens": 700,
      "top_p": 1,
      "frequency_penalty": 0,
      "presence_penalty": 0,
      "stop": "",
    ]

    var request = URLRequest(url: apiURL)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    request.httpMethod = "POST"
    request.httpBody = try! JSONSerialization.data(withJSONObject: body)
    log(body)

    let (data, _) = try! await URLSession.shared.data(for: request)
    log(data.utf8String)

    do {
      let textCompletion = try JSONDecoder().decode(TextCompletion.self, from: data)
      if let generatedText = textCompletion.choices.first?.text {
        receiveMessage(generatedText)
      } else {
        log("No choices")
      }
    } catch {
      log(error)

      if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
         let error = json["error"] as? [String: Any],
         let errorMessage = error["message"] as? String {
        log("Error message: \(errorMessage)")
      } else {
        log("Error parsing response")
      }
    }
  }
}

struct ChatView: View {
  @ObservedObject var viewModel = ChatViewModel()

  var body: some View {
    VStack(spacing: .grid(4)) {
      ScrollView {
        VStack(spacing: .grid(2)) {
          ForEach(viewModel.conversation.messages, content: { message in
            MessageView(message: message)
          })
        }
      }

      HStack {
        TextField("Message", text: $viewModel.currentInput, onCommit: {
          viewModel.sendButtonTap()
        })
        Button("Send") {
          viewModel.sendButtonTap()
        }
      }
    }
  }
}
