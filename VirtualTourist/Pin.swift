//
//  Pin.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/10/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit
import CoreData

@objc(Pin)

class Pin : NSManagedObject {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
        static let ID = "id"
    }
    
    @NSManaged var id: NSNumber
    @NSManaged var latitude: String
    @NSManaged var longitude: String
    @NSManaged var photos: [Photo]
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        id = dictionary[Keys.ID] as! Int
        latitude = dictionary[Keys.Latitude] as! String
        longitude = dictionary[Keys.Longitude] as! String
    }
}