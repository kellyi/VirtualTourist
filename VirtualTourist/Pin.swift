//
//  Pin.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/10/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import Foundation

class Pin {
    
    struct Keys {
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let Photos = "photos"
    }
    
    var latitude: String
    var longitude: String
    var photos: [Photo] = [Photo]()
    
    init(dictionary: [String : AnyObject]) {
        latitude = dictionary[Keys.Latitude] as! String
        longitude = dictionary[Keys.Longitude] as! String
    }
}