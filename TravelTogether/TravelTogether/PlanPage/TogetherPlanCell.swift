//
//  TogetherPlanCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class TogetherPlanCell: UITableViewCell {
    
    @IBOutlet weak var planImageView: UIImageView!
    @IBOutlet weak var planeNameLabel: UILabel!
    @IBOutlet weak var planDateLabel: UILabel!
  
    
    private var userImageViews: [UIImageView] = []

        override func awakeFromNib() {
            super.awakeFromNib()
            configure(with: [UIImage(systemName: "person.circle")!, UIImage(systemName: "person.circle.fill")!])
            // 初始化或设置任何其他属性
        }

        func configure(with users: [UIImage]) {
            // 移除之前的所有 userImageViews
            userImageViews.forEach { $0.removeFromSuperview() }
            userImageViews.removeAll()

            // 创建并添加新的 userImageViews
            for (index, userImage) in users.enumerated() {
                let userImageView = UIImageView(image: userImage)
                userImageView.contentMode = .scaleAspectFill
                userImageView.layer.cornerRadius = userImageView.frame.width / 2
                userImageView.clipsToBounds = true
                userImageView.tintColor = .darkGray
                userImageView.frame.size = CGSize(width: 40, height: 40)
                contentView.addSubview(userImageView)
                userImageViews.append(userImageView)

                // 调整 userImageView 的位置
                let xOffset = CGFloat(index) * (userImageView.frame.width + 5) // 5 是间距
                userImageView.frame.origin = CGPoint(x: planImageView.frame.origin.x + xOffset + 10, y: planImageView.frame.maxY + -50)
            }
        }
    
}
