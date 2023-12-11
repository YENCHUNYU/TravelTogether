//
//  PlanDetailCell.swift
//  TravelTogether
//
//  Created by User on 2023/12/10.
//

import UIKit

class PlanDetailCell: UITableViewCell {
    var currentImageUrl = ""
    @IBOutlet weak var pinImageView: UIImageView!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var placeStackView: UIView! {
        didSet {
            placeStackView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddressLabel: UILabel!
    
    @IBOutlet weak var locationImageView: UIImageView! {
        didSet {
            locationImageView.layer.cornerRadius = 15
            locationImageView.contentMode = .scaleAspectFill
        }
    }
    
}
    
