//
//  TeamData.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/19/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import Foundation

class Players{
    var teamKey:String = ""
    var url: String = "https://api.sportsdata.io/v3/nba/stats/json/Players/ATL?key=\(APIKeys.sportsDataNBAKey)"
    var playerArray: [PlayerInfo] = []
    
     init(teamKey: String){
        self.teamKey = teamKey
        self.url = "https://api.sportsdata.io/v3/nba/stats/json/Players/\(teamKey)?key=\(APIKeys.sportsDataNBAKey)"
        self.playerArray = []
    }
    
    private struct Returned: Codable {
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
        var College: String
        var Salary: Int
        var PhotoUrl: String
        var Experience: Int
        
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
                let returned = try JSONDecoder().decode([PlayerInfo].self, from: data!)
                self.playerArray = self.playerArray + returned
            }catch{
                print("error")
            }
            completed()
        }
        task.resume()
    }
    
    
}
