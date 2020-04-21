//
//  ViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/17/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit





class ViewController: UIViewController {

    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var gameTableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var teamEditToolbar: UIToolbar!
    
    var teamData = Teams()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableView.delegate = self
        teamTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.dataSource = self
        teamData.getData {
            DispatchQueue.main.async{
                self.teamTableView.reloadData()
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .blue
        self.navigationController?.toolbar.barTintColor = .blue
    }

    @IBAction func segmentedControlPressed(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0){
            teamTableView.isHidden = false
            gameTableView.isHidden = true
            teamEditToolbar.isHidden = false
        }else{
            teamTableView.isHidden = true
            gameTableView.isHidden = false
            teamEditToolbar.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTeam"{
            let destination = segue.destination as! TeamDetailViewController
            let selectedIndexPath = teamTableView.indexPathForSelectedRow!
            destination.teamInfo = teamData.teamArray[selectedIndexPath.row]
            destination.playerInfo = Players(teamKey: teamData.teamArray[selectedIndexPath.row].Key)
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy"
            let year = dateFormatter.string(from: Date())
            dateFormatter.dateFormat = "LLLL"
            let month = dateFormatter.string(from: Date())
            //conditionals to account for NBA season spanning tail end of one year and beginning of next
            var laterMonths = ["October", "November", "December"]
            if laterMonths.contains(month){
                var yearInt = Int(year)!+1
                destination.standingsInfo = Standings(seasonKey: String(yearInt))
            }else{
                destination.standingsInfo = Standings(seasonKey: year)
            }
            
        }
    }
    @IBAction func unwindFromTeamDetail(segue: UIStoryboardSegue){
        if segue.identifier == "ViewTeam"{
            let source = segue.source as! TeamDetailViewController
            let selectedIndexPath = teamTableView.indexPathForSelectedRow!
            teamTableView.scrollToRow(at: selectedIndexPath, at: .bottom, animated: true)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.teamTableView{
            return teamData.teamArray.count
        }else{
            return teamData.teamArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.teamTableView{
            teamData.teamArray.sort(by: {$0.City < $1.City})
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TeamTableViewCell
            cell.teamNameLabel.text = "\(teamData.teamArray[indexPath.row].City) \(teamData.teamArray[indexPath.row].Name)"
            /*
             API provides url to svg file. Had trouble converting svg. So manually extracted images as screenshots.
             Then used backhalf of url as image names in asset catalog.
            */
            let logoOriginalImageName = teamData.teamArray[indexPath.row].WikipediaLogoUrl
            var modifiedImageFileName = (logoOriginalImageName.suffix(from: logoOriginalImageName.lastIndex(of: "/")!))
            modifiedImageFileName.removeFirst()
            cell.logoImageView.image = UIImage(named: String(modifiedImageFileName))
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! GameTableViewCell
            cell.homeTeamNameLabel.text = ""
            cell.awayTeamNameLabel.text = ""
            cell.awayTeamScoreLabel.text = "\(indexPath.row)"
            cell.homeTeamScoreLabel.text = "\(indexPath.row)"
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.gameTableView{
            return 100
        }
        return 60
    }
    
    
}

