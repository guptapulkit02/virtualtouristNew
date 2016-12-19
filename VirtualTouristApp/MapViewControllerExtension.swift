//
//  BaseViewController.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MapViewControllerExtension: UIViewController {
    
    let pinFinishedDownloadingNotification = "pinFinishedDownloadNotification"
    
    func getPhotosForPin(_ pin: Pin, completionHandler: @escaping (_ success: Bool, _ errorString: String?) -> Void) {
        if (pin.isDownloading) {
            return
        }
        pin.isDownloading = true
        FlickrClient.sharedInstance.getPhotosForPin(pin) { (success, errorString) in
            pin.isDownloading = false
            
            CoreDataStackManager.sharedInstance().saveContext()
            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: self.pinFinishedDownloadingNotification), object: self))
            completionHandler(success, errorString)
        }
    }
    
    func showAlert(_ title: String, message: String, buttonText: String = "Ok", shake: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonText, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    var sharedContext: NSManagedObjectContext {
        return CoreDataStackManager.sharedInstance().managedObjectContext
    }
}
