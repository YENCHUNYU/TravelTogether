//
//  ProfileTableViewCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class ProfileCell: UITableViewCell {
    
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 20
            memoryImageView.clipsToBounds = true
        }
    }
    @IBOutlet weak var memoryNameLabel: UILabel!
     
    @IBOutlet weak var labelBackgroundView: UIView! {
        didSet {
            addRoundedBottomCorners(to: labelBackgroundView, cornerRadius: 15)
        }
    }
    
    var taskIdentifier = ""
    
    func addRoundedBottomCorners(to view: UIView, cornerRadius: CGFloat) {
            let maskPath = UIBezierPath(
                roundedRect: view.bounds,
                byRoundingCorners: [.bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)
            )

            let shapeLayer = CAShapeLayer()
            shapeLayer.path = maskPath.cgPath
            view.layer.mask = shapeLayer
        }
}
