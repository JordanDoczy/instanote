import ComposableArchitecture
import CreateNoteFeature
import FileClient
import SharedModels
import Storage
import SwiftUI

public struct ListViewFeature: ReducerProtocol {

    public struct State: Equatable {
        var notes: [NoteView.Model]
        var showCreateNote: Bool
        
        public init(
            notes: [NoteView.Model] = [],
            showCreateNote: Bool = false
        ) {
            self.notes = notes
            self.showCreateNote = showCreateNote
        }
    }

    public enum Action {
        case onAppear
        case createNotePressed
    }
    
    @Dependency(\.databaseClient) var databaseClient
    @Dependency(\.fileClient) var fileClient

    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                let notes = (try? databaseClient.fetchAllNotes()) ?? []
                state.notes = notes
                    .compactMap {
                        guard let uiImage = fileClient.getImage($0.id.rawValue) else {
                            return nil
                        }
                        
                        return NoteView.Model(id: $0.id.rawValue, caption: $0.caption, date: $0.date, uiImage: uiImage)
                    }

                return .none
            case .createNotePressed:
                state.showCreateNote = true
                return .none
            }
        }
    }

}

public struct ListView: View {
    
    let store: StoreOf<ListViewFeature>
    @ObservedObject var viewStore: ViewStoreOf<ListViewFeature>

    public init(store: StoreOf<ListViewFeature>) {
        self.store = store
        self.viewStore = ViewStore(store)
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(viewStore.notes) { noteModel in
                        NoteView(model: noteModel)
                    }
                }
            }

            Button(
                action: {
                    viewStore.send(.createNotePressed)
                },
                label: {
                    Image(systemName: "pencil.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                }
            )
            .frame(maxWidth: .infinity)

        }
        .padding(10)
        .onAppear {
            viewStore.send(.onAppear, animation: .default.delay(0.5))
        }
        .overlay {
            if viewStore.showCreateNote {
                CreateNoteView(store: .init(initialState: .init(), reducer: CreateNoteFeature()))
                    .background(Color.white)
            }
        }

    }
}

public struct NoteView: View {

    public struct Model: Equatable, Identifiable {
        public var id: String
        public var caption: String
        public var date: Date
        public var uiImage: UIImage
    }

    var model: Model
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("\(formateDate(model.date))")
            Text(model.caption)
            Image(uiImage: model.uiImage)
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .foregroundColor(.black)
    }

    private func formateDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true

        return dateFormatter.string(from: date)
    }
}
