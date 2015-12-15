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
    
    var title: String? {
        return caption != nil ? caption : ""

    }
    var subtitle: String? {
        let str:String? = date != nil ? formateDate(date!) : nil
        return str != title ? str : nil
    }
    
    func formateDate(date:NSDate)->String{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.stringFromDate(date)
    }

    
    func addTag(tag:Tag){
        mutableSetValueForKey(Constants.Relationships.Tags).addObject(tag)
    }
    
    func removeTag(tag:Tag){
        mutableSetValueForKey(Constants.Relationships.Tags).removeObject(tag)
    }
    
    func debug(prepend:String = "Note:"){
        if caption != nil{
            print(prepend + caption!)
        }
        if date != nil{
            print("\tdate:"+"\(date!)")
        }
        if tags != nil{
            for tag in tags!{
                tag.debug("\ttag:")
            }
        }
        if location != nil {
            location!.debug("\tlocation:")
        }
        if photo != nil {
            print("\tphoto:"+photo!)
        }
    }

}
