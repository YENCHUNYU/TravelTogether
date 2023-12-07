//
//  PlanHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

protocol PlanHeaderViewDelegate: AnyObject {
    func change(to index: Int)
}

class PlanHeaderView: UITableViewHeaderFooterView {
    
    var selectedIndex = 0
    var delegate: PlanHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }

        func commonInit() {
            let separator = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.5))
               separator.backgroundColor = UIColor.lightGray
               contentView.addSubview(separator)
            
            let codeSegmented = CustomSegmentedControl(
                frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50),
                buttonTitle: ["我的行程", "共同行程"])
            codeSegmented.backgroundColor = .clear
            codeSegmented.delegate = self
            contentView.addSubview(codeSegmented)
        }
}

extension PlanHeaderView: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        selectedIndex = index
        delegate?.change(to: index)
    }
}
