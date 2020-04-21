//
//  TeamViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/17/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import MapKit

class TeamDetailViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var rosterSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var standingsSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var teamPageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rosterTableView: UITableView!
    @IBOutlet weak var standingsTableView: UITableView!
    @IBOutlet weak var arenaStackView: UIStackView!
    @IBOutlet weak var arenaImageView: UIImageView!
    @IBOutlet weak var arenaNameLabel: UILabel!
    @IBOutlet weak var arenaCapacityLabel: UILabel!
    @IBOutlet weak var arenaAddressLabel: UILabel!
    @IBOutlet weak var arenaCityLabel: UILabel!
    @IBOutlet weak var arenaMapView: MKMapView!
    
    var teamInfo: TeamInfo!
    var playerInfo: Players!
    var standingsInfo: Standings!
    var arenaInfo = Arenas()
    var teamsByConference = [[StandingsInfo(City: "", Conference: "", Name: "", Wins: 0, Losses: 0, GamesBack: 0.0)], [StandingsInfo(City: "", Conference: "", Name: "", Wins: 0, Losses: 0, GamesBack: 0.0)]]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        rosterTableView.delegate = self
        rosterTableView.dataSource = self
        standingsTableView.delegate = self
        standingsTableView.dataSource = self
        
        rosterTableView.sectionHeaderHeight = 0
        standingsTableView.sectionHeaderHeight = 70
        standingsTableView.register(CustomScheduleHeader.self, forHeaderFooterViewReuseIdentifier: "StandingsHeader")
        
        if teamInfo == nil{
            teamInfo = TeamInfo(Key: "", City: "", Name: "", StadiumID: -1, Conference: "", Division: "", PrimaryColor: "",SecondaryColor: "", WikipediaLogoUrl: "")
        }
        updateUserInterface()
    }
    
    func updateUserInterface(){
        /*
         Changing UI on TeamDetail page to match team color scheme
         */
        let titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        rosterSortSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        teamPageSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        standingsSortSegmentedControl.setTitleTextAttributes(titleTextAttributes, for: .normal)
        let teamPrimaryColor = UIColor(hexCode: teamInfo.PrimaryColor)
        let teamSecondaryColor = UIColor(hexCode: teamInfo.SecondaryColor)
        self.navigationController?.navigationBar.barTintColor = teamPrimaryColor
        self.navigationController?.toolbar.barTintColor = teamPrimaryColor
        rosterSortSegmentedControl.backgroundColor = teamPrimaryColor
        rosterSortSegmentedControl.selectedSegmentTintColor = teamSecondaryColor
        teamPageSegmentedControl.selectedSegmentTintColor = teamSecondaryColor
        teamPageSegmentedControl.backgroundColor = teamPrimaryColor
        standingsSortSegmentedControl.backgroundColor = teamPrimaryColor
        standingsSortSegmentedControl.selectedSegmentTintColor = teamSecondaryColor
        //Accounting for special case where team colors are black and white
        if teamInfo.Name == "Nets"{
            rosterSortSegmentedControl.selectedSegmentTintColor = UIColor.gray
            teamPageSegmentedControl.selectedSegmentTintColor = UIColor.gray
            standingsSortSegmentedControl.selectedSegmentTintColor = UIColor.gray
        }
        //Changing top image and text to match team
        teamNameLabel.text = "\(teamInfo.City) \(teamInfo.Name)"
        let logoOriginalImageName = teamInfo.WikipediaLogoUrl
        var modifiedImageFileName = (logoOriginalImageName.suffix(from: logoOriginalImageName.lastIndex(of: "/")!))
        modifiedImageFileName.removeFirst()
        logoImageView.image = UIImage(named: String(modifiedImageFileName))
        playerInfo.getData {
            DispatchQueue.main.async{
                self.playerInfo.playerArray.sort(by: {$0.LastName < $1.LastName})
                self.rosterTableView.reloadData()
            }
        }
        standingsInfo.getData {
            DispatchQueue.main.async {
                self.standingsInfo.standingsArray.sort(by: {$0.GamesBack < $1.GamesBack})
                for team in self.standingsInfo.standingsArray{
                    if team.Conference == "Eastern"{
                        self.teamsByConference[0].append(team)
                    }else{
                        self.teamsByConference[1].append(team)
                    }
                }
                self.teamsByConference[0].removeFirst()
                self.teamsByConference[1].removeFirst()
                self.standingsTableView.reloadData()
            }
        }
        arenaInfo.getData {
            print(self.arenaInfo.arenaArray)
        }
        
    }
    @IBAction func rosterSortSCPressed(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex{
        case 1:
            playerInfo.playerArray.sort(by: {$0.Jersey < $1.Jersey})
            DispatchQueue.main.async{
                self.rosterTableView.reloadData()
            }
            
        case 0, 2:
            playerInfo.playerArray.sort(by: {$0.LastName < $1.LastName})
            DispatchQueue.main.async{
                self.rosterTableView.reloadData()
            }
            
        case 3:
            playerInfo.playerArray.sort(by: {$0.Position < $1.Position})
            DispatchQueue.main.async{
                self.rosterTableView.reloadData()
            }
            
        default:
            print("You shouldn't have gotten here!")
        }
    }

    @IBAction func teamPageSCPressed(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            rosterTableView.isHidden = false
            rosterSortSegmentedControl.isHidden = false
            standingsTableView.isHidden = true
            standingsSortSegmentedControl.isHidden = true
            arenaStackView.isHidden = true
        case 1:
            rosterTableView.isHidden = true
            rosterSortSegmentedControl.isHidden = true
            standingsTableView.isHidden = false
            standingsSortSegmentedControl.isHidden = false
            arenaStackView.isHidden = true
        case 2:
            rosterTableView.isHidden = true
            rosterSortSegmentedControl.isHidden = true
            standingsTableView.isHidden = true
            standingsSortSegmentedControl.isHidden = true
            arenaStackView.isHidden = true
        case 3:
            rosterTableView.isHidden = true
            rosterSortSegmentedControl.isHidden = true
            standingsTableView.isHidden = true
            standingsSortSegmentedControl.isHidden = true
            arenaStackView.isHidden = false
        default:
            print("You shouldn't have gotten here!")
        }
    }
    
    

}

