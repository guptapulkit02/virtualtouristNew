//
//  MapRegion+CoreDataProperties.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData


extension MapRegion {

    @NSManaged public var centerLatitude: Double
    @NSManaged public var centerLongitude: Double
    @NSManaged public var spanLatitude: Double
    @NSManaged public var spanLongitude: Double

}
