//
//  EditPlanHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit

protocol EditPlanHeaderViewDelegate: AnyObject {
    func passDayCouts(number: Int)
}

class EditPlanHeaderView: UITableViewHeaderFooterView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: EditPlanHeaderViewDelegate?
    var days: [String] = ["第1天", "＋"]
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Set scroll direction to horizontal
        layout.minimumLineSpacing = 10 // Adjust spacing between items if needed

        let collectionView = UICollectionView(
            frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 50),
            collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false // Optionally, hide horizontal scroll indicator
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
        collectionView.scrollToItem(at: IndexPath(item: indexPath.item + 1, section: 0), at: .right, animated: true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ButtonCell.reuseIdentifier,
            for: indexPath) as? ButtonCell else {
              fatalError("Failed to create ButtonCell")
          }

          cell.configure(with: days[indexPath.item], indexPath: indexPath) {
              if indexPath.item == self.days.count - 1 {
                  self.addNewDay(at: indexPath)
              } else {
              }
          }
          return cell
        }
      
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 50)
    }
    
    // Handle button tap to add a new day
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == days.count - 1 {
            addNewDay(at: indexPath)
                   collectionView.reloadData()
                   collectionView.scrollToItem(
                    at: IndexPath(item: indexPath.item + 1, section: 0),
                    at: .right, animated: true)
        } else {
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
