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
             
//            let searchBar = UITextField(frame: CGRect(
//                x: 20, y: codeSegmented.frame.maxY + 10,
//                width: UIScreen.main.bounds.width - 75, height: 40))
//                searchBar.placeholder = "搜尋旅遊回憶"
//                searchBar.borderStyle = .roundedRect
//                contentView.addSubview(searchBar)
//            
//            let searchButton = UIButton(type: .system)
//            searchButton.frame = CGRect(
//                x: UIScreen.main.bounds.width - 50,
//                y: codeSegmented.frame.maxY + 10,
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

extension MemoryHeaderView: CustomSegmentedControlDelegate {
    func change(to index: Int) {
        selectedIndex = index
        delegate?.change(to: index)
    }
}
