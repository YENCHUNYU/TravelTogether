//
//  EditMemoryCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import UIKit

class EditMemoryCell: UITableViewCell, UITextViewDelegate {
    
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
        textViewDidEndEditing(articleTextView)
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        textViewDidBeginEditing(articleTextView)
    }
    
        func setupTextView() {
            articleTextView.text = "輸入旅程中的美好回憶..."
            articleTextView.textColor = UIColor.lightGray
            articleTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            articleTextView.font = UIFont.systemFont(ofSize: 16, weight: .light)
            articleTextView.delegate = self
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == UIColor.lightGray {
                textView.text = nil
                textView.textColor = UIColor.black
            }
            articleTextView.becomeFirstResponder()
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = "輸入旅程中的美好回憶..."
                textView.textColor = UIColor.lightGray
            }
            textView.resignFirstResponder()
        }
    
}
