import ListFeature
import SwiftUI

@main
struct instanoteApp: App {
    var body: some Scene {
        WindowGroup {
            ListView(store:.init(
                initialState: .init(),
                reducer: ListViewFeature()
                    .dependency(\.databaseClient, .previewValue)
                    .dependency(\.fileClient, .previewValue)
            ))
        }
    }
}
