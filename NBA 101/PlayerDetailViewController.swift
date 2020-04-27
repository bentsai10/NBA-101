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
    
    var playerInfo: PlayerInfo!
    var player:Player!
    
    var team: FavoriteTeam!
    var photos: PlayerPhotos!
    var statsInfo: Statistics!
    var playerStats:StatisticsInfo!
    var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if playerInfo == nil{
            playerInfo = PlayerInfo(PlayerID: 9, Team: "", Jersey: 0, Position: "", FirstName: "", LastName: "", Height: 0, Weight: 0, BirthDate: nil, BirthCity: nil, BirthState: nil, College: nil, Salary: nil, PhotoUrl: "", Experience: 0)
        }
        if team == nil{
            team = FavoriteTeam()
        }
        photos = PlayerPhotos()
        
        playerPhotoCollectionView.delegate = self
        playerPhotoCollectionView.dataSource = self
        playerStatsTableView.delegate = self
        playerStatsTableView.dataSource = self
        imagePicker.delegate = self

        statsInfo.getData {
            DispatchQueue.main.async {
                for playerStats in self.statsInfo.statsArray{
                    if self.playerInfo.PlayerID == playerStats.PlayerID{
                        self.playerStats = playerStats
                        break
                    }
                }
                self.playerStatsTableView.reloadData()
            }
        }
        photos.loadData(team: team, player: player) {
            DispatchQueue.main.async {
                
                self.playerPhotoCollectionView.reloadData()
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
        if let imageURL = URL(string: playerInfo.PhotoUrl){
                playerImageView.load(url: imageURL)
            }else{
                playerImageView.image = UIImage()
        }
        playerNameLabel.text = "\(playerInfo.FirstName) \(playerInfo.LastName)"
        playerNumberLabel.text = "#\(String(playerInfo.Jersey))"
        playerPositionLabel.text = playerInfo.Position
        playerHeightLabel.text = "\(playerInfo.Height / 12)'\(playerInfo.Height % 12)"
        playerWeightLabel.text = "\(playerInfo.Weight)"
        playerExperienceLabel.text = "\(playerInfo.Experience)"
        var salaryString = ""
        if playerInfo.Salary == nil{
            salaryString = "N/A"
        }else{
            salaryString = formatSalary(salary: playerInfo.Salary!)
        }
        playerSalaryLabel.text = salaryString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        let date = playerInfo.BirthDate ?? "0000-01-01T00:00:00"
        if date == "0000-01-01T00:00:00"{
            playerBirthdayLabel.text = "N/A"
        }else{
            let updatedDate = dateFormatter.date(from: date)
            dateFormatter.dateFormat = "yyyy/MM/dd"
            let bdayString = dateFormatter.string(from: updatedDate!)
            playerBirthdayLabel.text = bdayString
        }
        if playerInfo.BirthCity == nil && playerInfo.BirthState == nil{
            playerHometownLabel.text = "N/A"
        }else{
            if playerInfo.BirthCity == nil{
                playerHometownLabel.text = "\(playerInfo.BirthState!)"
            }else if playerInfo.BirthState == nil{
                playerHometownLabel.text = "\(playerInfo.BirthCity!)"
            }else{
                playerHometownLabel.text = "\(playerInfo.BirthCity!), \(playerInfo.BirthState!)"
            }
        }
        if playerInfo.College == nil{
            playerCollegeLabel.text = "N/A"
        }else{
            playerCollegeLabel.text = playerInfo.College!
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
    func cameraOrLibraryAlert(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default){_ in
            self.accessCamera()
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default){_ in
            self.accessLibrary()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        cameraOrLibraryAlert()
    }
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension PlayerDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PlayerPhotoCollectionViewCell
        cell.photo = photos.photoArray[indexPath.row]
        return cell
    }
    
}

extension PlayerDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playerStatsTableView.dequeueReusableCell(withIdentifier: "StatsCell", for: indexPath) as! StatisticsTableViewCell
        if playerStats == nil{
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
extension PlayerDetailViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let photo = PlayerPhoto()
        photo.image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        dismiss(animated: true) {
            photo.saveData(team: self.team , player:self.player){ (success) in
                if success{
                    self.photos.photoArray.append(photo)
                    self.playerPhotoCollectionView.reloadData()
                }
            }
            self.playerPhotoCollectionView.reloadData()
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func accessLibrary(){
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    func accessCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }else{
            showAlert(title: "Camera Not Available", message: "There is no camera available.")
        }
    }
}
