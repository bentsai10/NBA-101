//
//  AddTeamTableViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/26/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class AddTeamTableViewController: UITableViewController {
    
    var teams: AllTeams!
    var favoritedTeams = [Bool]()
    var previousFaves = [FavoriteTeam]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //tableView.register(AddTeamTableViewCell.self, forCellReuseIdentifier: "AddTeamCell")

        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for team in teams.teamArray{
            favoritedTeams.append(false)
        }
        for index in 0...29{
            for team in previousFaves{
                if teams.teamArray[index].Name == team.Name{
                    favoritedTeams[index] = true
                }
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func editFavoriteTeams(cell: AddTeamTableViewCell){
        let indexPathClicked = tableView.indexPath(for: cell)
        favoritedTeams[indexPathClicked!.row] = !(favoritedTeams[indexPathClicked!.row])
        favoritedTeams[indexPathClicked!.row] ? cell.favoriteButton.setImage(UIImage(named: "star-filled"), for: .normal) : cell.favoriteButton.setImage(UIImage(named: "star-empty"), for: .normal)
    }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination as! ViewController
        for i in 0..<favoritedTeams.count{
            var dataSaved = false
            if favoritedTeams[i]{
                for team in previousFaves{
                    if teams.teamArray[i].Name == team.Name{
                        dataSaved = true
                        team.saveData { success in
                            if success {
                                
                            }else {
                                print("***ERROR: Couldn't leave this view controller because data wasn't saved")
                            }
                        }
                        break
                    }
                }
                if dataSaved{
                        
                }else{
                    let team = FavoriteTeam(TeamID: teams.teamArray[i].TeamID, Key: teams.teamArray[i].Key, City: teams.teamArray[i].City, Name: teams.teamArray[i].Name, StadiumID: teams.teamArray[i].StadiumID, PrimaryColor: teams.teamArray[i].PrimaryColor, SecondaryColor: teams.teamArray[i].SecondaryColor, WikipediaLogoURL: teams.teamArray[i].WikipediaLogoUrl, postingUserID: "" , documentID: "")
                    team.saveData { success in
                        if success {
                        }else {
                            print("***ERROR: Couldn't leave this view controller because data wasn't saved")
                        }
                    }
                }
            }else{
                for team in previousFaves{
                    if team.Name == teams.teamArray[i].Name{
                        team.deleteData { (success) in
                        }
                    }
                }
            }
        }
        
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 30
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddTeamCell", for: indexPath) as! AddTeamTableViewCell
        cell.link = self
        if teams.teamArray.count > 0{
            cell.teamNameLabel.text = teams.teamArray[indexPath.row].Name
            let logoOriginalImageName = teams.teamArray[indexPath.row].WikipediaLogoUrl
            var modifiedImageFileName = (logoOriginalImageName.suffix(from: logoOriginalImageName.lastIndex(of: "/")!))
            modifiedImageFileName.removeFirst()
            cell.logoImageView.image = UIImage(named: String(modifiedImageFileName))
            favoritedTeams[indexPath.row] ? cell.favoriteButton.setImage(UIImage(named: "star-filled"), for: .normal) : cell.favoriteButton.setImage(UIImage(named: "star-empty"), for: .normal)
        }
        return cell
    }
}
