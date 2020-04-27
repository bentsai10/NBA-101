//
//  AddTeamTableViewCell.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/17/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class AddTeamTableViewCell: UITableViewCell {
    @IBOutlet weak var logoImageView: UIImageView!
    
    @IBOutlet weak var teamNameLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var link: AddTeamTableViewController?
    
    @IBAction func favoritedPressed(_ sender: UIButton) {
        link?.editFavoriteTeams(cell: self)
    }
    
}
