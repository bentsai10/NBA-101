//
//  TeamData.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/19/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class FavoriteTeams{
    var url: String = "https://api.sportsdata.io/v3/nba/scores/json/teams?key=\(APIKeys.sportsDataNBAKey)"
    var teamArray: [TeamInfo] = []
    var faveTeamArray = [FavoriteTeam]() //why do we have to initialize it
    var db: Firestore!
    
    private struct Returned: Codable {
        var TeamID: Int
        var Key: String
        var City: String
        var Name: String
        var StadiumID: Int
        var PrimaryColor: String
        var SecondaryColor: String
        var WikipediaLogoUrl: String
    }
    
    init() {
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping ()->()){
        db.collection("faveTeams").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("***ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.faveTeamArray = []
            //there are questSnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let faveTeam = FavoriteTeam(dictionary: document.data())
                faveTeam.documentID = document.documentID
                self.faveTeamArray.append(faveTeam)
            }
            completed()
        }
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
                let returned = try JSONDecoder().decode([TeamInfo].self, from: data!)
                self.teamArray = self.teamArray + returned
            }catch{
                print("error getting teams")
            }
            completed()
        }
        task.resume()
    }
    
    
}
