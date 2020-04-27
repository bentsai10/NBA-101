//
//  TeamViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/17/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import MapKit
import Firebase

class TeamDetailViewController: UIViewController {
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var rosterSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var standingsSortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var teamPageSegmentedControl: UISegmentedControl!
    @IBOutlet weak var rosterTableView: UITableView!
    @IBOutlet weak var standingsTableView: UITableView!
    @IBOutlet weak var arenaImageView: UIImageView!
    @IBOutlet weak var arenaNameLabel: UILabel!
    @IBOutlet weak var arenaCityLabel: UILabel!
    @IBOutlet weak var arenaMapView: MKMapView!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet var monthScrollButtonCollection: [UIButton]!
    @IBOutlet weak var noGamesLabel: UILabel!
    
    var teams: AllTeams!
    var teamInfo: FavoriteTeam!
    var playerInfo: Players!
    var standingsInfo: Standings!
    var arenaInfo = Arenas()
    var teamArena: ArenaInfo!
    var scheduleInfo: Schedules!
    var teamsByConference = [[StandingsInfo(Conference: "", Name: "", Wins: 0, Losses: 0, GamesBack: 0.0)], [StandingsInfo(Conference: "", Name: "", Wins: 0, Losses: 0, GamesBack: 0.0)]]
    let months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    var monthScrollIndex:Int = -1
    var year = ""
    var teamGames:[ScheduleInfo] = []
    let regionDistance: CLLocationDistance = 500
    var arenaLatitude: CLLocationDegrees = 0.0
    var arenaLongitude: CLLocationDegrees = 0.0
    var arenaCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var favorited = true
    var initialFaveCount: Int!
    var index: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rosterTableView.delegate = self
        rosterTableView.dataSource = self
        standingsTableView.delegate = self
        standingsTableView.dataSource = self
        scheduleTableView.dataSource = self
        scheduleTableView.delegate = self
        
        rosterTableView.sectionHeaderHeight = 0
        scheduleTableView.sectionHeaderHeight = 0
        standingsTableView.sectionHeaderHeight = 70
        standingsTableView.register(CustomScheduleHeader.self, forHeaderFooterViewReuseIdentifier: "StandingsHeader")
        
