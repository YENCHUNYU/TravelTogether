//
//  EditPlanCollectionCell.swift
//  TravelTogether
//
//  Created by User on 2023/11/27.
//

import UIKit

class ButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "ButtonCell"
    
    private var buttonTapHandler: (() -> Void)?
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(named: "darkGray"), for: .normal)
        return button
    }()
    
    var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.frame = bounds
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button.backgroundColor = UIColor(named: "yellowGreen")
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with title: String, indexPath: IndexPath, tapHandler: @escaping () -> Void) {
        button.setTitle(title, for: .normal)
        self.indexPath = indexPath
        buttonTapHandler = tapHandler
    }
    
    @objc private func buttonTapped() {
        buttonTapHandler?()
    }
}
