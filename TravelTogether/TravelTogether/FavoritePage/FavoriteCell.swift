//
//  FavoriteCell.swift
//  TravelTogether
//
//  Created by User on 2023/12/10.
//

import UIKit

class FavoriteMemoryCell: UITableViewCell {
   
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.backgroundColor = .lightGray.withAlphaComponent(0.1)
            userImageView.layer.cornerRadius = 25
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 20
        }
    }
  
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var memoryNameLabel: UILabel!
    
}
