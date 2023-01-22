import AppDevUtils
import ComposableArchitecture
import Inject
import SwiftUI

// MARK: - ChatInputField

public struct ChatInputField: ReducerProtocol {
  public struct State: Equatable, Codable {
    @BindableState var text = ""
  }

  public enum Action: BindableAction, Equatable {
    case binding(BindingAction<State>)
    case sendButtonTapped
  }

  public var body: some ReducerProtocol<State, Action> {
    BindingReducer()

    Reduce { _, action in
      switch action {
      case .binding:
        return .none

      case .sendButtonTapped:
        return .none
      }
    }
  }
}

// MARK: - ChatInputFieldView

public struct ChatInputFieldView: View {
  @ObserveInjection var inject

  let store: StoreOf<ChatInputField>

  public init(store: StoreOf<ChatInputField>) {
    self.store = store
  }

  public var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      HStack(spacing: .grid(2)) {
        TextField(
          "free_form",
          text: viewStore.binding(\.$text),
          prompt: Text("Type your message..."),
          axis: .vertical
        )
        .lineLimit(1...)
        .textFieldStyle(.plain)
        .onSubmit { viewStore.send(.sendButtonTapped) }
        .foregroundColor(.black)
        .font(.DS.bodyL)
        .padding(.vertical, .grid(2))

        Button { viewStore.send(.sendButtonTapped) } label: {
          Image(systemName: "paperplane.fill")
            .resizable()
            .frame(width: 20, height: 20)
            .frame(width: 34, height: 34)
        }
        .actionButtonStyle()
      }
      .padding(.horizontal, .grid(2))
      .frame(minHeight: 50)
      .background {
        RoundedRectangle(cornerRadius: .grid(2))
          .fill(Color.white)
          .shadow(color: .black.opacity(0.3), radius: 15, y: 10)
      }
    }
    .enableInjection()
  }
}

#if DEBUG
  struct ChatInputFieldView_Previews: PreviewProvider {
    static var previews: some View {
      NavigationView {
        ChatInputFieldView(
          store: Store(
            initialState: ChatInputField.State(),
            reducer: ChatInputField()
          )
        )
      }
    }
  }
#endif
