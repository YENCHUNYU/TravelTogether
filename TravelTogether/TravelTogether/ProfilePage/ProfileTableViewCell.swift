//
//  ProfileTableViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 20
            memoryImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var memoryNameLabel: UILabel!
     
    @IBOutlet weak var labelBackgroundView: UIView! {
        didSet {
            labelBackgroundView.layer.cornerRadius = 15
            labelBackgroundView.clipsToBounds = true
        }
    }
}
