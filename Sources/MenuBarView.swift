import AppDevUtils
import ComposableArchitecture
import Inject
import SwiftUI

// MARK: - MenuBar

public struct MenuBar: ReducerProtocol {
  public struct State: Equatable, Codable {
    @BindableState var text = ""
    var bots: [Bot] = [Bot(name: "First bot"), Bot(name: "Second bot")]
    @BindableState var selectedBot: Bot?

    enum CodingKeys: String, CodingKey {
      case bots
      case selectedBot
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case createButtonTapped
    case botRowTapped(Bot)
  }

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .binding(\.$text):
        return .none

      case .binding:
        return .none

      case .createButtonTapped:
        return .none

      case let .botRowTapped(bot):
        state.selectedBot = bot
        return .none
      }
    }
  }
}

// MARK: - MenuBarView

public struct MenuBarView: View {
  @ObserveInjection var inject

  let store: StoreOf<MenuBar>

  public init(store: StoreOf<MenuBar>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack(spacing: .grid(1)) {
        ScrollView {
          ForEach(viewStore.bots) { bot in
            BotRowView(bot: bot)
              .applyIf(bot == viewStore.selectedBot) {
                $0
                  .foregroundColor(Color.white)
                  .background(Color.systemBlue)
                  .continuousCornerRadius(.grid(1))
                  .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
              }
              .foregroundColor(.black)
              .onTapGesture {
                viewStore.send(.botRowTapped(bot))
              }
          }
        }
        .animation(.spring(), value: viewStore.selectedBot)
        .listStyle(.plain)
        .frame(maxHeight: .infinity)
        .padding(.grid(2))
        .background {
          RoundedRectangle(cornerRadius: .grid(2))
            .fill(Color.white)
        }

        VStack(spacing: .grid(2)) {
          TextField(
            "free_form",
            text: viewStore.binding(\.$text),
            prompt: Text("Profession of new bot"),
            axis: .vertical
          )
          .lineLimit(1...)
          .textFieldStyle(.plain)
          .onSubmit { viewStore.send(.createButtonTapped) }
          .foregroundColor(.black)
          .font(.DS.bodyL)
          .padding(.horizontal, .grid(1))
          .background {
            RoundedRectangle(cornerRadius: .grid(1))
              .fill(Color.white)
              .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
          }

          Button { viewStore.send(.createButtonTapped) } label: {
            Text("Create")
              .foregroundColor(.white)
              .padding(.vertical, .grid(1))
              .padding(.horizontal, .grid(2))
              .background {
                RoundedRectangle(cornerRadius: .grid(2))
                  .fill(Color.systemBlue)
              }
          }
          .buttonStyle(.borderless)
          .shadow(color: .black.opacity(0.3), radius: 5, y: 2)
        }
        .padding(.grid(2))
        .background {
          RoundedRectangle(cornerRadius: .grid(2))
            .fill(Color.white)
        }
      }
      .frame(width: 200)
    }
    .enableInjection()
  }
}

// MARK: - BotRowView

public struct BotRowView: View {
  var bot: Bot

  public var body: some View {
    ZStack {
      Text(bot.name)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.grid(1))
    }
  }
}

#if DEBUG
  struct MenuBarView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        MenuBarView(
          store: Store(
            initialState: MenuBar.State(),
            reducer: MenuBar()
          )
        )
      }
    }
  }
#endif
