//
//  imageCollectionViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/12/1.
//
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 20
            memoryImageView.clipsToBounds = true
            memoryImageView.contentMode = .scaleAspectFill
        }
    }

}

class AddPhotoCell: UICollectionViewCell {
    @IBOutlet weak var addNewPhotoButton: UIButton! {
        didSet {
            addNewPhotoButton.setTitle("", for: .normal)
        }
    }
    
    @IBOutlet weak var addView: UIView! {
        didSet {
            addView.layer.cornerRadius = 20
            addView.clipsToBounds = true
            addView.contentMode = .scaleAspectFill
        }
    }
}
