//
//  SelectedAnno.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/8/21.
//

import UIKit
import MapKit

struct SelectedAnno: Equatable {
    let lat: CLLocationDegrees
    let long: CLLocationDegrees
    let title: String?
}
