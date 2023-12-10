//
//  PlanCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class MyPlanCell: UITableViewCell {
    
    @IBOutlet weak var planImageView: UIImageView! {
        didSet {
            planImageView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planDateLabel: UILabel!
}