        if teamInfo == nil{
            teamInfo = FavoriteTeam()
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
        monthLabel.backgroundColor = teamPrimaryColor
        for button in monthScrollButtonCollection{
            button.setTitleColor(teamSecondaryColor, for: .normal)
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "LLLL yyyy"
        var month = dateFormatter.string(from: Date())
        monthLabel.text = month
        year = String(month.suffix(from: month.firstIndex(of: " ")!))
        year.removeFirst()
        month = String(month.prefix(upTo: month.firstIndex(of: " ")!))
        monthScrollIndex = months.firstIndex(of: month)!
        monthLabel.textColor = teamSecondaryColor
        /*playerInfo.loadFaveData(favoriteTeam: teamInfo) {
            
        }*/
        playerInfo.getData {
            if self.initialFaveCount == 0{
                self.initialFaveCount += 1
                for player in self.playerInfo.playerArray{
                    let playerToBeSaved = Player(PlayerID: player.PlayerID, Team: player.Team, Jersey: player.Jersey, Position: player.Position, FirstName: player.FirstName, LastName: player.LastName, Height: player.Height, Weight: player.Weight, BirthDate: player.BirthDate, BirthCity: player.BirthCity, BirthState: player.BirthState, College: player.College, Salary: player.Salary, PhotoUrl: player.PhotoUrl, Experience: player.Experience, documentID: "")
                    playerToBeSaved.saveFaveData(team: self.teamInfo) { (success) in
                    }
                    
                }
                self.playerInfo.loadFaveData(favoriteTeam: self.teamInfo) {
                    DispatchQueue.main.async{
                        self.setUpRosterPage()
                    }
                }
            }else{
                self.playerInfo.loadFaveData(favoriteTeam: self.teamInfo) {
                    DispatchQueue.main.async{
                        self.setUpRosterPage()
                    }
                }
            }
            
        }
        standingsInfo.getData {
            DispatchQueue.main.async {
                self.setUpStandingsPage()
            }
        }
        scheduleInfo.getData {
            DispatchQueue.main.async {
                self.setUpSchedulePage()
            }
        }
        arenaInfo.getData {
            DispatchQueue.main.async {
                self.setUpArenaPage()
            }
        }
    }
    func setUpRosterPage(){
        self.playerInfo.hooperArray.sort(by: {$0.LastName < $1.LastName })
        self.playerInfo.playerArray.sort(by: {$0.LastName < $1.LastName })
        self.rosterTableView.reloadData()
    }
    func setUpStandingsPage(){
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
    func setUpSchedulePage(){
        for schedule in self.scheduleInfo.schedulesArray{
            let homeID = schedule.HomeTeamID ?? -1
            let awayID = schedule.AwayTeamID ?? -1
            if homeID == self.teamInfo.TeamID || awayID == self.teamInfo.TeamID {
                self.teamGames.append(schedule)
            }
            self.scheduleTableView.reloadData()
        }
    }
    func setUpArenaPage(){
        if self.teamInfo.Name != "Warriors"{
            self.teamArena = self.arenaInfo.arenaArray[self.teamInfo.StadiumID-1]
            self.arenaLatitude = self.arenaInfo.arenaArray[self.teamInfo.StadiumID-1].GeoLat ?? 0.0
            self.arenaLongitude = self.arenaInfo.arenaArray[self.teamInfo.StadiumID-1].GeoLong ?? 0.0
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.arenaLatitude, longitude: self.arenaLongitude), latitudinalMeters: self.regionDistance, longitudinalMeters: self.regionDistance)
            let annotation = Arena(Name: self.arenaInfo.arenaArray[self.teamInfo.StadiumID-1].Name, Address: self.arenaInfo.arenaArray[self.teamInfo.StadiumID-1].Address, Coordinate:CLLocationCoordinate2D(latitude: self.arenaLatitude, longitude: self.arenaLongitude))
            self.updateMap(region: region, annotation: annotation)
        }else{
            self.teamArena = self.arenaInfo.arenaArray[25]
            self.arenaLatitude = self.arenaInfo.arenaArray[25].GeoLat ?? 0.0
            self.arenaLongitude = self.arenaInfo.arenaArray[25].GeoLong ?? 0.0
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: self.arenaLatitude, longitude: self.arenaLongitude), latitudinalMeters: self.regionDistance, longitudinalMeters: self.regionDistance)
            let annotation = Arena(Name: self.arenaInfo.arenaArray[25].Name, Address: self.arenaInfo.arenaArray[25].Address, Coordinate:CLLocationCoordinate2D(latitude: self.arenaLatitude, longitude: self.arenaLongitude))
            self.updateMap(region: region, annotation: annotation)
            
        }
        self.arenaNameLabel.text = self.teamArena.Name
        self.arenaCityLabel.text = "\(self.teamArena.City), \(self.teamArena.State ?? "")"
        self.arenaImageView.image = UIImage(named: self.teamArena.Name)
    }
    func updateMap(region: MKCoordinateRegion, annotation: MKAnnotation){
        arenaMapView.removeAnnotations(arenaMapView.annotations)
        arenaMapView.addAnnotation(annotation)
        arenaMapView.setRegion(region, animated: true)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayerDetail"{
            let destination = segue.destination as! PlayerDetailViewController
            let selectedIndexPath = self.rosterTableView.indexPathForSelectedRow!
            destination.playerInfo = playerInfo.playerArray[selectedIndexPath.row]
            destination.player = playerInfo.hooperArray[selectedIndexPath.row]
            destination.team = teamInfo
            destination.statsInfo = Statistics(seasonKey: standingsInfo.seasonKey)
        }else{
            let destination = segue.destination as! ViewController
            destination.initialFavesCount[index] = initialFaveCount
            if !favorited{
                var remove = -1
                for index in 0 ..< destination.favoritedTeams.count{
                    if destination.favoritedTeams[index].Name == teamInfo.Name{
                        remove = index
                        break
                    }
                }
                destination.favoritedTeams.remove(at: remove)
            }
            DispatchQueue.main.async {
                destination.teamTableView.reloadData()
            }
        }
    }
    @IBAction func unwindFromPlayerDetail(segue: UIStoryboardSegue){
        if segue.identifier == "PlayerDetail"{
            let source = segue.source as! PlayerDetailViewController
            let selectedIndexPath = rosterTableView.indexPathForSelectedRow!
            rosterTableView.scrollToRow(at: selectedIndexPath, at: .bottom, animated: true)
        }
    }
    
    @IBAction func rosterSortSCPressed(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex{
        case 1:
            playerInfo.hooperArray.sort(by: {$0.Jersey < $1.Jersey })
            DispatchQueue.main.async{
                self.rosterTableView.reloadData()
            }
            
        case 0, 2:
            playerInfo.hooperArray.sort(by: {$0.LastName < $1.LastName })
            DispatchQueue.main.async{
                self.rosterTableView.reloadData()
            }
            
        case 3:
            playerInfo.hooperArray.sort(by: {$0.Position < $1.Position })
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
            scheduleTableView.isHidden = true
            monthLabel.isHidden = true
            for button in monthScrollButtonCollection{
                button.isHidden = true
                button.isEnabled = false
            }
            arenaImageView.isHidden = true
            arenaMapView.isHidden = true
            arenaNameLabel.isHidden = true
            arenaCityLabel.isHidden = true
        case 1:
            rosterTableView.isHidden = true
            rosterSortSegmentedControl.isHidden = true
            standingsTableView.isHidden = false
            standingsSortSegmentedControl.isHidden = false
            scheduleTableView.isHidden = true
            monthLabel.isHidden = true
            for button in monthScrollButtonCollection{
                button.isHidden = true
                button.isEnabled = false
            }
            arenaImageView.isHidden = true
            arenaMapView.isHidden = true
            arenaNameLabel.isHidden = true
            arenaCityLabel.isHidden = true
        case 2:
            rosterTableView.isHidden = true
            rosterSortSegmentedControl.isHidden = true
            standingsTableView.isHidden = true
            standingsSortSegmentedControl.isHidden = true
            scheduleTableView.isHidden = false
            monthLabel.isHidden = false
            for button in monthScrollButtonCollection{
                button.isHidden = false
                button.isEnabled = true
            }
            arenaImageView.isHidden = true
            arenaMapView.isHidden = true
            arenaNameLabel.isHidden = true
            arenaCityLabel.isHidden = true
        case 3:
            rosterTableView.isHidden = true
            rosterSortSegmentedControl.isHidden = true
            standingsTableView.isHidden = true
            standingsSortSegmentedControl.isHidden = true
            scheduleTableView.isHidden = true
            monthLabel.isHidden = true
            for button in monthScrollButtonCollection{
                button.isHidden = true
                button.isEnabled = false
            }
            arenaImageView.isHidden = false
            arenaMapView.isHidden = false
            arenaNameLabel.isHidden = false
            arenaCityLabel.isHidden = false
        default:
            print("You shouldn't have gotten here!")
        }
    }
    @IBAction func monthScrollPressed(_ sender: UIButton) {
        if sender.tag == 0{
            if monthScrollIndex == 0{
                monthScrollIndex = 11
                year = "\(Int(year)!-1)"
            }else{
                monthScrollIndex-=1
            }
        }else{
            if monthScrollIndex == 11{
                monthScrollIndex = 0
                year = "\(Int(year)!+1)"
            }else{
                monthScrollIndex+=1
            }
        }
        monthLabel.text = "\(months[monthScrollIndex]) \(year)"
        DispatchQueue.main.async {
    
            self.scheduleTableView.reloadData()
        }
    }
    
    
    

}

