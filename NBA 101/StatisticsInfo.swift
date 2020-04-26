//
//  StatisticsInfo.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/24/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

struct StatisticsInfo: Codable{
    var PlayerID: Int
    var Games: Int
    var Rebounds: Double
    var Assists: Double
    var Steals: Double
    var Points: Double
    var BlockedShots: Double
}
