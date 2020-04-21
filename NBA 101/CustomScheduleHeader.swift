//
//  CustomScheduleHeader.swift
//  NBA 101
//
//  Created by Ben Tsai on 4/21/20.
//  Copyright © 2020 Ben Tsai. All rights reserved.
//

import UIKit

class CustomScheduleHeader: UITableViewHeaderFooterView {
    let title = UILabel()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configureContents() {
        title.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(title)
        contentView.backgroundColor = .clear

        // Center the image vertically and place it near the leading
        // edge of the view. Constrain its width and height to 50 points.
        NSLayoutConstraint.activate([
        
            // Center the label vertically, and use it to fill the remaining
            // space in the header view.
            title.heightAnchor.constraint(equalToConstant: 30),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,
                   constant: 8),
            title.trailingAnchor.constraint(equalTo:
                   contentView.layoutMarginsGuide.trailingAnchor),
            title.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)])
            
    }
    func assignTextColor(color: UIColor){
        title.textColor = color
        title.font = UIFont(name: "Rockwell", size: CGFloat(18))
    }

}
