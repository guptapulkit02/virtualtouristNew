//
//  FlickrConstants.swift
//  VirtualTouristApp
//
//  Created by Pulkit  Gupta on 18/12/16.
//  Copyright © 2016 Pulkit  Gupta. All rights reserved.
//

import Foundation
extension FlickrClient {
    
    struct Constants {
        static let APIKey   = "0ead4a823691fa404a4cfb1eb8d68718"
        static let BASE_URL = "https://api.flickr.com/services/rest/"
        static let SEARCH = "flickr.photos.search"
        static let API_KEY          = "api_key"
        static let METHOD           = "method"
        static let SAFE_SEARCH      = "safe_search"
        static let EXTRAS           = "extras"
        static let FORMAT           = "format"
        static let NO_JSON_CALLBACK = "nojsoncallback"
        static let BBOX             = "bbox"
        static let PAGE             = "page"
        static let PER_PAGE         = "per_page"
        static let SORT             = "sort"
        static let JSON_FORMAT  = "json"
        static let URL_M        = "url_m"
        static let BOUNDING_BOX_HALF_WIDTH = 1.0
        static let BOUNDING_BOX_HALF_HEIGHT = 1.0
        static let LAT_MIN = -90.0
        static let LAT_MAX = 90.0
        static let LON_MIN = -180.0
        static let LON_MAX = 180.0
    }
}
