//
//  Photo+CoreDataClass.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData
import UIKit

public class Photo: NSManagedObject {
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertInto: context)
    }
    
    init(photoURL: String, pin: Pin, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context)!
        super.init(entity: entity, insertInto: context)
        self.photoURL = photoURL
        self.pin = pin
    }
    
    var image: UIImage? {
        if imagePath != nil {
            let fileURL = getFileURL()
            return UIImage(contentsOfFile: fileURL.path)
        }
        return nil
    }
    
    func getFileURL() -> URL {
        let fileName = (imagePath! as NSString).lastPathComponent
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileURL = URL(fileURLWithPath: dirPath, isDirectory: true).appendingPathComponent(fileName)
        return fileURL
    }
    
    
    override public func prepareForDeletion() {
        if (imagePath == nil) {
            return
        }
        let fileURL = getFileURL()
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
            } catch let error as NSError {
                print(error.userInfo)
            }
        }
    }

}
