//
//  ArenaInfo.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import MapKit

struct ArenaInfo: Codable{
    var StadiumID: Int
    var Name: String
    var Address: String?
    var City: String
    var State: String?
    var GeoLat: Double?
    var GeoLong: Double?
}
