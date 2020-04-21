//
//  TeamViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/17/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class TeamDetailViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var rosterSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var teamPageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rosterTableView: UITableView!
    
    var teamInfo: TeamInfo!
    var playerInfo: Players!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTableView.delegate = self
        rosterTableView.dataSource = self
        
        if teamInfo == nil{
            teamInfo = TeamInfo(Key: "", City: "", Name: "", StadiumID: -1, Conference: "", Division: "", PrimaryColor: "",
                                SecondaryColor: "", WikipediaLogoUrl: "")
        }
        
        
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        rosterSortSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        teamPageSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        
        let teamPrimaryColor = UIColor(hexCode: teamInfo.PrimaryColor)
        let teamSecondaryColor = UIColor(hexCode: teamInfo.SecondaryColor)
        self.navigationController?.navigationBar.barTintColor = teamPrimaryColor
        self.navigationController?.toolbar.barTintColor = teamPrimaryColor
        rosterSortSegmentedControl.backgroundColor = teamPrimaryColor
        rosterSortSegmentedControl.selectedSegmentTintColor = teamSecondaryColor
        teamPageSegmentedControl.selectedSegmentTintColor = teamSecondaryColor
        teamPageSegmentedControl.backgroundColor = teamPrimaryColor
        if teamInfo.Name == "Nets"{
            rosterSortSegmentedControl.selectedSegmentTintColor = UIColor.gray
            teamPageSegmentedControl.selectedSegmentTintColor = UIColor.gray
        }
        teamNameLabel.text = "\(teamInfo.City) \(teamInfo.Name)"
        let logoOriginalImageName = teamInfo.WikipediaLogoUrl
        var modifiedImageFileName = (logoOriginalImageName.suffix(from: logoOriginalImageName.lastIndex(of: "/")!))
        modifiedImageFileName.removeFirst()
        logoImageView.image = UIImage(named: String(modifiedImageFileName))
        //var playerInfo = Players(teamKey: teamInfo.Key)
        
        updateUserInterface()
        
    }
    
    func updateUserInterface(){
        playerInfo.getData {
            DispatchQueue.main.async{
                self.rosterTableView.reloadData()
            }
            for player in self.playerInfo.playerArray{
                print("\(player.FirstName) \(player.LastName): \(player.Jersey), \(player.Position)")
            }
        }
    }

}

extension TeamDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playerInfo.playerArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = rosterTableView.dequeueReusableCell(withIdentifier: "RosterCell", for: indexPath) as! RosterTableViewCell
        if let imageURL = URL(string: playerInfo.playerArray[indexPath.row].PhotoUrl){
            cell.playerImageView.load(url: imageURL)
        }else{
            cell.playerImageView.image = UIImage()
        }
        cell.playerNameLabel.text = "\(playerInfo.playerArray[indexPath.row].FirstName) \(playerInfo.playerArray[indexPath.row].LastName)"
        cell.playerNumberLabel.text = String(playerInfo.playerArray[indexPath.row].Jersey)
        cell.playerPositionLabel.text = playerInfo.playerArray[indexPath.row].Position
        
        return cell
    }
    
    
}
