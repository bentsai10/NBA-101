//
//  PlayerPhotos.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/26/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import Foundation
import Firebase

class PlayerPhotos{
    var photoArray: [PlayerPhoto] = []
    var db: Firestore
    
    init(){
        db = Firestore.firestore()
    }
    
    func loadData(team: FavoriteTeam, player: Player, completed: @escaping() -> ()){
        guard team.documentID != "" else{
            return
        }
        guard player.documentID != "" else{
            return
        }
        let storage = Storage.storage()
        db.collection("faveTeam").document(team.documentID).collection("roster").document(player.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("Error: adding the snapshot listener")
                return completed()
            }
            self.photoArray = []
            let storageRef = storage.reference().child(team.documentID).child(player.documentID)
            var loadAttempts = 0
            print(querySnapshot!.documents)
            for document in querySnapshot!.documents{
                let photo = PlayerPhoto(dictionary: document.data())
                photo.documentUUID = document.documentID
                self.photoArray.append(photo)
                
                let photoRef = storageRef.child(photo.documentUUID)
                photoRef.getData(maxSize: 25 * 1025 * 1025){ data, error in
                    if let error = error{
                        print("error occurred while reading data from file ref")
                        loadAttempts += 1
                        if loadAttempts >= (querySnapshot!.count){
                            return completed()
                        }
                    }else{
                        let image = UIImage(data: data!)
                        photo.image = image!
                        loadAttempts += 1
                        if loadAttempts >= (querySnapshot!.count){
                            return completed()
                        }
                    }
                }
            }
        }
        print(self.photoArray.count)
    }
}
