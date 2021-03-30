//
//  InstaMainApp.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/11/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import SwiftUI
import CoreLocation

@main
struct InstaMainApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var service: NoteService = RealNoteService(context: PersistenceFactory.getContext())

    func addExampleNote() {
        _ = service.createNote(caption: "Welcome! Click me to edit, or click the ⊕ buttom below to create new notes. Add #hashtags to notes to make searching #easy!",
                           uiImage: UIImage(named: "hula"),
                           location: CLLocationCoordinate2D(
                            latitude: 20.7984, longitude: 156.3319))
        service.save()
        UserDefaults.standard.isFirstLaunch = false
    }
    
    func addTestData() {
        for i in 0 ..< MockData.captions.count {
            let note = service.createNote(caption: MockData.captions[i],
                                          uiImage: nil,
                                          location: CLLocationCoordinate2D(latitude: MockData.locations[i].lat, longitude: MockData.locations[i].long))
            note.photo = MockData.photos[i]
        }
    }

    init() {
//        addTestData()
        
        if UserDefaults.standard.isFirstLaunch && service.publisher.value.isEmpty {
            addExampleNote()
        } else {
            UserDefaults.standard.isFirstLaunch = false
        }
    }
    
    var body: some Scene {
        WindowGroup {
            InstaMainView(viewModel: .init(service: service))
        }
    }
}
