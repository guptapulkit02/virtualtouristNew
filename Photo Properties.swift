//
//  Photo+CoreDataProperties.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @NSManaged public var imagePath: String?
    @NSManaged public var imageData: NSData
    @NSManaged public var photoURL: String
    @NSManaged public var pin: Pin

}
