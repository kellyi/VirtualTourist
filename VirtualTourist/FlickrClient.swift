//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/9/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    var photos: [Photo] = []
    
    let flickrAPIKey = FlickrClient.Constants.ApiKey
    let license = "1,2,3,4,5,6,8" // public domain and select creative commons licenses
    
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
    }
    
    func getPhotosUsingCompletionHandler(latitude: Double, longitude: Double, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        let computedBBox = createBoundingBoxString(latitude, longitude: longitude)
        let flickrSearchURL = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrAPIKey)&license=\(license)&bbox=\(computedBBox)&safe_search=1&content_type=1&format=json&nojsoncallback=1"
        let request = NSMutableURLRequest(URL: NSURL(string: flickrSearchURL)!)
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(success: false, errorString: "Encountered an error")
            } else {
                var error: NSError?
                let result = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error) as! NSDictionary?
                if let result = result {
                    println(result)
                }
                completionHandler(success: true, errorString: nil)
            }
        }
        task.resume()
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
}
