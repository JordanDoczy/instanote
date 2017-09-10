//
//  RequestManager.swift
//  instanote
//
//  Created by Jordan Doczy on 12/2/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class RequestManager{
    
    // MARK : Create Methods
    static func createLocation(_ coordinate:CLLocationCoordinate2D) ->Location?{
        if let location = NSEntityDescription.insertNewObject(forEntityName: Entities.Location, into: AppDelegate.sharedInstance().managedObjectContext) as? Location{
            location.lat = coordinate.latitude as NSNumber
            location.long = coordinate.longitude as NSNumber
            return location
        }
        return nil
    }
    
    static func createNote(_ caption:String?, photo:String?, location:CLLocationCoordinate2D?)->Note?{
        
        if var note = NSEntityDescription.insertNewObject(forEntityName: Entities.Note, into: AppDelegate.sharedInstance().managedObjectContext) as? Note {
            updateNote(&note, caption: caption, photo: photo, location: location)
            return note
        }
        return nil
    }
    
    static func createTag(_ tagName:String) ->Tag?{
        if tagName == "" {
            return nil
        }
        if let tag = NSEntityDescription.insertNewObject(forEntityName: Entities.Tag, into: AppDelegate.sharedInstance().managedObjectContext) as? Tag{
            tag.name = tagName
            return tag
        }
        return nil
    }
    
    // MARK : Delete Methods
    static func deleteAll(){
        deleteNotes()
        deleteTags()
        delelteLocations()
    }
    
    static func delelteLocations(){
        _ = RequestManager.getLocations()?.map() { RequestManager.deleteObject($0) }
    }
    
    static func deleteNote(_ note:Note){
        deletePhoto(note)
        deleteObject(note)
        
        RequestManager.save()
        
    }
    
    static func deleteNotes(){
        _ = RequestManager.getNotes()?.map() { RequestManager.deleteNote($0) }
    }
    
    static func deleteObject(_ object:NSManagedObject){
        AppDelegate.sharedInstance().managedObjectContext.delete(object)
    }
    
    static func deletePhoto(_ note:Note)->Bool{
        if note.imagePath != nil, let imageURL = URL(string:note.imagePath!){
            return AppDelegate.sharedInstance().deleteImage(imageURL)
        }
        return false
    }

    static func deleteTags(){
        _ = RequestManager.getTags()?.map() { RequestManager.deleteObject($0) }
    }
    
    
    // MARK : Get Methods
    static func getLocation(_ coordinate:CLLocationCoordinate2D) ->Location?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Location)
        request.returnsObjectsAsFaults = false

        let latPredicate = NSPredicate(format: "lat = %d", coordinate.latitude)
        let longPredicate = NSPredicate(format: "long = %d", coordinate.longitude)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, longPredicate])

        do{
            if let locations = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Location]{
                return locations.first
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getLocations()->[Location]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Location)
        request.returnsObjectsAsFaults = false
        
        do{
            if let locations = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Location]{
                return locations
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getNotes()->[Note]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Note)
        request.returnsObjectsAsFaults = false
        
        do{
            if let notes = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Note]{
                return notes
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getNotes(_ captionPrefix:String)->[Note]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Note)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Note.Constants.Properties.Caption, ascending: true)]
        request.predicate = NSPredicate(format: "caption BEGINSWITH[c] %@", captionPrefix)
        
        do{
            if let notes = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Note]{
                return notes
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getTag(_ tag:String)->Tag?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Tag)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", tag)
        do{
            if let tags = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Tag]{
                return tags.first
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getTags()->[Tag]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Tag)
        request.returnsObjectsAsFaults = false
        
        do{
            if let tags = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Tag]{
                return tags
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getTags(_ searchString:String)->[Tag]?{
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Entities.Tag)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Tag.Constants.Properties.Name, ascending: true)]
        request.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", searchString)
        
        do{
            if let tags = try AppDelegate.sharedInstance().managedObjectContext.fetch(request) as? [Tag]{
                return tags
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    // MARK : Save Methods
    static func save(){
        do { try
            AppDelegate.sharedInstance().managedObjectContext.save()
            
            if let tags = RequestManager.getTags(){
                for tag in tags{
                    if tag.notes?.count == 0{
                        RequestManager.deleteObject(tag)
                    }
                }
            }
            
            if let locations = RequestManager.getLocations(){
                for location in locations{
                    if location.notes?.count == 0{
                        RequestManager.deleteObject(location)
                    }
                }
            }

        }
        catch _ { }
    }
    
    
    // MARK : Update Methods
    static func updateNote(_ note:inout Note, caption:String?, photo:String?, location:CLLocationCoordinate2D?){

        if photo != note.photo {
            deletePhoto(note)
        }
        
        note.caption = caption
        note.photo = photo
        note.date = Date()
        note.tags = nil
        
        if let tags = caption?.matchesForRegex("\\#+\\w+") {
            _ = tags.map() {
                let string = $0.replacingOccurrences(of: "#", with: "", options: .literal, range: nil)

                if let tag = RequestManager.getTag(string) ?? createTag(string) {
                    note.addTag(tag)
                }
            }
        }
        
        if location != nil{
            note.location = getLocation(location!) ?? createLocation(location!)
        }
        
        
    }
    
}
