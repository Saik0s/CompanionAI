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
    @BindableState var alert: AlertState<Action>?
    @BindableState var conversation: Conversation = .init()
    @BindableState var isLoading: Bool = false
    @BindableState var chatInputField = ChatInputField.State()
    var embeddingCalculationInProgress: Set<UUID> = []

    enum CodingKeys: String, CodingKey {
      case conversation
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case chatInputField(ChatInputField.Action)
    case addMessage(Participant, TaskResult<String>)
    case addEmbedding(Message.ID, TaskResult<[Double]>)
    case askForAnswer
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

      case let .addMessage(participant, .success(text)):
        let message = Message(text: text, participant: participant, timestamp: Date().timeIntervalSince1970)
        state.conversation.messages.append(message)

        var messagesToCalculateEmbeddingsFor: [Message] = []
        for message in state.conversation.messages where message.isEmbeddingCalculated == false {
          if state.embeddingCalculationInProgress.insert(message.id).inserted {
            messagesToCalculateEmbeddingsFor.append(message)
          }
        }

        return .run { [messagesToCalculateEmbeddingsFor] send in
          for message in messagesToCalculateEmbeddingsFor {
            await send(.addEmbedding(message.id, TaskResult { try await chatClient.calculateEmbeddingForMessage(message) }))
          }
        }

      case let .addEmbedding(id, .success(embedding)):
        state.conversation.messages = state.conversation.messages.map { message in
          message.id == id
            ? message
              .with(\.embedding, setTo: embedding)
              .with(\.isEmbeddingCalculated, setTo: true)
            : message
        }

        if let message = state.conversation.messages.first(where: { $0.id == id }) {
          state.conversation.messages.forEach {
            log.debug("\nMessage \(message.text)\nMessage: \($0.text)\nsimilarity: \(chatClient.cosineSimilarity($0.embedding, message.embedding))")
          }
        }

        return .none

      case .askForAnswer:
        return .run { [conversation = state.conversation] send in
          await send(.binding(.set(\.$isLoading, true)))
          await send(.addMessage(.bot(conversation.bot), TaskResult { try await chatClient.generateAnswerForConversation(conversation) }))
          await send(.binding(.set(\.$isLoading, false)))
        }

      case let .addEmbedding(id, .failure(error)):
        state.embeddingCalculationInProgress.remove(id)
        state.alert = AlertState(title: TextState("Error"), message: TextState(error.localizedDescription))
        return .none

      case let .addMessage(_, .failure(error)):
        state.alert = AlertState(title: TextState("Error"), message: TextState(error.localizedDescription))
        return .none
      }
    }
  }

  private func sendButtonTap(state: inout State) -> EffectTask<Action> {
    guard !state.chatInputField.text.isEmpty, !state.isLoading else { return .none }

    let oldInput = state.chatInputField.text
    state.chatInputField.text = ""

    return .run { [state] send in
      await send(.addMessage(.user(state.conversation.user), TaskResult { oldInput }))
      await send(.askForAnswer)
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
    .alert(store.scope(state: \.alert),
           dismiss: .binding(.set(\.$alert, nil)))
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
