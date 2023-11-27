//
//  EditPlanHeaderForSections.swift
//  TravelTogether
//
//  Created by User on 2023/11/27.
//
import UIKit

class EditPlanHeaderViewForSection: UITableViewHeaderFooterView {

    var deleteButtonHandler: (() -> Void)?

    lazy var deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("刪除", for: .normal)
        button.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.gray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupDeleteButton()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupDeleteButton()
    }

    private func setupDeleteButton() {
        addSubview(deleteButton)
        NSLayoutConstraint.activate([
            deleteButton.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
            deleteButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }

    @objc func deleteButtonTapped() {
        deleteButtonHandler?()
    }
}
