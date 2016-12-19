//
//  FlickrClient.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
class FlickrClient: NSObject {
    
    var session: URLSession
    
    
    static let sharedInstance = FlickrClient()
    
    fileprivate override init() {
        session = URLSession.shared
        super.init()
    }
    // MARK: GET Methods
    func taskForGETMethod(_ url: String?, parameters: [String : AnyObject]?, parseJSON: Bool, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        var urlString = (url != nil) ? url : Constants.BASE_URL
        if parameters != nil {
            var mutableParameters = parameters
            mutableParameters![Constants.API_KEY] = Constants.APIKey as AnyObject?
            urlString = urlString! + self.escapedParameters(mutableParameters!)
        }
        
        let url = URL(string: urlString!)!
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            
            //checking for the error
            guard (error == nil) else {
                print("There was an error with your request: \(error)")
                completionHandler(nil, NSError(domain: "getTask", code: 2, userInfo: nil))
                return
            }
            
            //Checking for the status code
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                var errorCode = 0
                if let response = response as? HTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                    errorCode = response.statusCode
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                DispatchQueue.main.async(execute: {
                    completionHandler(nil, NSError(domain: "getTask", code: errorCode, userInfo: nil))
                })
                return
            }
            
            guard let data = data else {
                print("No data was returned by the request!")
                completionHandler(nil, NSError(domain: "getTask", code: 3, userInfo: nil))
                return
            }
            
            if parseJSON {
                self.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            } else {
                completionHandler(data as AnyObject?, nil)
            }
            
        })
        
        task.resume()
        
        return task
    }
    func escapedParameters(_ parameters: [String : AnyObject]) -> String {
        
        var variedURL = [String]()
        
        for (key, value) in parameters {
            
            let stringValue = "\(value)"
            
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            variedURL += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!variedURL.isEmpty ? "?" : "") + variedURL.joined(separator: "&")
    }
    //JSON Parsing
    func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: Any!
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandler(nil, NSError(domain: "parseJSONWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandler(parsedResult as AnyObject?, nil)
    }
}
