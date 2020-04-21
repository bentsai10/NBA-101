//
//  Arenas.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/20/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class Arenas{
    var url: String = "https://api.sportsdata.io/v3/nba/scores/json/Stadiums?key=\(APIKeys.sportsDataNBAKey)"
    var arenaArray: [ArenaInfo] = []
    
    private struct Returned: Codable {
        var StadiumID: Int
        var Name: String
        var City: String
        var State: String
        var Zip: String
        var Capacity: Int
        var GeoLat: Double
        var GeoLong: Double
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
                let returned = try JSONDecoder().decode([ArenaInfo].self, from: data!)
                self.arenaArray = self.arenaArray + returned
            }catch{
                print("error yeet")
            }
            completed()
        }
        task.resume()
    }
    
    
}

