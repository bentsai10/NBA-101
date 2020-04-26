//
//  Schedules.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/22/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import Foundation
import UIKit

class Schedules{
    var seasonKey:String = ""
    var url: String = "https://api.sportsdata.io/v3/nba/scores/json/Standings/2020?key=\(APIKeys.sportsDataNBAKey)"
    var schedulesArray: [ScheduleInfo] = []
    
    init(seasonKey: String){
        self.seasonKey = seasonKey
        self.url = "https://api.sportsdata.io/v3/nba/scores/json/Games/\(seasonKey)?key=\(APIKeys.sportsDataNBAKey)"
        self.schedulesArray = []
    }
    
    private struct Returned: Codable {
        var Season: Int?
        var Status: String?
        var DateTime: String?
        var AwayTeamID: Int?
        var HomeTeamID: Int?
        var StadiumID: Int?
        var AwayTeamScore: Int?
        var HomeTeamScore: Int?
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
                let returned = try JSONDecoder().decode([ScheduleInfo].self, from: data!)
                self.schedulesArray = self.schedulesArray + returned

            }catch{
                print("error getting schedules")
            }
            completed()
        }
        task.resume()
    }
    
    
}
