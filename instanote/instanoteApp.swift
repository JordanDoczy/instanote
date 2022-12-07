import ListFeature
import SwiftUI

@main
struct instanoteApp: App {
    var body: some Scene {
        WindowGroup {
            ListView(store:.init(
                initialState: .init(title: "Notes", notes: []),
                reducer: ListViewFeature()
                    .dependency(\.storageClient, .previewValue)
            ))
        }
    }
}