extension TeamDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.standingsTableView{
            return teamsByConference[0].count
        }
        else if tableView == self.scheduleTableView{
            var currentMonthGames: [ScheduleInfo] = []
            for schedule in self.teamGames{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                let date = schedule.DateTime ?? "2020-01-01T00:00:00"
                let updatedDate = dateFormatter.date(from: date)
                dateFormatter.dateFormat = "LLLL"
                let nameOfMonth = dateFormatter.string(from: updatedDate!)
                let currentMonth = self.monthLabel.text!.prefix(upTo: self.monthLabel.text!.firstIndex(of: " ")!)
                if nameOfMonth == currentMonth{
                    currentMonthGames.append(schedule)
                }
            }
            if currentMonthGames.count == 0 && self.teamGames.count > 0{
                self.noGamesLabel.isHidden = false
            }else{
                self.noGamesLabel.isHidden = true
            }
            return currentMonthGames.count
        }else{
           return playerInfo.hooperArray.count
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
                cell.playerNameLabel.text = "\(playerInfo.playerArray[indexPath.row].FirstName) \(playerInfo.hooperArray[indexPath.row].LastName)"
            cell.playerNumberLabel.text = String(playerInfo.playerArray[indexPath.row].Jersey)
                cell.playerPositionLabel.text = playerInfo.playerArray[indexPath.row].Position
                
                return cell
        }else if tableView == self.standingsTableView{
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
        }else{
            let cell = scheduleTableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! GameTableViewCell
            var currentMonthGames: [ScheduleInfo] = []
            let dateFormatter = DateFormatter()
            for schedule in self.teamGames{
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
                let date = schedule.DateTime ?? "2020-01-01T00:00:00"
                let updatedDate = dateFormatter.date(from: date)
                dateFormatter.dateFormat = "LLLL"
                let nameOfMonth = dateFormatter.string(from: updatedDate!)
                let currentMonth = self.monthLabel.text!.prefix(upTo: self.monthLabel.text!.firstIndex(of: " ")!)
                if nameOfMonth == currentMonth{
                    currentMonthGames.append(schedule)
                }
            }
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            var homeTeam: TeamInfo!
            var awayTeam: TeamInfo!
            for team in self.teams.teamArray{
                if team.TeamID == currentMonthGames[indexPath.row].HomeTeamID{
                    homeTeam = team
                }else if team.TeamID == currentMonthGames[indexPath.row].AwayTeamID{
                    awayTeam = team
                }
            }
            let homeLogoOriginalImageName = homeTeam.WikipediaLogoUrl
            let awayLogoOriginalImageName = awayTeam.WikipediaLogoUrl
            var homeModifiedImageFileName = (homeLogoOriginalImageName.suffix(from: homeLogoOriginalImageName.lastIndex(of: "/")!))
            var awayModifiedImageFileName = (awayLogoOriginalImageName.suffix(from: awayLogoOriginalImageName.lastIndex(of: "/")!))
            homeModifiedImageFileName.removeFirst()
            awayModifiedImageFileName.removeFirst()
            cell.homeTeamNameLabel.text = homeTeam.Name
            cell.homeTeamLogoImageView.image = UIImage(named: String(homeModifiedImageFileName))
            cell.homeTeamScoreLabel.text = String(currentMonthGames[indexPath.row].HomeTeamScore ?? 0)
            cell.awayTeamNameLabel.text = awayTeam.Name
            cell.awayTeamLogoImageView.image = UIImage(named: String(awayModifiedImageFileName))
            cell.awayTeamScoreLabel.text = String(currentMonthGames[indexPath.row].AwayTeamScore ?? 0)
            let boldAttribute = [NSAttributedString.Key.font: UIFont(name: "Rockwell-Bold", size: 17.0)!]
            let regularAttribute = [NSAttributedString.Key.font: UIFont(name: "Rockwell", size: 17.0)!]
            let boldItalicAttribute = [NSAttributedString.Key.font: UIFont(name: "Rockwell-BoldItalic", size: 17.0)!]
            if cell.homeTeamNameLabel.text == self.teamInfo.Name{
                cell.homeTeamNameLabel.attributedText = NSAttributedString(string: cell.homeTeamNameLabel.text!, attributes: boldAttribute)
                cell.awayTeamNameLabel.attributedText = NSAttributedString(string: cell.awayTeamNameLabel.text!, attributes: regularAttribute)
            }else{
                cell.awayTeamNameLabel.attributedText = NSAttributedString(string: cell.awayTeamNameLabel.text!, attributes: boldAttribute)
                cell.homeTeamNameLabel.attributedText = NSAttributedString(string: cell.homeTeamNameLabel.text!, attributes: regularAttribute)
            }
            let gameDate = currentMonthGames[indexPath.row].DateTime ?? "2020-01-01T00:00:00"
            let parsedDate = dateFormatter.date(from: gameDate)!
            dateFormatter.dateFormat = "MM/dd"
            cell.dateLabel.text = dateFormatter.string(from: parsedDate)
            if currentMonthGames[indexPath.row].Status != "Final" && currentMonthGames[indexPath.row].Status != "F/OT" {
                cell.awayTeamScoreLabel.isHidden = true
                cell.homeTeamScoreLabel.isHidden = true
                cell.dateLabel.frame.origin.x = cell.awayTeamScoreLabel.frame.origin.x

            }else{
                cell.awayTeamScoreLabel.isHidden = false
                cell.homeTeamScoreLabel.isHidden = false
                cell.dateLabel.frame.origin.x = cell.awayTeamScoreLabel.frame.origin.x - 60
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.rosterTableView{
            return 85
        }else if tableView == self.scheduleTableView{
            return 100
        }
        else{
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

