import ComposableArchitecture
import SharedModels
import Storage
import SwiftUI

public struct ListViewFeature: ReducerProtocol {
    public struct State: Equatable {
        var title: String
        var notes: [Note]
        
        public init(
            title: String,
            notes: [Note]
        ) {
            self.title = title
            self.notes = notes
        }
    }

    public enum Action {
        case onAppear
    }
    
    @Dependency(\.storageClient) var storageClient
    
    public init() {}

    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.title = "\(state.title) appeared!"
                state.notes = storageClient.fetchAllNotes()
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
            Text(viewStore.title)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 10) {
                    ForEach(viewStore.notes) { note in
                        NoteView(note: note)
                    }
                }
            }
        }
        .padding(10)
        .onAppear {
            viewStore.send(.onAppear, animation: .default.delay(0.5))
        }
    }
}

struct NoteView: View {
    
    var note: Note
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(formateDate(note.date))")
            Text(note.caption)
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
