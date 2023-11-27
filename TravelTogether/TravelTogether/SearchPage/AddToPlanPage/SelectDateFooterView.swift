//
//  SelectDateFooterView.swift
//  TravelTogether
//
//  Created by User on 2023/11/27.
//

import UIKit

class SelectDateFooterView: UITableViewHeaderFooterView {
    
    let createNewDayButton: UIButton = {
        let create = UIButton()
        create.translatesAutoresizingMaskIntoConstraints = false
        create.setTitle("新增天數", for: .normal)
        create.backgroundColor = .lightGray
        return create
    }()
    
    override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            commonInit()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            commonInit()
        }
    
    func commonInit() {
        contentView.addSubview(createNewDayButton)
        createNewDayButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        createNewDayButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    }
    
}
