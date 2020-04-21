//
//  PlayerInfo.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

struct PlayerInfo: Codable{
    var Team: String
    var Jersey: Int
    var Position: String
    var FirstName: String
    var LastName: String
    var Height: Int
    var Weight: Int
    //var BirthDate: Date
    //var BirthCity: String
    //var BirthState: String
    //var College: String
    //var Salary: Int
    var PhotoUrl: String
    var Experience: Int
}
