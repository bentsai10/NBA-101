//
//  StandingsInfo.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

struct StandingsInfo: Codable{
    var City: String
    var Conference: String
    var Name: String
    var Wins: Int
    var Losses: Int
    var GamesBack: Double
}
