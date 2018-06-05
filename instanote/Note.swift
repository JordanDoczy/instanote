//
//  Note.swift
//  instanote
//
//  Created by Jordan Doczy on 11/28/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

protocol NoteDataSource {
    var note: Note? { get set }
}
class Note: NSManagedObject, MKAnnotation {
    
    struct Constants{
        struct Relationships {
            static let Tags = "tags"
            static let Location = "location"
        }
        struct Properties {
            static let Caption = "caption"
            static let Date = "date"
            static let Photo = "photo"
        }
        
    }
    
    
    
    var coordinate: CLLocationCoordinate2D {
        return location?.coordinate ?? CLLocationCoordinate2D()
    }
    
    var imagePath: String? {
        if photo != nil {
            return AppDelegate.sharedInstance().getFilePath(photo!)
        }
        return nil
    }
    
    var title: String? {
        return caption != nil ? caption : ""

    }
    var subtitle: String? {
        let str:String? = date != nil ? formateDate(date! as Date) : nil
        return str != title ? str : nil
    }
    
    func formateDate(_ date:Date)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: date)
    }
    
    func addTag(_ tag:Tag){
        mutableSetValue(forKey: Constants.Relationships.Tags).add(tag)
    }
    
    func removeTag(_ tag:Tag){
        mutableSetValue(forKey: Constants.Relationships.Tags).remove(tag)
    }
    
    func debug(_ prepend:String = "Note:"){
        if let caption = caption {
            print(prepend + caption)
        }
        if let date = date {
            print("\tdate:"+"\(date)")
        }
        if let tags = tags {
            tags.forEach { tag in
                (tag as? Tag)?.debug("\ttag:")
            }
        }
        if let location = location {
            location.debug("\tlocation:")
        }
        if let photo = photo {
            print("\tphoto:"+photo)
        }
    }

}
