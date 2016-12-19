//
//  Pin+CoreDataClass.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import MapKit

public class Pin: NSManagedObject, MKAnnotation {
    var isDownloading = false
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2DMake(latitude, longitude)
        }
        set {
            self.latitude = newValue.latitude
            self.longitude = newValue.longitude
        }
    }
}
