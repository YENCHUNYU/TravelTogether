//
//  MemoryHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

protocol MemoryHeaderViewDelegate: AnyObject {
    func change(to index: Int)
}

class MemoryHeaderView: UITableViewHeaderFooterView {
    
    var selectedIndex = 0
    var delegate: MemoryHeaderViewDelegate?
    
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
                buttonTitle: ["已發佈", "草稿"])
            codeSegmented.backgroundColor = .clear
            codeSegmented.delegate = self
            contentView.addSubview(codeSegmented)
        }
}

extension MemoryHeaderView: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        selectedIndex = index
        delegate?.change(to: index)
    }
}
