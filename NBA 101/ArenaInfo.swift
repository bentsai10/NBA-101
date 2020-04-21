//
//  ArenaInfo.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

struct ArenaInfo: Codable{
    var StadiumID: Int
    var Name: String
    var City: String
    var State: String
    var Zip: String
    var Capacity: Int
    var GeoLat: Double
    var GeoLong: Double
}
