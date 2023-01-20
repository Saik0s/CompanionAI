import AppDevUtils
import ComposableArchitecture
import Inject
import SwiftUI

// MARK: - ChatViewModel

@MainActor
class ChatViewModel: ObservableObject {
  @Published var conversation: Conversation = .init()
  @Published var currentInput: String = ""
  @Published var isLoading: Bool = false

  var chatClient: ChatClient { ChatClient.liveValue }
}

// MARK: - Chat

public struct Chat: ReducerProtocol {
  public struct State: Equatable, Codable {
    @BindableState var conversation: Conversation = .init()
    @BindableState var isLoading: Bool = false
    @BindableState var chatInputField = ChatInputField.State()

    enum CodingKeys: String, CodingKey {
      case conversation
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case chatInputField(ChatInputField.Action)
  }

  @Dependency(\.chatClient) var chatClient: ChatClient

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Scope(state: \.chatInputField, action: /Action.chatInputField) { ChatInputField() }

    Reduce { state, action in
      switch action {
      case .binding:
        return .none

      case .chatInputField(.sendButtonTapped):
        return sendButtonTap(state: &state)

      case .chatInputField:
        return .none
      }
    }
  }

  private func sendButtonTap(state: inout State) -> EffectTask<Action> {
    guard !state.chatInputField.text.isEmpty, !state.isLoading else { return .none }

    let oldInput = state.chatInputField.text
    state.chatInputField.text = ""

    return .run { [state] send in
      await send(.binding(.set(\.$isLoading, true)))

      let newMessage = Message(text: oldInput, participant: .user(state.conversation.user), timestamp: Date().timeIntervalSince1970)
      var conversation = state.conversation
      conversation.messages.append(newMessage)
      await send(.binding(.set(\.$conversation, conversation)))

      let answer: String
      do {
        answer = try await chatClient.generateAnswerForConversation(conversation)
      } catch {
        answer = "I'm sorry, I'm having trouble understanding you. Can you rephrase?"
        log.error(error)
      }

      let answerMessage = Message(text: answer, participant: .bot(conversation.bot), timestamp: Date().timeIntervalSince1970)
      conversation.messages.append(answerMessage)
      await send(.binding(.set(\.$conversation, conversation)))

      await send(.binding(.set(\.$isLoading, false)))
    }
  }
}

// MARK: - ChatView

public struct ChatView: View {
  @ObserveInjection var inject
  @Namespace var namespace

  let store: StoreOf<Chat>

  public init(store: StoreOf<Chat>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      let lastId = (viewStore.conversation.messages.last?.id.uuidString ?? "Empty") + (viewStore.isLoading ? "Loading" : "")

      ZStack {
        ScrollViewReader { scrollReader in
          ReversedScrollView {
            VStack(spacing: .grid(4)) {
              ForEach(viewStore.conversation.messages, content: { message in
                MessageView(message: message)
              })

              if viewStore.isLoading {
                WithInlineState(initialValue: ".") { text in
                  MessageView(message: .init(text: text.wrappedValue,
                                             participant: .bot(viewStore.conversation.bot),
                                             timestamp: Date().timeIntervalSince1970))
                    .animateForever(using: .easeInOut(duration: 1), autoreverses: true) {
                      text.wrappedValue = text.wrappedValue == "..." ? "." : "..."
                    }
                }
              }
            }
            .padding(.bottom, .grid(4))
            .padding(.bottom, 50) // input field height
            .padding(.bottom, .grid(6)) // input field bottom padding
            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewStore.isLoading)
            .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewStore.conversation.messages)

            AnyView(Text(lastId).frame(width: 0, height: 0)).id(lastId)
          }
          .padding(.horizontal, .grid(6))
          .onChange(of: lastId) { lastId in
            withAnimation {
              scrollReader.scrollTo(lastId)
            }
          }
          .onAppear {
            withAnimation {
              scrollReader.scrollTo(lastId)
            }
          }
        }

        ZStack {
          if viewStore.isLoading {
            ActivityIndicator()
              .foregroundColor(.black)
              .frame(width: 20, height: 20)
              .frame(width: 50, height: 50)
              .background {
                RoundedRectangle(cornerRadius: .grid(2))
                  .fill(Color.white)
                  .shadow(color: .black.opacity(0.3), radius: 15, y: 5)
              }
              .matchedGeometryEffect(id: "input", in: namespace)
          } else {
            ChatInputFieldView(store: store.scope(state: \.chatInputField, action: Chat.Action.chatInputField))
              .matchedGeometryEffect(id: "input", in: namespace)
          }
        }
        .padding([.horizontal, .bottom], .grid(6))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .animation(.interpolatingSpring(stiffness: 170, damping: 15), value: viewStore.isLoading)
      }
      .background {
        RoundedRectangle(cornerRadius: .grid(2))
          .fill(Color.white)
      }
    }
    .enableInjection()
  }
}

#if DEBUG
  struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        ChatView(
          store: Store(
            initialState: Chat.State(),
            reducer: Chat()
          )
        )
      }
    }
  }
#endif
