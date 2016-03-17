//
//  ParkingSpotAnnotation.swift
//  Wheelz
//
//  Created by Benson Huynh & Dave Hurley on 2016-02-09.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

import Foundation
import MapKit

class ParkSpotAnnotation: NSObject, MKAnnotation {
   
    let title: String?
    var coordinate: CLLocationCoordinate2D
    var address: String
    var subtitle: String?

    
    init(coordinate: CLLocationCoordinate2D, address: String, title: String) {
        self.coordinate = coordinate
        self.address = address
        self.title = title
    }
    
    init(coordinate: CLLocationCoordinate2D, address: String, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.address = address
        self.title = title
        self.subtitle = subtitle
    }
}
