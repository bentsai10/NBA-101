//
//  Standings.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import Foundation
import UIKit

class Standings{
    var seasonKey:String = ""
    var url: String = "https://api.sportsdata.io/v3/nba/scores/json/Standings/2020?key=\(APIKeys.sportsDataNBAKey)"
    var standingsArray: [StandingsInfo] = []
    
    init(seasonKey: String){
        self.seasonKey = seasonKey
        self.url = "https://api.sportsdata.io/v3/nba/stats/json/Standings/\(seasonKey)?key=\(APIKeys.sportsDataNBAKey)"
        self.standingsArray = []
    }
    
    private struct Returned: Codable {
        var City: String
        var Conference: String
        var Name: String
        var Wins: Int
        var Losses: Int
        var GamesBack: Double
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
                let returned = try JSONDecoder().decode([StandingsInfo].self, from: data!)
                self.standingsArray = self.standingsArray + returned

            }catch{
                print("error")
            }
            completed()
        }
        task.resume()
    }
    
    
}
