//
//  EditPlanHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit

//protocol EditPlanHeaderViewDelegate: AnyObject {
//    func change(to index: Int)
//    func passButtonCount(number: Int)
//}

//class EditPlanHeaderView: UITableViewHeaderFooterView {
    
//    var selectedIndex = 0
//    var delegate: EditPlanHeaderViewDelegate?
//    var buttons: [String] = ["第1天", "+"]
//    var codeSegmented = CustomSegmentedControl(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50), buttonTitle: ["第1天", "+"])
//
//    override init(reuseIdentifier: String?) {
//            super.init(reuseIdentifier: reuseIdentifier)
//            commonInit()
//        }
//
//        required init?(coder: NSCoder) {
//            super.init(coder: coder)
//            commonInit()
//        }
//
//        func commonInit() {
//            let separator = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0.5))
//               separator.backgroundColor = UIColor.lightGray
//               contentView.addSubview(separator)
//
//            codeSegmented.backgroundColor = .clear
//            codeSegmented.delegate = self
//            contentView.addSubview(codeSegmented)
//
//            let searchBar = UITextField(frame: CGRect(x: 20, y: codeSegmented.frame.maxY + 10, width: UIScreen.main.bounds.width - 75, height: 40))
//                searchBar.placeholder = "搜尋"
//                searchBar.borderStyle = .roundedRect
//                contentView.addSubview(searchBar)
//
//            let searchButton = UIButton(type: .system)
//            searchButton.frame = CGRect(x: UIScreen.main.bounds.width - 50 , y: codeSegmented.frame.maxY + 10, width: 30, height: 40)
//
//            let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular)
//            let searchImage = UIImage(systemName: "magnifyingglass.circle.fill", withConfiguration: imageConfiguration)
//            searchButton.setImage(searchImage, for: .normal)
//
//            searchButton.tintColor = .black
//            searchButton.imageView?.contentMode = .scaleAspectFit
//            contentView.addSubview(searchButton)

//        }
    
//    var collectionView: UICollectionView = {
//        // Create a layout for the collection view
//        let layout = UICollectionViewFlowLayout()
//
//        // Create the collection view using the designated initializer
//        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100), collectionViewLayout: layout)
//
//        collectionView.backgroundColor = .lightGray
//        return collectionView
//    }()
//
//}

//extension EditPlanHeaderView: CustomSegmentedControlDelegate {
//    func change(to index: Int) {
//        selectedIndex = index
//        if index == buttons.count - 1 {
//            buttons.insert("第\(buttons.count)天", at: buttons.count - 1)
//            codeSegmented.setButtonTitles(buttonTitles: buttons)
//            selectedIndex = index
//            delegate?.passButtonCount(number: buttons.count - 1 )
//        } else {
//            delegate?.change(to: index)
//        }
//    }
    
//}

protocol EditPlanHeaderViewDelegate: AnyObject {
    func passDayCouts(number: Int)
}

class EditPlanHeaderView: UITableViewHeaderFooterView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: EditPlanHeaderViewDelegate?
    var days: [String] = ["第1天", "＋"]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 50), collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.reuseIdentifier)
        return collectionView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addNewDay(at indexPath: IndexPath) {
        let newDay = "第\(days.count)天"
        days.insert(newDay, at: days.count - 1)
        delegate?.passDayCouts(number: days.count - 1)
        collectionView.reloadData()
        // You may also want to scroll to the newly added day for better visibility
        collectionView.scrollToItem(at: IndexPath(item: indexPath.item + 1, section: 0), at: .right, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ButtonCell.reuseIdentifier, for: indexPath) as? ButtonCell else {
              fatalError("Failed to create ButtonCell")
          }

          cell.configure(with: days[indexPath.item], indexPath: indexPath) {
              if indexPath.item == self.days.count - 1 {
                  // If the last item (the "Add Day" button) is tapped
                  self.addNewDay(at: indexPath)
              } else {
                  // Handle tap on an existing day button if needed
              }
          }

          return cell
        }
    
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Adjust the size based on your requirements
        return CGSize(width: 60, height: 50)
    }
    
    // Handle button tap to add a new day
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == days.count - 1 {
            addNewDay(at: indexPath)
                   collectionView.reloadData()
                   collectionView.scrollToItem(at: IndexPath(item: indexPath.item + 1, section: 0), at: .right, animated: true)
        } else {
            // Handle tap on an existing day button if needed
        }
    }
}

class ButtonCell: UICollectionViewCell {
    static let reuseIdentifier = "ButtonCell"
    
    private var buttonTapHandler: (() -> Void)?
    
    let button: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    var indexPath: IndexPath?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.frame = bounds
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
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
