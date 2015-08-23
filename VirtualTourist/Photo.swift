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
    
    struct Keys {
        static let ID = "id"
        static let ImagePath = "image_path"
        static let Title = "title"
        static let FlickrURL = "flickrURL"
    }
    
    @NSManaged var id: String?
    @NSManaged var pin: Pin
    @NSManaged var imagePath: String?
    @NSManaged var flickrURL: String?
    
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
    
    func saveImageToDocumentsDirectoryFromURL() {
        let photoFileName = "\(id!).png"
        let imageURL = NSURL(string: flickrURL!)
        let imageData = NSData(contentsOfURL: imageURL!)
        let image = UIImage(data: imageData!)
        let imageDataPNG = UIImagePNGRepresentation(image)
        let path = getPathToPhotoFile()
        imageDataPNG.writeToFile(path, atomically: true)
    }
    
    func retrieveImageFromDocumentsDirectory() -> UIImage? {
        let path = getPathToPhotoFile()
        let data = NSData(contentsOfFile: path)
        return UIImage(data: data!)
    }
    
    override func prepareForDeletion() {
        deleteFile()
    }
    
    func deleteFile() {
        let fileManager = NSFileManager.defaultManager()
        let path = getPathToPhotoFile()
        println("deleting \(imagePath!)")
        fileManager.removeItemAtPath(path, error: nil)
    }
    
    func getPathToPhotoFile() -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(imagePath!)
        return fullURL.path!
    }
}