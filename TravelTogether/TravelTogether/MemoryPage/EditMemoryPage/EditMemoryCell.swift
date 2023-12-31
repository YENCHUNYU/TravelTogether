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
        didSet {
            articleTextView.layer.cornerRadius = 15
            articleTextView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            editButton.layer.cornerRadius = 15
        }
    }
    
    override func awakeFromNib() {
            super.awakeFromNib()
            setupTextView()
        }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        articleTextView.resignFirstResponder()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        articleTextView.becomeFirstResponder()
    }
    
    var imageCollectionData: [String] = []
    func setImageData(_ imageData: [String]) {
            imageCollectionData = imageData
            imageCollectionView.reloadData()
        }
    
        func setupTextView() {
            articleTextView.text = "輸入旅程中的美好回憶..."
            articleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            articleTextView.font = UIFont.systemFont(ofSize: 16, weight: .light)
        }
}
