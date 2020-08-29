# NBA-101
Full-stack app resembling bleacher report app to contain NBA info built from scratch

Leave spontaneous google searches about the NBA behind with the app that holds all the possible info you want to know about your favorite NBA teams: NBA 101!

<p align = "center"><kbd><img src = "/images/launch.png" height = "400"></kbd></p>

<p><strong>NBA 101's purpose:</strong><br>Provide NBA fans with ease of access to team schedules, statistics, standings, and rosters (players).</p>

<h3> Accessing NBA 101</h3>
<ul>
  <li>Own a Mac (Sorry PC users :( )</li>
  <li>Download XCode</li>
  <li>NBA 101 was created using XCode 11.6, so make sure you have that or a higher version!</li>
  <li>Go to the "Code" dropdown above and select "Open in XCode!"</li>
  <li>Add your favorite teams!</li>
</ul>

<h3>How NBA 101 Works</h3>
<ol>
  <li>Login using a google account so the app can save your favorite teams</li>
  <br>
  <p align = "center"><kbd><img src = "/images/google_log.png" height = "500"></kbd></p>
  <li>Add your favorite teams to your home page</li>
  <br>
  <p align = "center"><kbd><img src = "/images/fave_teams.gif" height = "500"></kbd></p>
  <li>Freely edit your favorite teams whenever they change (We don't judge Bandwagon fans!)</li>
  <br>
  <p align = "center"><kbd><img src = "/images/edit_faves.gif" height = "500"></kbd></p>
  <li>Click on your team to access their team page</li>
  <br>
  <p align = "center"><kbd><img src = "/images/base_team_page.gif" height = "500"></kbd></p>
  <li>See a player you don't recognize? Locate them by sorting the roster by last name, number, or position</li>
  <br>
  <p align = "center"><kbd><img src = "/images/roster_sort.gif" height = "500"></kbd></p>
  <li>Wondering where your team stands? Navigate to the standings page to see your team highlighted</li>
  <br>
  <p align = "center"><kbd><img src = "/images/standings_voew.gif" height = "500"></kbd></p>
  <li>Curious what games your team has played or has coming up? Navigate to the schedule page to update your viewing schedule</li>
  <br>
  <p align = "center"><kbd><img src = "/images/schedule_view.gif" height = "500"></kbd></p>
  <li>Want to know where your team's arena is and what's around it? Navigate to the arena page to scope things out</li>
  <br>
  <p align = "center"><kbd><img src = "/images/arena_view.gif" height = "500"></kbd></p>
  <li>Want to check in on how a player is doing this season or find out other information? Click on any player on the roster to learn more about them</li>
  <br>
  <p align = "center"><kbd><img src = "/images/player_view1.gif" height = "500"></kbd></p>
  <li>Add player action photos throughout the season whenever you catch them in action</li>
  <br>
  <p align = "center"><kbd><img src = "/images/add_player_photo.gif" height = "500"></kbd></p>
</ol>
<h3>Logic Behind NBA 101</h3>
<ul>
  <li>Extensive API use to fetch information throughout the app</li>
  <ul>
    <li>Similar logic is used to get team, player, standings, schedule, and arena info, but below is the excerpt for retrieving all NBA teams</li>
    <li>Returned struct created with all the relevant attributes we want to retrieve of each team from the API url</li>
    <li>Returned struct created with all the relevant attributes we want to retrieve of each team from the API url</li>
    <li>loadData function retrieves data in JSON format from API url and decodes each team's JSON data into the prebuilt TeamInfo struct</li>
    <li>All teams' TeamInfo struct then appended to array of teams displayed to user when they go to add their favorite teams</li>
  </ul>
  
```swift

struct TeamInfo: Codable{
    var TeamID: Int
    var Key: String
    var City: String
    var Name: String
    var StadiumID: Int
    var PrimaryColor: String
    var SecondaryColor: String
    var WikipediaLogoUrl: String
}

class AllTeams{
    var url: String = "https://api.sportsdata.io/v3/nba/scores/json/teams?key=\(APIKeys.sportsDataNBAKey)"
    var teamArray: [TeamInfo] = []
    var allTeamArray = [Team]()
    
    private struct Returned: Codable {
        var TeamID: Int
        var Key: String
        var City: String
        var Name: String
        var StadiumID: Int
        var PrimaryColor: String
        var SecondaryColor: String
        var WikipediaLogoUrl: String
    }
    
    ...
    
    func getData(completed: @escaping ()->()){
        let urlString = url
        guard let url = URL(string: urlString)else{
            print("Error")
            completed()
            return
        }
        let session = URLSession.shared    
        let task = session.dataTask(with: url){(data, response, error)in
            if let error = error{
                print("error")
            }
            do{
                let returned = try JSONDecoder().decode([TeamInfo].self, from: data!)
                self.teamArray = self.teamArray + returned
            }catch{
                print("error getting teams")
            }
            completed()
        }
        task.resume()
    }
}
```
  <li>Using Firebase to save and load data</li>
  <ul>
    <li>Use dictionary associated with each Team object to save all relevant data to Firebase. Only allow users who are logged in to save data to Firebase</li>
    <li>If collection (of teams, in this case) exists already, update the document with the info being saved, otherwise create a new collection with the saved info</li>
    <li>To load the data, locate the previously saved collection and iterate through items in the collection to retrieve them</li>
  </ul>
  
```swift

var dictionary: [String: Any]{
        return ["TeamID": TeamID, "Key": Key, "City": City, "Name" : Name, "StadiumID": StadiumID, "PrimaryColor": PrimaryColor, "SecondaryColor":SecondaryColor, "WikipediaLogoURL": WikipediaLogoUrl, "postingUserID": postingUserID]
}

func saveData(completed: @escaping (Bool) -> ()){
  let db = Firestore.firestore()
  guard let postingUserID = (Auth.auth().currentUser?.uid) else{
      print("Could not save data b/c no valid postingUserID")
      return completed(false)
  }
  self.postingUserID = postingUserID
  let dataToSave = self.dictionary

  if self.documentID != "" {
      let ref = db.collection("allTeams").document(self.documentID)
      ref.setData(dataToSave){ (error) in
          if let error = error {
              print("ERROR: updating document \(self.documentID)\(error.localizedDescription)")
              completed(false)
          }else {
              print("Document updated with ref ID \(ref.documentID)")
              completed(true)
          }
      }
  }else {
      var ref: DocumentReference? = nil //let firestore create the new documentID
      ref = db.collection("allTeams").addDocument(data: dataToSave) {error in
         if let error = error {
              print("ERROR: creating new document \(self.documentID)\(error.localizedDescription)")
              completed(false)
          }else {
          print("new document created with ref ID \(ref?.documentID ?? "unknown")")
              completed(true)
          }
      }
  }
}
```
```swift
func loadData(completed: @escaping ()->()){
    db.collection("allTeams").addSnapshotListener { (querySnapshot, error) in
        guard error == nil else {
            print("***ERROR: adding the snapshot listener \(error!.localizedDescription)")
            return completed()
        }
        self.allTeamArray = []
        //there are questSnapshot!.documents.count documents in the spots snapshot
        for document in querySnapshot!.documents {
            let team = Team(dictionary: document.data())
            team.documentID = document.documentID
            self.allTeamArray.append(team)
        }
        completed()
    }
}
```
  <li>Populating tableViews throughout application</li>
  <ul>
    <li>Similar logic is used to populate tableviews for team, player, standings, schedule, and arena pages, but below is the excerpt for retrieving all NBA teams</li>
    <li>Team objects retrieved from API or loaded from firebase are added to teamArray</li>
    <li>Use appropriate variable values of given Team at each index to populate each tableView cell</li>
    <li>In this case, this is the tableView for adding your favorite teams: so if the team is favorited (favoritedTeams is an array of length 30 with 
    all indexes set to false at launch. Index matching chosen index in teamArray set to true when user favorites team at that index), a filled-in star
    is displayed. If not favorited, there is a blank star next to the team</li>
  </ul>

```swift
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
```
</ul>
<h3>NBA 101 is responsive across iPads and iPhones!</h3>
<h6><em>(Displayed images are of iPad, iPhone 11, and iPhone SE in that order)</em></h6>
<p align = "center"><kbd><img src = "/images/ipad.png" height = "500"></kbd></p>
<br>
<p align = "center"><kbd><img src = "/images/iphone11.png" height = "500"></kbd><img src = "/images/white_space.png" width = "100"><kbd><img src = "/images/iphoneSE.png" height = "500"></kbd></p>
