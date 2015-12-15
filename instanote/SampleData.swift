//
//  SampleData.swift
//  RememberThat
//
//  Created by Jordan Doczy on 12/7/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

import MapKit
import Photos

class SampleData {
    
    static func GetData(limit:Int){
        func random(min min: Double, max: Double) -> Double {
            return Double(arc4random()) * (max - min) + min
        }
        
        let locations = [
            CLLocationCoordinate2D(latitude: 37.7749290, longitude: -122.4194160),
            CLLocationCoordinate2D(latitude: 37.8205051, longitude: -122.4781242),
            CLLocationCoordinate2D(latitude: 37.7852404, longitude: -122.1811500),
            CLLocationCoordinate2D(latitude: 37.7846977, longitude: -122.1516243),
            CLLocationCoordinate2D(latitude: 37.7528090, longitude: -122.2462097),
            CLLocationCoordinate2D(latitude: 37.3325025, longitude: -121.9111267),
            CLLocationCoordinate2D(latitude: 34.0498231, longitude: -118.2087341),
            CLLocationCoordinate2D(latitude: 36.1794619, longitude: -115.1435485),
            CLLocationCoordinate2D(latitude: 36.7273359, longitude: -119.7687927),
            CLLocationCoordinate2D(latitude: 39.5268262, longitude: -119.8237243),
        ]

        
        let photos = [
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-8LG5pQC/1/L/IMG_1238-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-B3Xq4nk/0/L/IMG_7977-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-jKw2Vqr/0/L/IMG_7968-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-s5jrNQr/0/L/IMG_7998-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-p2drdnP/0/L/IMG_8040-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-mG5gWZz/0/L/IMG_8002-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-hLmXWCN/0/L/IMG_8263-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-cdjm5t5/0/L/IMG_8475-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-tzxCS86/1/L/IMG_8998-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-wmNzD2B/0/L/IMG_3485-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-3gfFLnv/0/L/IMG_1556-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-NPvKVgP/0/L/IMG_1545-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-5MnrMv5/0/L/IMG_1476-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-B4792CM/0/L/IMG_1454-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-xtN6k2J/0/L/IMG_1437-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-Qfs7cSr/0/L/IMG_1416-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-4Dnv2t6/0/L/IMG_1407-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-VMd7ddQ/0/L/IMG_1371-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-sjmsC67/0/L/IMG_1270-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-NPbJKQp/1/L/IMG_1241-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-25rzW2z/0/L/IMG_1191-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-WSt3vLQ/0/L/IMG_1184-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-mV5JzV5/0/L/IMG_1151-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-2ZdTN2C/0/L/IMG_0787-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-Dbq9VZS/0/L/IMG_0769-Edit-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-CqthfkC/0/L/IMG_0764-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-Q6Tq6qc/0/L/IMG_0696-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-FKkCHj9/0/L/IMG_0506-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-6Frv9H5/0/L/IMG_0686-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-L5hqQq7/0/L/IMG_0653-L.jpg"
            
        ]
        
        

        
        if let path = NSBundle.mainBundle().pathForResource("dictionary", ofType: "txt"){
            let fm = NSFileManager()
            let exists = fm.fileExistsAtPath(path)
            if(exists){
                let contents = fm.contentsAtPath(path)
                let cString = NSString(data: contents!, encoding: NSUTF8StringEncoding)
                let string = cString as! String
                let terms = string.characters.split{$0 == "\n"}.map(String.init)
                
                RequestManager.deleteAll()
                RequestManager.save()
                
                let l = limit <= 30 ? limit : 30
                
                for index in 0 ..< l {
                    
                    
                    var caption = terms[Int(arc4random_uniform(UInt32(terms.count-1)))]
                    let photo = photos[index]
                    let location = locations[Int(arc4random_uniform(UInt32(locations.count-1)))]

                    for _ in 0 ..< (arc4random_uniform(20)) {
                        let i = Int(arc4random_uniform(UInt32(terms.count-1)))
                        
                        let definition = terms[i].characters.split{$0 == " "}.map(String.init)
                        
                        if let term = definition.first{
                            caption += " #" + term +  " "
                        }
                    }
                    
                    RequestManager.createNote(caption, photo: photo, location: location)
                }
                
                RequestManager.save()

                
            }
        }
        
    }
    
    
    static func InsertData(){
        
        
        let captions = [
            "Buildings downtown SF",
            "Party!",
            "My dog",
            "New Laptop",
            "Breakfast",
            "Dinner",
            "Airport Parking",
            "Shopping",
            "Long caption test, it's really really long",
            "Friends",
        ]
        
        let photos = [
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-8LG5pQC/1/L/IMG_1238-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-B3Xq4nk/0/L/IMG_7977-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-jKw2Vqr/0/L/IMG_7968-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-s5jrNQr/0/L/IMG_7998-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-p2drdnP/0/L/IMG_8040-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-mG5gWZz/0/L/IMG_8002-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-hLmXWCN/0/L/IMG_8263-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-cdjm5t5/0/L/IMG_8475-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-tzxCS86/1/L/IMG_8998-L.jpg",
            "https://jordandoczy.smugmug.com/Photography/PhotoStream/i-wmNzD2B/0/L/IMG_3485-L.jpg"
        ]
        
        let tags = [
            "cat",
            "bird",
            "dog",
            "wood",
            "cake",
            "forest",
            "work",
            "internet",
            "computer",
            "mobile",
            "city",
            "sf",
            "buildings",
            "street",
            "people",
            "things",
            "life",
            "dirty",
            "alpha",
            "beta",
            "phone",
            "cold",
            "weather",
            "holidays",
            "electronic",
            "sale",
            "paint",
            "home"
        ]
        
        let locations = [
            CLLocationCoordinate2D(latitude: 37.7749290, longitude: -122.4194160),
            CLLocationCoordinate2D(latitude: 37.8205051, longitude: -122.4781242),
            CLLocationCoordinate2D(latitude: 37.7852404, longitude: -122.1811500),
            CLLocationCoordinate2D(latitude: 37.7846977, longitude: -122.1516243),
            CLLocationCoordinate2D(latitude: 37.7528090, longitude: -122.2462097),
            CLLocationCoordinate2D(latitude: 37.3325025, longitude: -121.9111267),
            CLLocationCoordinate2D(latitude: 34.0498231, longitude: -118.2087341),
            CLLocationCoordinate2D(latitude: 36.1794619, longitude: -115.1435485),
            CLLocationCoordinate2D(latitude: 36.7273359, longitude: -119.7687927),
            CLLocationCoordinate2D(latitude: 39.5268262, longitude: -119.8237243),
        ]
        
        RequestManager.deleteAll()
        RequestManager.save()

        for index in 0 ..< captions.count {
            
            var caption = captions[index]
            let photo = photos[index]
            
            for _ in 0 ..< (arc4random_uniform(10)) {
                let i = Int(arc4random_uniform(UInt32(tags.count-1)))
                caption += " #" + tags[i] + " "
            }
            
            RequestManager.createNote(caption, photo: photo, location: locations[index])
        }

        RequestManager.save()

    }
    
}
