//
//  EditPlanHeaderView.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit

protocol EditPlanHeaderViewDelegate: AnyObject {
    func passDays(daysData: [String])
    func reloadNewData()
}

class EditPlanHeaderView: UITableViewHeaderFooterView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: EditPlanHeaderViewDelegate?
    var days: [String] = ["第1天", "＋"]
    var travelPlanId = ""
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10

        let collectionView = UICollectionView(
            frame: CGRect(x: 10, y: 0, width: UIScreen.main.bounds.width - 20, height: 50),
            collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ButtonCell.self, forCellWithReuseIdentifier: ButtonCell.reuseIdentifier)
        collectionView.dragInteractionEnabled = true
        collectionView.dragDelegate = self
        collectionView.dropDelegate = self
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

    func addNewDay(at indexPath: IndexPath) {
        let newDay = "第\(days.count)天"
        days.insert(newDay, at: days.count - 1)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(item: indexPath.item + 1, section: 0), at: .right, animated: true)
        self.delegate?.passDays(daysData: days)
    }
    
    func addNewDayButtonTapped() {
        let firestoreManager = FirestoreManagerForPostDay()
        firestoreManager.addDayToTravelPlan(planId: travelPlanId) { error in
            if let error = error {
                print("Error posting day: \(error)")
            } else {
                print("Day posted successfully!\(self.days.count - 1)")
                self.delegate?.reloadNewData()
            }
        }
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
                  self.addNewDayButtonTapped()
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
}

extension EditPlanHeaderView: UICollectionViewDragDelegate, UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, 
                        itemsForBeginning session: UIDragSession,
                        at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.days[indexPath.item]
        let itemProvider = NSItemProvider(object: item as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        // 返回true表示可以處理拖放
        return session.localDragSession != nil
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        dropSessionDidUpdate session: UIDropSession,
                        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, 
                        performDropWith coordinator: UICollectionViewDropCoordinator) {
        if let destinationIndexPath = coordinator.destinationIndexPath {
            var updatedIndexPaths = [IndexPath]()
            collectionView.performBatchUpdates({
                let item = coordinator.items[0]
                if let sourceIndexPath = item.sourceIndexPath {
                    guard sourceIndexPath.row < self.days.count - 1,
                          destinationIndexPath.row < self.days.count - 1 else {
                            return  // sourceIndexPath.row 超出範圍，不執行相應的代碼
                        }
                    if sourceIndexPath.row != destinationIndexPath.row {  
                        let movedDay = self.days.remove(at: sourceIndexPath.item)
                        self.days.insert(movedDay, at: destinationIndexPath.item)
                        collectionView.moveItem(at: sourceIndexPath, to: destinationIndexPath)
                        if sourceIndexPath.row <= self.onePlan.days.count - 1 {
                            let dayData = self.onePlan.days[sourceIndexPath.row]
                            self.onePlan.days.remove(at: sourceIndexPath.row)
                            self.onePlan.days.insert(
                                dayData, at: destinationIndexPath.row)
                            updatedIndexPaths.append(destinationIndexPath)
                            postNewDay()
                        }
                    }
                }
            }, completion: { _ in // 拖放操作動畫完成後，重新載入數據
                DispatchQueue.main.async {
                   self.collectionView.reloadData()
               }
            })
        }
    }
    
    func postNewDay() {
        let firestoreMangerPostDay = FirestoreManagerForPostDay()
        firestoreMangerPostDay.postNewDaysArray(
            planId: travelPlanId,
            newDaysArray: self.onePlan.days) { error in
            if error != nil {
                print("Failed to reorder the days")
            } else {
                print("Reorder the days successfully!")
                self.delegate?.reloadNewData()
            }
        }
    }
}
