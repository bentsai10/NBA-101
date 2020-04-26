//
//  Statistics.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/24/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import Foundation
import UIKit

class Statistics{
    var seasonKey:String = ""
    var url: String = "https://api.sportsdata.io/v3/nba/stats/json/PlayerSeasonStats/2020?key=\(APIKeys.sportsDataNBAKey)"
    var statsArray: [StatisticsInfo] = []
    
    init(seasonKey: String){
        self.seasonKey = seasonKey
        self.url = "https://api.sportsdata.io/v3/nba/stats/json/PlayerSeasonStats/\(seasonKey)?key=\(APIKeys.sportsDataNBAKey)"
        self.statsArray = []
    }
    
    private struct Returned: Codable {
        var PlayerID: Int
        var Games: Int
        var Rebounds: Double
        var Assists: Double
        var Steals: Double
        var Points: Double
        var BlockedShots: Double
    }
    
    func getData(completed: @escaping ()->()){
        let urlString = url
        guard let url = URL(string: urlString)else{
            print("Error")
            completed()
            return
        }
        let session = URLSession.shared
        
        let task = session.dataTask(with: url){(data, response, error)in
            if let error = error{
                print("error")
            }
            do{
                let returned = try JSONDecoder().decode([StatisticsInfo].self, from: data!)
                self.statsArray = self.statsArray + returned

            }catch{
                print("error getting stats")
            }
            completed()
        }
        task.resume()
    }
    
    
}
