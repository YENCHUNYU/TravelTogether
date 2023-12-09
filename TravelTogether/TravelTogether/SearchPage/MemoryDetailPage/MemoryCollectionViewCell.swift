//
//  MemoryCollectionViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/12/10.
//
import UIKit

class MemoryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 20
            memoryImageView.clipsToBounds = true
            memoryImageView.contentMode = .scaleAspectFill
        }
    }
}
