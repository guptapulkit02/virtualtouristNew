//
//  Pin+CoreDataProperties.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData


extension Pin {

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var numPages: NSNumber?
    @NSManaged public var photos: [Photo]

}


