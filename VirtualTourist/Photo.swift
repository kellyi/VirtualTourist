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
        // TODO: additional keys
    }
    
    @NSManaged var id: String?
    @NSManaged var pin: Pin?
    @NSManaged var imagePath: String?
    @NSManaged var title: String?
    @NSManaged var flickrURL: String?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String : AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        id = dictionary[Keys.ID] as? String!
        title = dictionary[Keys.Title] as? String!
        flickrURL = dictionary[Keys.FlickrURL] as? String!
        
        // TODO: download the flickr image to the documents directory
        saveImageToDocumentsDirectoryFromURL()
        println(imagePath)
    }
    
    func saveImageToDocumentsDirectoryFromURL() {
        let fileManager = NSFileManager.defaultManager()
        let directoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        let photoFileName = "\(id!).png"
        let filePathToWrite = "\(directoryPath)/\(photoFileName)"
        let imageURL = NSURL(string: flickrURL!)
        let imageData = NSData(contentsOfURL: imageURL!)
        let image = UIImage(data: imageData!)
        let imageDataPNG = UIImagePNGRepresentation(image)
        fileManager.createFileAtPath(filePathToWrite, contents: imageDataPNG, attributes: nil)
        self.imagePath = filePathToWrite
    }
    
    override func prepareForDeletion() {
        if let fileName = imagePath?.lastPathComponent {
            let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
            let pathArray = [dirPath, fileName]
            let fileURL = NSURL.fileURLWithPathComponents(pathArray)!
            println("deleting \(imagePath)")
            NSFileManager.defaultManager().removeItemAtURL(fileURL, error: nil)
        }
    }
}