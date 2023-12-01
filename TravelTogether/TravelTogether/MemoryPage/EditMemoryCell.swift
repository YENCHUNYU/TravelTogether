//
//  EditMemoryCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import UIKit

class EditMemoryCell: UITableViewCell {
    
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var imageCollectionView: UICollectionView!
    
    @IBOutlet weak var articleTextView: UITextView! {
        didSet{
            articleTextView.layer.cornerRadius = 15
            articleTextView.clipsToBounds = true
        }
    }
    
}
