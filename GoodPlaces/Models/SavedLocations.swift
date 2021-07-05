//
//  SavedLocations.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/3/21.
//

import UIKit
import CoreLocation //Xcode default module

struct SavedLocations {
    var latitude: CLLocationDegrees
    var longtitude: CLLocationDegrees
    var altitude: CLLocationDistance
    var title: String
    var time: String //manually change the time to String for easy access
    
    init(dictionary: [String: Any]) {
        self.title = dictionary["title"] as? String ?? "no title"
        self.latitude = dictionary["latitude"] as? CLLocationDegrees ?? 0
        self.longtitude = dictionary["longitude"] as? CLLocationDegrees ?? 0
        self.altitude = dictionary["altitude"] as? CLLocationDistance ?? 0
        self.time = dictionary["timestamp"] as? String ?? "no time"
        
    }
    
    
}
