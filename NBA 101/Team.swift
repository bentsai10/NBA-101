//
//  Team.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/25/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Team{
    var TeamID: Int
    var Key: String
    var City: String
    var Name: String
    var StadiumID: Int
    var PrimaryColor: String
    var SecondaryColor: String
    var WikipediaLogoUrl: String
    var postingUserID: String
    var documentID: String
    
    var dictionary: [String: Any]{
        return ["TeamID": TeamID, "Key": Key, "City": City, "Name" : Name, "StadiumID": StadiumID, "PrimaryColor": PrimaryColor, "SecondaryColor":SecondaryColor, "WikipediaLogoURL": WikipediaLogoUrl, "postingUserID": postingUserID]
    }
    
    init(TeamID: Int, Key: String, City: String, Name: String, StadiumID: Int, PrimaryColor: String, SecondaryColor: String, WikipediaLogoURL: String, postingUserID: String, documentID: String){
        self.TeamID = TeamID
        self.Key = Key
        self.City = City
        self.Name = Name
        self.StadiumID = StadiumID
        self.PrimaryColor = PrimaryColor
        self.SecondaryColor = SecondaryColor
        self.WikipediaLogoUrl = WikipediaLogoURL
        self.postingUserID = postingUserID
        self.documentID = documentID
    }
    convenience init() {
        self.init(TeamID: 0, Key: "", City: "", Name: "", StadiumID: 0, PrimaryColor: "", SecondaryColor: "", WikipediaLogoURL: "", postingUserID: "", documentID: "")
    }
    convenience init(dictionary: [String:Any]) {
        let TeamID = dictionary["TeamID"] as! Int? ?? 0
        let Key = dictionary["Key"] as! String? ?? ""
        let City = dictionary["City"] as! String? ?? ""
        let Name = dictionary["Name"] as! String? ?? ""
        let StadiumID = dictionary["StadiumID"] as! Int? ?? 0
        let PrimaryColor = dictionary["PrimaryColor"] as! String? ?? ""
        let SecondaryColor = dictionary["SecondaryColor"] as! String? ?? ""
        let WikipediaLogoURL = dictionary["WikipediaLogoURL"] as! String? ?? ""
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(TeamID: TeamID, Key: Key, City: City, Name: Name, StadiumID: StadiumID, PrimaryColor: PrimaryColor, SecondaryColor: SecondaryColor, WikipediaLogoURL: WikipediaLogoURL, postingUserID: postingUserID, documentID: "")
    }
    
    func saveData(completed: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        guard let postingUserID = (Auth.auth().currentUser?.uid) else{
            print("Could not save data b/c no valid postingUserID")
            return completed(false)
        }
        self.postingUserID = postingUserID
        
        let dataToSave = self.dictionary
        
        if self.documentID != "" {
            let ref = db.collection("allTeams").document(self.documentID)
            ref.setData(dataToSave){ (error) in
                if let error = error {
                    print("ERROR: updating document \(self.documentID)\(error.localizedDescription)")
                    completed(false)
                }else {
                    print("Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
            
        }else {
            var ref: DocumentReference? = nil //let firestore create the new documentID
            ref = db.collection("allTeams").addDocument(data: dataToSave) {error in
               if let error = error {
                    print("ERROR: creating new document \(self.documentID)\(error.localizedDescription)")
                    completed(false)
                }else {
                print("new document created with ref ID \(ref?.documentID ?? "unknown")")
                    completed(true)
                }
            }
        }
    }
    
}
