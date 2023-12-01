//
//  imageCollectionViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/12/1.
//
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 20
            imageView.clipsToBounds = true
            imageView.contentMode = .scaleAspectFill
        }
    }

}

class AddPhotoCell: UICollectionViewCell {
    @IBOutlet weak var addNewPhotoButton: UIButton!
    
    @IBOutlet weak var addView: UIView! {
        didSet {
            addView.layer.cornerRadius = 20
            addView.clipsToBounds = true
            addView.contentMode = .scaleAspectFill
        }
    }
}