//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Kelly Innes on 8/9/15.
//  Copyright (c) 2015 Kelly Innes. All rights reserved.
//

import Foundation

class FlickrClient : NSObject {
    
    var photos = [Photo]()
    
    let flickrAPIKey = FlickrClient.Constants.ApiKey
    let baseURL = FlickrClient.Constants.BaseURL
    let methodName = FlickrClient.Constants.MethodName
    let extras = FlickrClient.Constants.Extras
    let safeSearch = FlickrClient.Constants.SafeSearch
    let dataFormat = FlickrClient.Constants.DataFormat
    let noJSONCallback = FlickrClient.Constants.NoJSONCallback
    
    var session: NSURLSession
    var completionHandler : ((success: Bool, errorString: String?) -> Void)? = nil
    
    override init() {
        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        session = NSURLSession(configuration: config)
        super.init()
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
