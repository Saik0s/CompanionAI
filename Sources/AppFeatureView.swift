import AppDevUtils
import Inject
import SwiftUI
import ComposableArchitecture

public struct AppFeature: ReducerProtocol {
  public struct State: Equatable {
  }

  public enum Action: Equatable {
    case placeholder
  }

  public var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .placeholder:
        return .none
      }
    }
  }
}

public struct AppFeatureView: View {
  @ObserveInjection var inject

  let store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      ChatView()
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
