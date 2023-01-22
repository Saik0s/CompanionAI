import AppDevUtils
import ComposableArchitecture
import Inject
import SwiftUI

extension UserDefaults {
  var appState: AppFeature.State? {
    get { decode(forKey: #function) }
    set { encode(newValue, forKey: #function) }
  }
}

// MARK: - AppFeature

public struct AppFeature: ReducerProtocol {
  public struct State: Equatable, Codable {
    @BindableState var alert: AlertState<Action>?
    var chat: Chat.State?
    var menuBar = MenuBar.State()

    enum CodingKeys: String, CodingKey {
      case chat
      case menuBar
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case chat(Chat.Action)
    case menuBar(MenuBar.Action)
    case changeConversation(TaskResult<Conversation>)
    case task
  }

  @Dependency(\.chatClient) var chatClient

  public var body: some ReducerProtocol<State, Action> {
    CombineReducers {
      EmptyReducer()
        .ifLet(\.chat, action: /Action.chat) {
          Chat()
        }

      Scope(state: \.menuBar, action: /Action.menuBar) { MenuBar() }

      BindingReducer()

      Reduce<State, Action> { state, action in
        switch action {
        case let .changeConversation(.failure(error)),
             let .chat(.addEmbedding(_, .failure(error))),
             let .chat(.addMessage(_, .failure(error))),
             let .menuBar(.finishReadingBots(.failure(error))),
             let .menuBar(.botCreated(.failure(error))):
          state.alert = AlertState(title: TextState("Error"), message: TextState(error.localizedDescription))
          return .none

        case .binding:
          return .none

        case .chat:
          return .none

        case .menuBar:
          return .none

        case let .changeConversation(.success(conversation)):
          state.chat = Chat.State(conversation: conversation)
          return .none

        case .task:
          return .none
        }
      }
    }
    .onChange(of: \.chat) { chat, state, _ in
      guard let chat else { return .none }
      return .fireAndForget {
        try await chatClient.saveConversation(chat.conversation)
      }
    }
    .onChange(of: \.menuBar.selectedBot) { selectedBot, state, _ in
      guard let bot = selectedBot else {
        state.chat = nil
        return .none
      }

      return .task {
        await .changeConversation(TaskResult { try await chatClient.getConversationWithBot(bot) })
      }
    }
  }
}

// MARK: - AppFeatureView

public struct AppFeatureView: View {
  @ObserveInjection var inject

  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(spacing: .grid(1)) {
        MenuBarView(store: store.scope(state: \.menuBar, action: { .menuBar($0) }))

        IfLetStore(store.scope(state: \.chat, action: { .chat($0) })) { store in
          ChatView(store: store)
        } else: {
          EmptyChatView()
        }
      }
      .alert(store.scope(state: \.alert),
             dismiss: .binding(.set(\.$alert, nil)))
      .task {
        viewStore.send(.task)
      }
    }
    .padding(.grid(1))
    .background {
      Color.systemGray.darken(by: 0.4)
        .ignoresSafeArea()
    }
    .enableInjection()
  }
}

// MARK: - EmptyChatView

struct EmptyChatView: View {
  @ObserveInjection var inject

  var body: some View {
    ZStack {
      Color(.systemGray)

      Text("Select a bot to start a conversation")
        .font(.DS.titleL)
        .foregroundColor(.secondary)
        .padding(.grid(2))
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .continuousCornerRadius(.grid(2))
  }
}

#if DEBUG
  struct AppFeatureView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        AppFeatureView(
          store: Store(
            initialState: AppFeature.State(),
            reducer: AppFeature()
          )
        )
      }
    }
  }
#endif
