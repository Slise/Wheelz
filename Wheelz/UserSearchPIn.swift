//
//  UserSearchPIn.swift
//  Wheelz
//
//  Created by Benson Huynh on 2016-02-11.
//  Copyright © 2016 Benson Huynh. All rights reserved.
//

import Foundation
import MapKit

class UserSearchPin: NSObject, MKAnnotation {
    
    let title: String?
    var coordinate: CLLocationCoordinate2D
    var address: String
    
    
    init(coordinate: CLLocationCoordinate2D, address: String, title: String) {
        self.coordinate = coordinate
        self.address = address
        self.title = title
    }
}
