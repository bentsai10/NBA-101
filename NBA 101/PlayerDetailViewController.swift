//
//  PlayerDetailViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/21/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class PlayerDetailViewController: UIViewController {
    @IBOutlet weak var playerImageView: UIImageView!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var teamImageView: UIImageView!
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerPositionLabel: UILabel!
    @IBOutlet weak var playerHeightLabel: UILabel!
    @IBOutlet weak var playerWeightLabel: UILabel!
    @IBOutlet weak var playerExperienceLabel: UILabel!
    @IBOutlet weak var playerSalaryLabel: UILabel!
    @IBOutlet weak var playerBirthdayLabel: UILabel!
    @IBOutlet weak var playerHometownLabel: UILabel!
    @IBOutlet weak var playerCollegeLabel: UILabel!
    @IBOutlet weak var playerPhotoCollectionView: UICollectionView!
    @IBOutlet weak var playerStatsSegmentedControl: UISegmentedControl!
    @IBOutlet weak var playerStatsTableView: UITableView!
    
    var player: PlayerInfo!
    var team: TeamInfo!
    var statsInfo: Statistics!
    var playerStats = StatisticsInfo(PlayerID: 0, Games: 0, Rebounds: 0.0, Assists: 0.0, Steals: 0.0, Points: 0.0, BlockedShots: 0.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if player == nil{
            player = PlayerInfo(PlayerID: 0,Team: "", Jersey: -1, Position: "", FirstName: "", LastName: "", Height: -1, Weight: -1, BirthDate: nil, BirthCity: nil, BirthState: nil, College: nil, Salary: nil, PhotoUrl: "", Experience: -1)
        }
        if team == nil{
            team = TeamInfo(TeamID: -1, Key: "", City: "", Name: "", StadiumID: -1, PrimaryColor: "", SecondaryColor: "", WikipediaLogoUrl: "")
        }
        
        playerStatsTableView.delegate = self
        playerStatsTableView.dataSource = self

        statsInfo.getData {
            DispatchQueue.main.async {
                for playerStats in self.statsInfo.statsArray{
                    if playerStats.PlayerID == self.player.PlayerID{
                        self.playerStats = playerStats
                        break
                    }
                }
                self.playerStatsTableView.reloadData()
            }
        }
        updateUserInterface()
    }
    
    func updateUserInterface(){
        let teamPrimaryColor = UIColor(hexCode: team.PrimaryColor)
        let teamSecondaryColor = UIColor(hexCode: team.SecondaryColor)
        playerStatsSegmentedControl.backgroundColor = teamPrimaryColor
        playerStatsSegmentedControl.selectedSegmentTintColor = teamSecondaryColor
        let logoOriginalImageName = team.WikipediaLogoUrl
        var modifiedImageFileName = (logoOriginalImageName.suffix(from: logoOriginalImageName.lastIndex(of: "/")!))
        modifiedImageFileName.removeFirst()
        teamImageView.image = UIImage(named: String(modifiedImageFileName))
        if let imageURL = URL(string: player.PhotoUrl){
                playerImageView.load(url: imageURL)
            }else{
                playerImageView.image = UIImage()
        }
        playerNameLabel.text = "\(player.FirstName) \(player.LastName)"
        playerNumberLabel.text = "#\(String(player.Jersey))"
        playerPositionLabel.text = player.Position
        playerHeightLabel.text = "\(player.Height / 12)'\(player.Height % 12)"
        playerWeightLabel.text = "\(player.Weight)"
        playerExperienceLabel.text = "\(player.Experience)"
        var salaryString = ""
        if player.Salary == nil{
            salaryString = "N/A"
        }else{
            salaryString = formatSalary(salary: player.Salary!)
        }
        playerSalaryLabel.text = salaryString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let date = player.BirthDate ?? "0000-01-01T00:00:00"
        if date == "0000-01-01T00:00:00"{
            playerBirthdayLabel.text = "N/A"
        }else{
            let updatedDate = dateFormatter.date(from: date)
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let bdayString = dateFormatter.string(from: updatedDate!)
            playerBirthdayLabel.text = bdayString
        }
        if player.BirthCity == nil && player.BirthState == nil{
            playerHometownLabel.text = "N/A"
        }else{
            if player.BirthCity == nil{
                playerHometownLabel.text = "\(player.BirthState!)"
            }else if player.BirthState == nil{
                playerHometownLabel.text = "\(player.BirthCity!)"
            }else{
                playerHometownLabel.text = "\(player.BirthCity!), \(player.BirthState!)"
            }
        }
        if player.College == nil{
            playerCollegeLabel.text = "N/A"
        }else{
            playerCollegeLabel.text = player.College!
        }
    }
    func formatSalary(salary: Int) -> String{
        var millions = salary/1000000
        var thousands = (salary-(millions*1000000))/1000
        var ones = salary-(millions*1000000)-(thousands*1000)
        if millions == 0{
            return "\(thousands),\(ones)"
        }else{
            return "\(millions),\(thousands),\(ones)"
        }
    }
}

extension PlayerDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerStatsTableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatisticsTableViewCell
        if playerStats.Points == 0.0{
            cell.pointsPerGameLabel.text = "Loading..."
            cell.assistsPerGameLabel.text = ""
            cell.reboundsPerGameLabel.text = ""
            cell.stealsPerGameLabel.text = ""
            cell.blocksPerGameLabel.text = ""
        }else{
            let points = ((playerStats.Points/Double(playerStats.Games))*10).rounded()/10
            let assists = ((playerStats.Assists/Double(playerStats.Games))*10).rounded()/10
            let rebounds = ((playerStats.Rebounds/Double(playerStats.Games))*10).rounded()/10
            let steals = ((playerStats.Steals/Double(playerStats.Games))*10).rounded()/10
            let blocks = ((playerStats.BlockedShots/Double(playerStats.Games))*10).rounded()/10
            cell.pointsPerGameLabel.text = "\(points)"
            cell.assistsPerGameLabel.text = "\(assists)"
            cell.reboundsPerGameLabel.text = "\(rebounds)"
            cell.stealsPerGameLabel.text = "\(steals)"
            cell.blocksPerGameLabel.text = "\(blocks)"
        }
        return cell
    }
}
