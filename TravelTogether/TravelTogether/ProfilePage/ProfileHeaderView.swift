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
     
//            let searchBar = UITextField(frame: CGRect(
//                x: 20, y: codeSegmented.frame.maxY + 10,
//                width: UIScreen.main.bounds.width - 75, height: 40))
//                searchBar.placeholder = "搜尋"
//                searchBar.borderStyle = .roundedRect
//                contentView.addSubview(searchBar)
//            
//            let searchButton = UIButton(type: .system)
//            searchButton.frame = CGRect(
//                x: UIScreen.main.bounds.width - 50, y: codeSegmented.frame.maxY + 10,
//                width: 30, height: 40)
//
//            let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
//            let searchImage = UIImage(systemName: "magnifyingglass.circle.fill", withConfiguration: imageConfiguration)
//            searchButton.setImage(searchImage, for: .normal)
//
//            searchButton.tintColor = .black
//            searchButton.imageView?.contentMode = .scaleAspectFit
//            contentView.addSubview(searchButton)
        }
}

extension ProfileHeaderView: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        selectedIndex = index
        delegate?.change(to: index)
    }
}