extension TeamDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.standingsTableView{
            return teamsByConference[0].count
        }else{
           return playerInfo.playerArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == self.rosterTableView{
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
        }else{
            let cell = standingsTableView.dequeueReusableCell(withIdentifier: "StandingsCell", for: indexPath) as! StandingsTableViewCell
            cell.teamNameLabel.text = teamsByConference[indexPath.section][indexPath.row].Name
            cell.teamWinsLabel.text = String(teamsByConference[indexPath.section][indexPath.row].Wins)
            cell.teamLossesLabel.text = String(teamsByConference[indexPath.section][indexPath.row].Losses)
            cell.teamGamesBackLabel.text = String(teamsByConference[indexPath.section][indexPath.row].GamesBack)
            let boldAttribute = [NSAttributedString.Key.font: UIFont(name: "Rockwell-Bold", size: 17.0)!]
            let regularAttribute = [NSAttributedString.Key.font: UIFont(name: "Rockwell", size: 17.0)!]
            if cell.teamNameLabel.text == self.teamInfo.Name{
                cell.teamNameLabel.attributedText = NSAttributedString(string: cell.teamNameLabel.text!, attributes: boldAttribute)
                cell.teamWinsLabel.attributedText = NSAttributedString(string: cell.teamWinsLabel.text!, attributes: boldAttribute)
                cell.teamLossesLabel.attributedText = NSAttributedString(string: cell.teamLossesLabel.text!, attributes: boldAttribute)
                cell.teamGamesBackLabel.attributedText = NSAttributedString(string: cell.teamGamesBackLabel.text!, attributes: boldAttribute)
            }else{
                cell.teamNameLabel.attributedText = NSAttributedString(string: cell.teamNameLabel.text!, attributes: regularAttribute)
                cell.teamWinsLabel.attributedText = NSAttributedString(string: cell.teamWinsLabel.text!, attributes: regularAttribute)
                cell.teamLossesLabel.attributedText = NSAttributedString(string: cell.teamLossesLabel.text!, attributes: regularAttribute)
                cell.teamGamesBackLabel.attributedText = NSAttributedString(string: cell.teamGamesBackLabel.text!, attributes: regularAttribute)
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.rosterTableView{
            return 85
        }else{
            return 60
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.standingsTableView{
            return 2
        }else{
            return 1
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == self.standingsTableView{
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier:
                        "StandingsHeader") as! CustomScheduleHeader
            let headers = ["Eastern Conference", "Western Conference"]
            view.title.text = headers[section]
            if view.title.text == headers[0]{
                view.assignTextColor(color: .blue)
            }else{
                view.assignTextColor(color: .red)
            }
            return view
        }else{
            return nil
        }
        
    }
    
}
