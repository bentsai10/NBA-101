//
//  ScheduleInfo.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/22/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

struct ScheduleInfo: Codable{
    var Season: Int?
    var Status: String?
    var DateTime: String?
    var AwayTeamID: Int?
    var HomeTeamID: Int?
    var StadiumID: Int?
    var AwayTeamScore: Int?
    var HomeTeamScore: Int?
}
