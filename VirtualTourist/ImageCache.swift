//
//  ImageCache.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/22/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import UIKit

class ImageCache {
    
    func imageWithIdentifier(identifier: String?) -> UIImage? {
        
        if identifier == nil || identifier == "" {
            return nil
        }
        
        let path = pathForIdentifier(identifier!)
        var data: NSData?
        
        if let data = NSData(contentsOfFile: path) {
            return UIImage(data: data)
        }
        
        return nil
    }
    
    func storeImage(image: UIImage?, withIdentifier identifier: String) {
        
        let path = pathForIdentifier(identifier)
        
        if image == nil {
            NSFileManager.defaultManager().removeItemAtPath(path, error: nil)
            return
        }
        
        let data = UIImagePNGRepresentation(image!)
        data.writeToFile(path, atomically: true)
    }
    
    func pathForIdentifier(identifier: String) -> String {
        let documentsDirectoryURL: NSURL = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as! NSURL
        let fullURL = documentsDirectoryURL.URLByAppendingPathComponent(identifier)
        
        return fullURL.path!
    }
    
}
