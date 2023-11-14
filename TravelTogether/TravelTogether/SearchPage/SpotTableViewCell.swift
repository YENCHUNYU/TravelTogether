//
//  spotTableViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class SpotCell: UITableViewCell {
    
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var thumbsUpButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var thumbsUpCountsLabel: UILabel!
    @IBOutlet weak var favoriteCountsLabel: UILabel!
    
    var isLiked = false
    var isFavorite = false
    
    @IBAction func thumbUpButtonTapped(_ sender: Any) {
        
        isLiked = !isLiked
        
        if isLiked {
            thumbsUpButton.setTitle("已按讚", for: .normal)
            thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
        } else {
            thumbsUpButton.setTitle("讚", for: .normal)
            thumbsUpButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
        }
        
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        
        isFavorite = !isFavorite
        
        if isFavorite {
            favoriteButton.setTitle("已收藏", for: .normal)
            favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else {
            favoriteButton.setTitle("收藏", for: .normal)
            favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        
    }
    
    
}
