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
    
    static var appDelegate:AppDelegate { return UIApplication.sharedApplication().delegate as! AppDelegate }

    // MARK : Create Methods
    static func createLocation(coordinate:CLLocationCoordinate2D) ->Location?{
        if let location = NSEntityDescription.insertNewObjectForEntityForName(Entities.Location, inManagedObjectContext: appDelegate.managedObjectContext) as? Location{
            location.lat = coordinate.latitude
            location.long = coordinate.longitude
            return location
        }
        return nil
    }
    
    static func createNote(caption:String?, photo:String?, location:CLLocationCoordinate2D?)->Note?{
        
        if var note = NSEntityDescription.insertNewObjectForEntityForName(Entities.Note, inManagedObjectContext: self.appDelegate.managedObjectContext) as? Note {
            updateNote(&note, caption: caption, photo: photo, location: location)
            return note
        }
        return nil
    }
    
    static func createTag(tagName:String) ->Tag?{
        if tagName == "" {
            return nil
        }
        if let tag = NSEntityDescription.insertNewObjectForEntityForName(Entities.Tag, inManagedObjectContext: appDelegate.managedObjectContext) as? Tag{
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
    
    static func deleteNote(note:Note){
        
        deleteObject(note)
        
        RequestManager.save()
        
    }
    
    static func deleteNotes(){
        _ = RequestManager.getNotes()?.map() { RequestManager.deleteObject($0) }
    }
    
    static func deleteObject(object:NSManagedObject){
        appDelegate.managedObjectContext.deleteObject(object)
    }

    static func deleteTags(){
        _ = RequestManager.getTags()?.map() { RequestManager.deleteObject($0) }
    }
    
    
    // MARK : Get Methods
    static func getLocation(coordinate:CLLocationCoordinate2D) ->Location?{
        let request = NSFetchRequest(entityName: Entities.Location)
        request.returnsObjectsAsFaults = false

        let latPredicate = NSPredicate(format: "lat = %d", coordinate.latitude)
        let longPredicate = NSPredicate(format: "long = %d", coordinate.longitude)
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, longPredicate])

        do{
            if let locations = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Location]{
                return locations.first
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getLocations()->[Location]?{
        let request = NSFetchRequest(entityName: Entities.Location)
        request.returnsObjectsAsFaults = false
        
        do{
            if let locations = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Location]{
                return locations
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getNotes()->[Note]?{
        let request = NSFetchRequest(entityName: Entities.Note)
        request.returnsObjectsAsFaults = false
        
        do{
            if let notes = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Note]{
                return notes
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getNotes(captionPrefix:String)->[Note]?{
        let request = NSFetchRequest(entityName: Entities.Note)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Note.Constants.Properties.Caption, ascending: true)]
        request.predicate = NSPredicate(format: "caption BEGINSWITH[c] %@", captionPrefix)
        
        do{
            if let notes = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Note]{
                return notes
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getTag(tag:String)->Tag?{
        let request = NSFetchRequest(entityName: Entities.Tag)
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "name = %@", tag)
        do{
            if let tags = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Tag]{
                return tags.first
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getTags()->[Tag]?{
        let request = NSFetchRequest(entityName: Entities.Tag)
        request.returnsObjectsAsFaults = false
        
        do{
            if let tags = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Tag]{
                return tags
            }
        } catch _ {
            print ("no results found")
        }
        
        return nil
    }
    
    static func getTags(searchString:String)->[Tag]?{
        let request = NSFetchRequest(entityName: Entities.Tag)
        request.returnsObjectsAsFaults = false
        request.sortDescriptors = [NSSortDescriptor(key: Tag.Constants.Properties.Name, ascending: true)]
        request.predicate = NSPredicate(format: "name BEGINSWITH[c] %@", searchString)
        
        do{
            if let tags = try appDelegate.managedObjectContext.executeFetchRequest(request) as? [Tag]{
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
            appDelegate.managedObjectContext.save()
            
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
    static func updateNote(inout note:Note, caption:String?, photo:String?, location:CLLocationCoordinate2D?){
        note.caption = caption
        note.photo = photo
        note.date = NSDate()
        note.tags = nil
        
        if let tags = caption?.matchesForRegex("\\#+\\w+") {
            _ = tags.map() {
                let string = $0.stringByReplacingOccurrencesOfString("#", withString: "", options: .LiteralSearch, range: nil)

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