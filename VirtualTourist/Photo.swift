//
//  Photo.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/9/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit
import CoreData

@objc(Photo)

class Photo : NSManagedObject {
    
    // MARK: - Convenience Keys for Creating Photo from JSON Dictionary
    struct Keys {
        static let ID = "id"
        static let ImagePath = "image_path"
        static let Title = "title"
        static let FlickrURL = "flickrURL"
    }
    
    // MARK: - Variables
    
    // NSManaged var
    @NSManaged var id: String?
    @NSManaged var pin: Pin
    @NSManaged var imagePath: String?
    @NSManaged var flickrURL: String?
    
    // MARK: - Initializers
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        id = dictionary[Keys.ID] as? String!
        flickrURL = dictionary[Keys.FlickrURL] as? String!
        imagePath = "\(id!).png"
        saveImageToDocumentsDirectoryFromURL()
    }
    
    // MARK: - Photo File Methods
    
    // Save photo's image to Documents directory
    func saveImageToDocumentsDirectoryFromURL() {
        let photoFileName = "\(id!).png"
        let imageURL = NSURL(string: flickrURL!)
        let imageData = NSData(contentsOfURL: imageURL!)
        let image = UIImage(data: imageData!)
        let imageDataPNG = UIImagePNGRepresentation(image)
        let path = getPathToPhotoFile()
        imageDataPNG.writeToFile(path, atomically: true)
    }
    
    // Retrieve photo's image from Documents directory
    func retrieveImageFromDocumentsDirectory() -> UIImage? {
        let path = getPathToPhotoFile()
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        return nil
    }
    
    // Delete photo's image from Documents directory right before photo object is deleted
    override func prepareForDeletion() {
        let fileManager = NSFileManager.defaultManager()
        let path = getPathToPhotoFile()
        fileManager.removeItemAtPath(path, error: nil)
    }
    
    // Helper method to find full path to file in Documents directory
    func getPathToPhotoFile() -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(imagePath!)
        return fullURL.path!
    }
}