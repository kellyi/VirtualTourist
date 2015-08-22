//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/9/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import Foundation
import CoreData

class FlickrClient : NSObject {
    
    // replace with your own Flickr API Key
    let flickrAPIKey = FlickrClient.Constants.ApiKey
    
    // public domain and select Creative Commons licenses
    let license = "1,2,3,4,5,6,8"
    let flickrURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    let flickrExtraParams = "&safe_search=1&content_type=1&format=json&nojsoncallback=1"
    let perPage = "21"
    
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
    lazy var sharedContext: NSManagedObjectContext = {
        return CoreDataStackManager.sharedInstance().managedObjectContext!
    }()
    
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }
    
    func getPhotosUsingCompletionHandler(pin: Pin, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        let computedBBox = createBoundingBoxString(latitude, longitude: longitude)
        let flickrSearchURL = "\(flickrURL)&api_key=\(flickrAPIKey)&license=\(license)&per_page=\(perPage)&bbox=\(computedBBox)\(flickrExtraParams)"
        let request = NSMutableURLRequest(URL: NSURL(string: flickrSearchURL)!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Encountered an error")
            } else {
                var error: NSError?
                let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary?
                if let result = result {
                    if let dictResult = result["photos"] as! NSDictionary? {
                        if let totalPages = dictResult["pages"] as? Int {
                            let pageLimit = min(totalPages, 40)
                            let randomPage = Int(arc4random_uniform(UInt32(pageLimit))) + 1
                            self.getPhotosWithPageUsingCompletionHandler(pin, pageNumber: randomPage, completionHandler: completionHandler)
                        }
                    }
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
    
    func getPhotosWithPageUsingCompletionHandler(pin: Pin, pageNumber: Int, completionHandler: (success: Bool, errorString: String?) -> Void) {
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        let computedBBox = createBoundingBoxString(latitude, longitude: longitude)
        let flickrSearchURL = "\(flickrURL)&api_key=\(flickrAPIKey)&license=\(license)&per_page=21&page=\(pageNumber)&bbox=\(computedBBox)\(flickrExtraParams)"
        let request = NSMutableURLRequest(URL: NSURL(string: flickrSearchURL)!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Encountered an error")
            } else {
                var error: NSError?
                let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary?
                if let result = result {
                    if let dictResult = result["photos"] as! NSDictionary? {
                        if let arrayResult = dictResult["photo"] as! NSArray? {
                            if arrayResult.count >= 1 {
                                for pic in arrayResult {
                                    let newPic = self.photoFromDictionary(pic as! NSDictionary)
                                    newPic!.pin = pin
                                }
                            }
                        }
                    }
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
    }
    
    func photoFromDictionary(photoDictionary: NSDictionary) -> Photo? {
        let photoID = photoDictionary["id"] as! String
        let farm = photoDictionary["farm"] as! NSNumber
        let server = photoDictionary["server"] as! String
        let secret = photoDictionary["secret"] as! String
        let flickrURL = getPhotoURL(photoID, farm: farm, server: server, secret: secret)
        let initializerDictionary = ["id": photoID, "flickrURL": flickrURL] as [String:AnyObject]
        return Photo(dictionary: initializerDictionary, context: sharedContext)
    }
    
    // Convenience method to turn photo dictionary into a URL
    func getPhotoURL(id: String, farm: NSNumber, server: String, secret: String) -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
    
    // MARK: - Create Bounding Box for API Call
    
    func createBoundingBoxString(latitude: Double, longitude: Double) -> String {
        let bounding_box_half_width = 0.3
        let bounding_box_half_height = 0.3
        let lat_min = -90.0
        let lat_max = 90.0
        let lon_min = -180.0
        let lon_max = 180.0
        let bottom_left_lon = max(longitude - bounding_box_half_width, lon_min)
        let bottom_left_lat = max(latitude - bounding_box_half_height, lat_min)
        let top_right_lon = min(longitude + bounding_box_half_width, lon_max)
        let top_right_lat = min(latitude + bounding_box_half_height, lat_max)
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    // MARK: - Shared Instance
    
    // make this class a singleton to share across classes
    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
    
    // MARK: - Shared Image Cache
    
    struct Caches {
        static let imageCache = ImageCache()
    }
}
