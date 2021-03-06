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
    
    // MARK: - Variables
    
    // NSManaged var
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var photos: [Photo]
    
    // Computed coordinate variable to satisfy making the Pin an MKAnnotation subclass
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude.doubleValue, longitude: longitude.doubleValue)
    }
    
    // MARK: - Initializers
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