//
//  EditPlanFooterView.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit

class EditPlanFooterView: UITableViewHeaderFooterView {
    
    let addNewLocationButton: UIButton = {
        let create = UIButton()
        create.translatesAutoresizingMaskIntoConstraints = false
        create.setTitle("  新增景點  ", for: .normal)
        create.backgroundColor = UIColor(red: 147/255, green: 177/255, blue: 166/255, alpha: 1)
        create.layer.cornerRadius = 10
        create.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
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
        contentView.addSubview(addNewLocationButton)
        addNewLocationButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 0).isActive = true
        addNewLocationButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
    }
    
}
