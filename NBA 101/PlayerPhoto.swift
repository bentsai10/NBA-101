//
//  PlayerPhoto.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/26/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import Foundation
import Firebase

class PlayerPhoto{
    var image: UIImage
    var description: String
    var postedBy: String
    var date:Date
    var documentUUID: String
    var dictionary: [String: Any]{
        return ["description": description, "postedBy": postedBy, "date": date ]
    }
    
    init(image: UIImage, description: String, postedBy: String, date: Date, documentUUID: String){
        self.image = image
        self.description = description
        self.postedBy = postedBy
        self.date = date
        self.documentUUID = documentUUID
    }
    
    convenience init() {
        let postedBy = Auth.auth().currentUser?.email ?? "unknown user"
        self.init(image: UIImage(), description: "", postedBy: postedBy, date: Date(), documentUUID:"")
    }
    convenience init(dictionary: [String:Any]) {
        let description = dictionary["description"] as! String? ?? ""
        let postedBy = dictionary["postedBy"] as! String? ?? ""
        let date = dictionary["date"] as! Date ?? Date()
        self.init(image:UIImage(), description: description, postedBy: postedBy, date: date, documentUUID: "")
    }
    
    func saveData(team: FavoriteTeam, player:Player, completed: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        //create the dictionary representing the data we want to save
        guard let photoData = self.image.jpegData(compressionQuality: 0.5)else{
            print("Error: could not convert image to data format")
            return completed(false)
        }
        documentUUID = UUID().uuidString
        
        let storageRef = storage.reference().child(team.documentID).child(player.documentID).child(self.documentUUID)
        let uploadTask = storageRef.putData(photoData)
        
        uploadTask.observe(.success){(snapshot) in
            let dataToSave = self.dictionary
            let ref = db.collection("faveTeams").document(team.documentID).collection("roster").document(player.documentID).collection("photos").document(self.documentUUID)
            ref.setData(dataToSave){ (error) in
                if let error = error {
                    print("ERROR: updating document \(self.documentUUID)\(error.localizedDescription)")
                    completed(false)
                }else {
                    print("Document updated with ref ID \(ref.documentID)")
                    completed(true)
                }
            }
        }
        uploadTask.observe(.failure){(snapshot) in
            if let error = snapshot.error{
                print("upload task for photo file failed")
            }
            return completed(false)
        }
        
        
        //if we have saved a record, we'll have a documentID
        
    }
}
