//
//  PlayerPhotoCollectionViewCell.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/26/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class PlayerPhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    var photo: PlayerPhoto!{
        didSet{
            photoImageView.image = photo.image
        }
    }
    
}
