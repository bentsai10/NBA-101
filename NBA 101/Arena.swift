//
//  File.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/21/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import MapKit

class Arena: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    
    var Name: String
    var Address: String?
    
    init(Name: String, Address: String?, Coordinate: CLLocationCoordinate2D) {
        self.Name = Name
        self.Address = Address
        self.coordinate = Coordinate
    }
    
    var title: String?{
        return Name
    }
    var subtitle: String?{
        return Address
    }
    
    
}

