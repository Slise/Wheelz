//
//  ParkingSpotAnnotation.swift
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-09.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

import Foundation
import MapKit

class ParkSpotAnnotation: NSObject, MKAnnotation {
   
    let coordinate: CLLocationCoordinate2D
    let address: String
    let title: String?
    
    init(coordinate: CLLocationCoordinate2D, address: String, title: String) {
        self.coordinate = coordinate
        self.address = address
        self.title = title
    }
}
