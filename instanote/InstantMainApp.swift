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
    var service: NoteService = MockNoteService()
        //RealNoteService(context: PersistenceFactory.getContext())

    func addExampleNote() {
        _ = service.createNote(caption: "Welcome! Click me to edit, or click the ⊕ buttom below to create new notes. Add #hashtags to notes to make searching #easy!",
                           uiImage: UIImage(named: "hula"),
                           location: CLLocationCoordinate2D(
                            latitude: 20.7984, longitude: 156.3319))
        service.save()
        UserDefaults.standard.isFirstLaunch = false
    }

    init() {
        // TESTING
//        MockData.CreateTestData(service: service)
        
        if UserDefaults.standard.isFirstLaunch { // TODO: check for notes?
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
