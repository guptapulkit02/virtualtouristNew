//
//  MapRegion+CoreDataClass.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData
import MapKit
import UIKit

public class MapRegion: NSManagedObject {
    
    override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        
        super.init(entity: entity, insertInto: context)
    }
    
    init(region: MKCoordinateRegion, context: NSManagedObjectContext) {
        
        let entity = NSEntityDescription.entity(forEntityName: "MapRegion", in: context)!
        super.init(entity: entity, insertInto: context)
        
        self.region = region
    }
    
    var region: MKCoordinateRegion {
        set {
            centerLatitude = newValue.center.latitude
            centerLongitude = newValue.center.longitude
            spanLatitude = newValue.span.latitudeDelta
            spanLongitude = newValue.span.longitudeDelta
        }
        get {
            let center = CLLocationCoordinate2DMake(centerLatitude, centerLongitude)
            let span = MKCoordinateSpanMake(spanLatitude, spanLongitude)
            return MKCoordinateRegionMake(center, span)
        }
    }

}
