//
//  LocationAnnotation.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/3/21.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    dynamic var coordinate: CLLocationCoordinate2D //make this "dynamic" so that the driver's annotation moves around on the map
    //var locationTitle: String
    
    init(locaTitle: String? = nil, coordinateLoca: CLLocationCoordinate2D) {
        //self.locationTitle = locaTitle
        self.coordinate = coordinateLoca
    }
    
    
}

