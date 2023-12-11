//
//  EditPlanCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit

class EditPlanCell: UITableViewCell {
    var currentImageURL = ""
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var placeStackView: UIView! {
        didSet {
            placeStackView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel! {
        didSet {
            userLabel.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            locationImageView.layer.cornerRadius = 15
            locationImageView.contentMode = .scaleAspectFill
        }
    }
    
}
