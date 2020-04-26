//
//  Team.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/19/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

struct TeamInfo: Codable{
    var TeamID: Int
    var Key: String
    var City: String
    var Name: String
    var StadiumID: Int
    var PrimaryColor: String
    var SecondaryColor: String
    var WikipediaLogoUrl: String
}
