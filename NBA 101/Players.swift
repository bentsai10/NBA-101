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

class Players{
    var teamKey:String = ""
    var url: String = "https://api.sportsdata.io/v3/nba/stats/json/Players/ATL?key=\(APIKeys.sportsDataNBAKey)"
    var playerArray: [PlayerInfo] = []
    var hooperArray: [Player] = []
    var db: Firestore!
    
     init(teamKey: String){
        db = Firestore.firestore()
        self.teamKey = teamKey
        self.url = "https://api.sportsdata.io/v3/nba/stats/json/Players/\(teamKey)?key=\(APIKeys.sportsDataNBAKey)"
        self.playerArray = []
    }
    
    private struct Returned: Codable {
        var PlayerID: Int
        var Team: String
        var Jersey: Int
        var Position: String
        var FirstName: String
        var LastName: String
        var Height: Int
        var Weight: Int
        var BirthDate: String?
        var BirthCity: String?
        var BirthState: String?
        var College: String?
        var Salary: Int?
        var PhotoUrl: String
        var Experience: Int
        
    }
    init() {
           db = Firestore.firestore()
       }
       
    func loadFaveData(favoriteTeam: FavoriteTeam, completed: @escaping ()->()){
        guard favoriteTeam.documentID != "" else{
            return
        }
       db.collection("faveTeams").document(favoriteTeam.documentID).collection("roster").addSnapshotListener { (querySnapshot, error) in
          guard error == nil else {
              print("***ERROR: adding the snapshot listener \(error!.localizedDescription)")
              return completed()
          }
          self.hooperArray = []
          //there are questSnapshot!.documents.count documents in the spots snapshot
          for document in querySnapshot!.documents {
              let player = Player(dictionary: document.data())
              player.documentID = document.documentID
              self.hooperArray.append(player)
          }
          completed()
      }
       }
    /*func loadAllData(team: Team, completed: @escaping ()->()){
        guard team.documentID != "" else{
            return
        }
        db.collection("allTeams").document(team.documentID).collection("roster").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else {
                print("***ERROR: adding the snapshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.hooperArray = []
            //there are questSnapshot!.documents.count documents in the spots snapshot
            for document in querySnapshot!.documents {
                let player = Player(dictionary: document.data())
                player.documentID = document.documentID
                self.hooperArray.append(player)
            }
            completed()
        }
    }*/

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
                print("error getting players")
            }
            completed()
        }
        task.resume()
    }
    
    
}
