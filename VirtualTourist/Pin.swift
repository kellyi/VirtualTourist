//
//  Pin.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/10/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit
import CoreData
import MapKit

@objc(Pin)

class Pin : NSManagedObject, MKAnnotation {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var photos: Set<Photo>
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(annotationLatitude: Double, annotationLongitude: Double, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        latitude = annotationLatitude
        longitude = annotationLongitude
    }
}