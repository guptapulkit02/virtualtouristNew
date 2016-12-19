//
//  FlickrDownloader.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData

extension FlickrClient {
    
    
    func getPhotosForPin(_ pin: Pin, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        var pageNumber = 1
        
        if let numPages = pin.numPages {
            var numPagesInt = numPages as Int
            if numPagesInt > 190 {
                numPagesInt = 190
            }
            pageNumber = Int((arc4random_uniform(UInt32(numPagesInt)))) + 1
            print("Getting photos for page number \(pageNumber) in \(numPages) total pages")
        }
        let possibleSorts = ["date-posted-desc", "date-posted-asc", "date-taken-desc", "date-taken-asc", "interstingness-desc", "interestingness-asc"]
        let sortBy = possibleSorts[Int((arc4random_uniform(UInt32(possibleSorts.count))))]
        
        let parameters = [
            Constants.METHOD: Constants.SEARCH,
            Constants.EXTRAS: Constants.URL_M,
            Constants.FORMAT: Constants.JSON_FORMAT,
            Constants.NO_JSON_CALLBACK: "1",
            Constants.SAFE_SEARCH: "1",
            Constants.BBOX: createBoundingBoxString(pin),
            Constants.PAGE: pageNumber,
            Constants.PER_PAGE: 21,
            Constants.SORT: sortBy
            ] as [String : Any]
        
        taskForGETMethod(nil, parameters: parameters as [String : AnyObject], parseJSON: true) { (JSONResult, error) in
            if let error = error {
                var errorMessage = ""
                switch error.code {
                case 2:
                    errorMessage = "Network connection lost"
                    break
                default:
                    errorMessage = "A technical error occured while fetching photos"
                    break
                }
                completionHandler(false,errorMessage)
            } else {
                if let photosDictionary = JSONResult?.value(forKey: "photos") as? [String: AnyObject],
                    let photosArray = photosDictionary["photo"] as? [[String: AnyObject]],
                    let numPages = photosDictionary["pages"] as? Int {
                    
                    DispatchQueue.main.async(execute: {
                        pin.numPages = numPages as NSNumber?
                        
                        for photoDictionary in photosArray {
                            let photoURLString = photoDictionary["url_m"] as! String
                            let photo = Photo(photoURL: photoURLString, pin: pin, context: self.sharedContext)
                            
                            self.downloadImageForPhoto(photo) { (success, errorString) in
                                if success {
                                    DispatchQueue.main.async(execute: {
                                        CoreDataStackManager.sharedInstance().saveContext()
                                        completionHandler(true, nil)
                                    })
                                } else {
                                    DispatchQueue.main.async(execute: {
                                        completionHandler(false, errorString)
                                    })
                                }
                            }
                        }
                    })
                } else {
                    completionHandler(false, "Unable to download Photos")
                }
            }
        }
    }
    
    func downloadImageForPhoto(_ photo: Photo, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        
        taskForGETMethod(photo.photoURL, parameters: nil, parseJSON: false) { (result, error) in
            if error != nil {
                photo.imagePath = "unavailable"
                completionHandler(false, "Unable to download Photo")
            } else {
                if let result = result {
                    DispatchQueue.main.async(execute: {
                        let fileName = (photo.photoURL as NSString).lastPathComponent
                        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let pathArray = [path, fileName]
                        let fileURL = NSURL.fileURL(withPathComponents: pathArray)!
                        FileManager.default.createFile(atPath: fileURL.path, contents: result as? Data, attributes: nil)
                        
                        photo.imagePath = fileURL.path
                        completionHandler(true, nil)
                    })
                } else {
                    completionHandler(false, "Unable to download Photo")
                }
            }
        }
    }
    
    func createBoundingBoxString(_ pin: Pin) -> String {
        
        let latitude = pin.coordinate.latitude
        let longitude = pin.coordinate.longitude
        let bottom_left_lon = max(longitude - Constants.BOUNDING_BOX_HALF_WIDTH, Constants.LON_MIN)
        let bottom_left_lat = max(latitude - Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MIN)
        let top_right_lon = min(longitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LON_MAX)
        let top_right_lat = min(latitude + Constants.BOUNDING_BOX_HALF_HEIGHT, Constants.LAT_MAX)
        return "\(bottom_left_lon),\(bottom_left_lat),\(top_right_lon),\(top_right_lat)"
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
}
