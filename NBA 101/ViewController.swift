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
    override func viewDidLoad() {
        super.viewDidLoad()
        teamTableView.delegate = self
        teamTableView.dataSource = self
        gameTableView.delegate = self
        gameTableView.dataSource = self
    }

    var myTeams = ["Golden State Warriors", "Miami Heat", "Cleveland Cavaliers", "Boston Celtics"]
    var myteams2 = ["Juventus", "Man U", "Real Madrid"]
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
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.teamTableView{
            return myTeams.count
        }else{
            return myteams2.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.teamTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TeamTableViewCell
            cell.teamNameLabel.text = myTeams[indexPath.row]
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath) as! GameTableViewCell
            cell.homeTeamNameLabel.text = myteams2[indexPath.row]
            cell.awayTeamNameLabel.text = myteams2[indexPath.row]
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

