//
//  ProfileHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

protocol ProfileHeaderViewDelegate: AnyObject {
    func change(to index: Int)
}

class ProfileHeaderView: UITableViewHeaderFooterView {
    
    var selectedIndex = 0
    var delegate: ProfileHeaderViewDelegate?
    
    override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }

        func commonInit() {
            let codeSegmented = CustomSegmentedControl(
                frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50),
                buttonTitle: ["旅遊回憶", "行程"])
            codeSegmented.backgroundColor = .clear
            codeSegmented.delegate = self
            contentView.addSubview(codeSegmented)
        }
}

extension ProfileHeaderView: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        selectedIndex = index
        delegate?.change(to: index)
    }
}
