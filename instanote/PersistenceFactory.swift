//
//  PersistenceFactory.swift
//  InstaNote
//
//  Created by Jordan Doczy on 3/21/21.
//  Copyright © 2021 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData
import UIKit

struct PersistenceFactory {
    
    enum ContainerType {
        case external
        case memory
    }

    static func getContext(type: ContainerType = .external) -> NSManagedObjectContext {
        switch type {
        case .external:

            /// legacy code
            /// keeping this to ensure coredata entries are preserved 
            var coordinator: NSPersistentStoreCoordinator {
                
                var applicationDocumentsDirectory: URL {
                    let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                    return urls[urls.count-1]
                }
                
                var managedObjectModel: NSManagedObjectModel {
                    let modelURL = Bundle.main.url(forResource: "instanote", withExtension: "momd")!
                    return NSManagedObjectModel(contentsOf: modelURL)!
                }

                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
                let url = applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")

                do {
                    try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
                } catch {
                    abort()
                }

                return coordinator
            }
            
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            managedObjectContext.persistentStoreCoordinator = coordinator
            return managedObjectContext

        case .memory:
            let container = NSPersistentContainer(name: "instanote")
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
            container.loadPersistentStores { description, error in
                if let error = error {
                    fatalError("Error: \(error.localizedDescription)")
                }
            }

            return container.viewContext
        }
    }
}
