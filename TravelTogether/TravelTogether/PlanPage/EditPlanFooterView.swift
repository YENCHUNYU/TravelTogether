//
//  EditPlanFooterView.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit

class EditPlanFooterView: UITableViewHeaderFooterView {
    
    let createNewPlanButton: UIButton = {
        let create = UIButton()
        create.translatesAutoresizingMaskIntoConstraints = false
        create.setTitle("新增景點", for: .normal)
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
        contentView.addSubview(createNewPlanButton)
        createNewPlanButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        createNewPlanButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    }
    
}
