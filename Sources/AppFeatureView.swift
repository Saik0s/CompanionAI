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
    var chat = Chat.State()
  }

  public enum Action: Equatable {
    case chat(Chat.Action)
    case task
  }

  public var body: some ReducerProtocol<State, Action> {
    CombineReducers {
      Scope(state: \.chat, action: /Action.chat) { Chat() }

      Reduce { _, action in
        switch action {
        case .chat:
          return .none

        case .task:
          return .none
        }
      }
    }
    .onChange(of: { $0 }) { _, state, _ in
      UserDefaults.standard.appState = state
      return .none
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
      ChatView(store: store.scope(state: { $0.chat }, action: { .chat($0) }))
        .task {
          viewStore.send(.task)
        }
    }
    .padding(.grid(1))
    .enableInjection()
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
