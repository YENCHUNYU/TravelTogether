//
//  EditMemoryHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//
import UIKit

protocol EditMemoryHeaderViewDelegate: AnyObject {
    func reloadData()
    func passDays(daysData: [String])
    }

class EditMemoryHeaderView:
    UITableViewHeaderFooterView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: EditMemoryHeaderViewDelegate?
    var days: [String] = ["第1天"]
    var travelPlanId = ""
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Set scroll direction to horizontal
        layout.minimumLineSpacing = 10 // Adjust spacing between items if needed

        let collectionView = UICollectionView(
            frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 50),
            collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = true
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.reuseIdentifier)
        
        collectionView.backgroundColor = UIColor(named: "yellowGreen")
        return collectionView
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        addSubview(collectionView)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        cell.configure(with: days[indexPath.item], indexPath: indexPath) {}
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
    }
}

extension EditMemoryHeaderView: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
    }
}
