//
//  MemoryDetailCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class MemoryDetailCell: UITableViewCell {
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var memoryCollectionView: UICollectionView!
    @IBOutlet weak var articleTextView: UITextView! {
        didSet {
            articleTextView.layer.cornerRadius = 15
            articleTextView.clipsToBounds = true
            articleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            articleTextView.font = UIFont.systemFont(ofSize: 16, weight: .light)
            articleTextView.sizeToFit()
            articleTextView.isScrollEnabled = false
            articleTextView.isEditable = false
        }
    }
    @IBOutlet weak var articleConstraint: NSLayoutConstraint!
}
