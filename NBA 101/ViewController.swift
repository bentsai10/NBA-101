//
//  ViewController.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/17/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import GoogleSignIn




class ViewController: UIViewController {

    @IBOutlet weak var teamTableView: UITableView!
    @IBOutlet weak var teamEditToolbar: UIToolbar!
    var authUI: FUIAuth!
    
    var teamData = FavoriteTeams()
    var allTeams = AllTeams()
    var favoritedTeams = [TeamInfo]()
    var initialFavesCount = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    var dataSaved = false
    var justOpened = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authUI = FUIAuth.defaultAuthUI()
        authUI?.delegate = self
        
        teamTableView.delegate = self
        teamTableView.dataSource = self
        allTeams.getData {
            self.allTeams.teamArray.sort(by: {$0.City < $1.City})
        }
        teamData.loadData {
            DispatchQueue.main.async {
                self.teamTableView.reloadData()
            }
        }
        teamTableView.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.barTintColor = .blue
        self.navigationController?.toolbar.barTintColor = .blue
        teamData.loadData {
            DispatchQueue.main.async {
                self.teamTableView.reloadData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        signIn()
    }
    func signIn(){
        let providers: [FUIAuthProvider] = [
          FUIGoogleAuth(),
        ]
        let currentUser = authUI.auth?.currentUser
        if authUI.auth?.currentUser == nil {
            self.authUI?.providers = providers
            let loginViewController = authUI.authViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true, completion: nil)
        }else{
            teamTableView.isHidden = false
        }
        
        
    }
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do{
            try authUI!.signOut()
            print("user has signed out")
            teamTableView.isHidden = true
            signIn()
        }catch{
            teamTableView.isHidden = true
            print("Error signing out!")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewTeam"{
            let destination = segue.destination as! TeamDetailViewController
            let selectedIndexPath = teamTableView.indexPathForSelectedRow!
            destination.teams = allTeams
            destination.teamInfo = teamData.faveTeamArray[selectedIndexPath.row]
            destination.playerInfo = Players(teamKey: teamData.faveTeamArray[selectedIndexPath.row].Key)
            for index in 0..<allTeams.teamArray.count{
                if teamData.faveTeamArray[selectedIndexPath.row].Name == allTeams.teamArray[index].Name{
                    destination.initialFaveCount = initialFavesCount[index]
                    destination.index = index
                    break
                }
            }
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
                destination.scheduleInfo = Schedules(seasonKey: String(yearInt))
            }else{
                destination.standingsInfo = Standings(seasonKey: year)
                destination.scheduleInfo = Schedules(seasonKey: String(year))
            }
            
        }else{
            let destination = segue.destination as! AddTeamTableViewController
            allTeams.teamArray.sort(by: {$0.City < $1.City})
            destination.teams = allTeams
            destination.previousFaves = teamData.faveTeamArray
        }
    }
    @IBAction func unwindFromTeamDetail(segue: UIStoryboardSegue){
        let source = segue.source as! TeamDetailViewController
        
    }
    @IBAction func unwindFromAddTeam(segue: UIStoryboardSegue){
        if segue.identifier == "AddTeam"{
            let source = segue.source as! AddTeamTableViewController
        }
    }
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
    }
    
    
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamData.faveTeamArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.teamTableView{
            teamData.faveTeamArray.sort(by: {$0.City < $1.City})
            let team = teamData.faveTeamArray[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "TeamCell", for: indexPath) as! TeamTableViewCell
            cell.teamNameLabel.text = "\(team.City) \(team.Name)"
            /*
             API provides url to svg file. Had trouble converting svg. So manually extracted images as screenshots.
             Then used backhalf of url as image names in asset catalog.
            */
            let logoOriginalImageName = team.WikipediaLogoUrl
            var modifiedImageFileName = (logoOriginalImageName.suffix(from: logoOriginalImageName.lastIndex(of: "/")!))
            modifiedImageFileName.removeFirst()
            cell.logoImageView.image = UIImage(named: String(modifiedImageFileName))
            
            return cell
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath) as! RosterTableViewCell
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    
}
extension ViewController: FUIAuthDelegate{
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?
      if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
        return true
      }
      // other URL handling goes here.
      return false
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        if let user = user{
            print("User has signed in! Userid: \(user.email ?? "unknown email")")
        }
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let loginViewController = FUIAuthPickerViewController(authUI: authUI)
        loginViewController.view.backgroundColor = UIColor.blue
        let marginInsets: CGFloat = 10
        let imageHeight: CGFloat = 400
        let imageY = self.view.center.y - imageHeight
        let logoFrame = CGRect(x: self.view.frame.origin.x + marginInsets, y: imageY + 130, width: self.view.frame.width - (marginInsets*2), height: imageHeight)
        let logoImageView = UIImageView(frame: logoFrame)
        logoImageView.image = UIImage(named: "nba logo")
        logoImageView.contentMode = .scaleAspectFit
        loginViewController.view.addSubview(logoImageView)
        return loginViewController
        
    }
}
