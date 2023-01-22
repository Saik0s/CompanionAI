import AppDevUtils
import ComposableArchitecture
import Inject
import SwiftUI

// MARK: - MenuBar

public struct MenuBar: ReducerProtocol {
  public struct State: Equatable, Codable {
    @BindableState var text = ""
    var bots: [Bot] = []
    @BindableState var selectedBot: Bot?
    @BindableState var isCreationInProgress = false

    enum CodingKeys: String, CodingKey {
      case bots
      case selectedBot
    }
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case createButtonTapped
    case botRowTapped(Bot)
    case finishReadingBots(TaskResult<[Bot]>)
    case botCreated(TaskResult<Bot>)
    case deleteBot(Bot)
    case task
  }

  @Dependency(\.botClient) var botClient

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce { state, action in
      switch action {
      case .createButtonTapped:
        return .run { [text = state.text] send in
          await send(.binding(.set(\.$isCreationInProgress, true)))
          await send(.botCreated(TaskResult { try await botClient.createBot(text) }))
          await send(.binding(.set(\.$isCreationInProgress, false)))
        }

      case let .botCreated(.success(bot)):
        state.text = ""
        state.bots.append(bot)
        return .none

      case let .deleteBot(bot):
        state.bots.removeAll(where: { $0.id == bot.id })
        if state.selectedBot == bot {
          state.selectedBot = nil
        }
        return .fireAndForget { [bot] in
          try await botClient.deleteBot(bot.id)
        }

      case let .botRowTapped(bot):
        state.selectedBot = bot
        return .none

      case let .finishReadingBots(.success(bots)):
        state.bots = bots
        return .none

      case .task:
        return .task {
          await .finishReadingBots(TaskResult { try await botClient.getBots() })
        }

      case .binding, .finishReadingBots, .botCreated:
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
        BotListView(bots: viewStore.bots, selectedBot: viewStore.selectedBot) {
          viewStore.send(.botRowTapped($0))
        } onDelete: { bot in
          viewStore.send(.deleteBot(bot))
        }

        CreateBotView(text: viewStore.binding(\.$text), isLoading: viewStore.isCreationInProgress) { viewStore.send(.createButtonTapped) }
      }
      .frame(width: 300)
      .task {
        viewStore.send(.task)
      }
    }
    .enableInjection()
  }
}

// MARK: - BotListView

struct BotListView: View {
  var bots: [Bot]
  var selectedBot: Bot?
  var onSelect: (Bot) -> Void
  var onDelete: (Bot) -> Void

  var body: some View {
    ScrollView {
      VStack(spacing: .grid(1)) {
        ForEach(bots) { bot in
          HStack(spacing: .grid(1)) {
            BotRowView(bot: bot)
              .applyIf(bot == selectedBot) {
                $0
                  .foregroundColor(Color.white)
                  .background(Color.systemBlue)
                  .continuousCornerRadius(.grid(1))
                  .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
              }
              .foregroundColor(.black)
              .contentShape(Rectangle())
              .onTapGesture { onSelect(bot) }

            Button(action: { onDelete(bot) }) {
              Image(systemName: "trash")
                .foregroundColor(.systemRed)
                .font(.DS.bodyL)
                .padding(.grid(1))
            }
            .buttonStyle(.borderless)
          }
        }
      }
      .padding(.grid(2))
    }
    .animation(.spring(), value: selectedBot)
    .animation(.spring(), value: bots)
    .frame(minHeight: 200)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background {
      RoundedRectangle(cornerRadius: .grid(2))
        .fill(Color.white)
    }
  }
}

// MARK: - CreateBotView

struct CreateBotView: View {
  @Binding var text: String
  var isLoading: Bool = false
  var action: () -> Void

  @Namespace var namespace

  var body: some View {
    ZStack {
      if isLoading {
        ActivityIndicator()
          .frame(width: 20, height: 20)
          .matchedGeometryEffect(id: "loading", in: namespace)
      } else {
        VStack(spacing: .grid(2)) {
          TextField(
            "free_form",
            text: $text,
            prompt: Text("Profession of new bot"),
            axis: .vertical
          )
          .lineLimit(1...)
          .textFieldStyle(.plain)
          .onSubmit(action)
          .foregroundColor(.black)
          .font(.DS.bodyL)
          .padding(.horizontal, .grid(1))
          .background {
            RoundedRectangle(cornerRadius: .grid(1))
              .fill(Color.white)
              .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
          }

          Button(action: action) {
            Text("Create")
              .padding(.vertical, .grid(1))
              .padding(.horizontal, .grid(2))
          }
          .actionButtonStyle()
        }
        .matchedGeometryEffect(id: "loading", in: namespace)
      }
    }
    .frame(minHeight: 70)
    .frame(maxWidth: .infinity)
    .padding(.grid(2))
    .background {
      RoundedRectangle(cornerRadius: .grid(2))
        .fill(Color.white)
    }
    .animation(.easeInOut(duration: 0.5), value: isLoading)
  }
}

// MARK: - BotRowView

public struct BotRowView: View {
  var bot: Bot

  public var body: some View {
    HStack(alignment: .center, spacing: .grid(1)) {
      Text(bot.who)
      Text("(\(bot.name))")
        .foregroundColor(.systemGray)
    }
    .font(.DS.titleS)
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.grid(1))
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
