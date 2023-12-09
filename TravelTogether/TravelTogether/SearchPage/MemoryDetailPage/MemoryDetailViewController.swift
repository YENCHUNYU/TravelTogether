//
//  MemoryDetailViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore
import Photos
import FirebaseAuth
class MemoryDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [], userId: "")
    var travelPlanId = ""
    var dayCounts = 1
    var days: [String] = ["第1天"]
    let headerView = EditMemoryHeaderView(reuseIdentifier: "EditMemoryHeaderView")
    var memoryPhotos: [String] = []
    var currentIndexPath: IndexPath?
    var memoryId = ""
    var userId = ""

    private var itemsPerRow: CGFloat = 2
    private var sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    lazy var copyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "doc.on.doc.fill"), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(copyPlan), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
    }()
    
    @objc func copyPlan() {
        let firestoreFetch = FirestoreManagerForOne()
        firestoreFetch.fetchOneTravelPlan(userId: userId, byId: memoryId) { (memory, error) in
            if let error = error {
                print("Error fetching one memory: \(error)")
            } else if let memory = memory {
                print("Fetched one memory: \(memory)")
                self.onePlan = memory
                self.tableView.reloadData()
            } else {
                print("One memory not found.")
            }
        }
        let firestorePost = FirestoreManagerForPost()
        firestorePost.postFullPlan(plan: self.onePlan)  { error in
            if let error = error {
                print("Error fetching one plan: \(error)")
            } else {
                print("One plan not found.")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(copyButton)
        setUpButton()
        tableView.dataSource = self
        tableView.delegate = self
//        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 300

        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
//        headerView.delegate = self
        headerView.travelPlanId = travelPlanId
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        
        tableView.dragInteractionEnabled = true
        
        let firestoreManagerForOne = FirestoreManagerFetchMemory()
        firestoreManagerForOne.fetchOneMemoryFromSearch(byId: memoryId, userId: userId) { (memory, error) in
                        if let error = error {
                            print("Error fetching one memory: \(error)")
                        } else if let memory = memory {
                            print("Fetched one memory: \(memory)")
                            self.onePlan = memory
                            self.tableView.reloadData()
                        } else {
                            print("One memory not found.")
                        }
                    }
    }
    func setUpButton() {
        copyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firestoreManagerForOne = FirestoreManagerFetchMemory()
        firestoreManagerForOne.fetchOneMemoryFromSearch(byId: memoryId, userId: userId) { (memory, error) in
                        if let error = error {
                            print("Error fetching one memory: \(error)")
                        } else if let memory = memory {
                            print("Fetched one memory: \(memory)")
                            self.onePlan = memory
                            self.tableView.reloadData()
                        } else {
                            print("One memory not found.")
                        }
                    }
    }
}

extension MemoryDetailViewController: UITableViewDataSource, UITextViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        onePlan.days.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "第\(section + 1)天"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !onePlan.days.isEmpty, section < onePlan.days.count else {
               return 0
           }
           return onePlan.days[section].locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MemoryDetailCell",
            for: indexPath) as? MemoryDetailCell
        else { fatalError("Could not create MemoryDetailCell") }
currentIndexPath = indexPath
        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.addressLabel.text = location.address
        cell.articleTextView.text = location.article
        cell.memoryCollectionView.dataSource = self
        cell.memoryCollectionView.delegate = self
//        cell.imageCollectionData = onePlan.days[indexPath.section].locations[indexPath.row].memoryPhotos ?? []
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Set scroll direction to horizontal
        layout.minimumLineSpacing = 10
        
        cell.memoryCollectionView.collectionViewLayout = layout
        cell.memoryCollectionView.showsHorizontalScrollIndicator = false
        cell.memoryCollectionView.tag = indexPath.section * 1000 + indexPath.row
        cell.memoryCollectionView.reloadData()
        cell.articleTextView.tag = indexPath.section * 1000 + indexPath.row
        cell.articleTextView.delegate = self
        return cell
    }
}

extension MemoryDetailViewController: UITableViewDelegate {
//    func tableView(
//        _ tableView: UITableView,
//        heightForRowAt indexPath: IndexPath) -> CGFloat {
//            330
//    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

}

//extension MemoryDetailViewController: EditMemoryHeaderViewDelegate {
//    
//    func passDays(daysData: [String]) {
//        self.days = daysData
//    }
//    
//    func reloadData() {
//        let firestoreManagerForOne = FirestoreManagerForOne()
////        firestoreManagerForOne.delegate = self
//        firestoreManagerForOne.fetchOneTravelPlan(userId: Auth.auth().currentUser?.uid ?? "", byId: travelPlanId) { (travelPlan, error) in
//            if let error = error {
//                print("Error fetching one travel plan: \(error)")
//            } else if let travelPlan = travelPlan {
//                self.onePlan = travelPlan
//                self.tableView.reloadData()
//                self.headerView.collectionView.reloadData()
//            } else {
//                print("One travel plan not found.")
//            }
//        }
//    }
//}

extension MemoryDetailViewController: UICollectionViewDataSource,
                                        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dayIndex = collectionView.tag / 1000
        let locationIndex = collectionView.tag % 1000
        if onePlan.days.isEmpty == false && onePlan.days[dayIndex].locations.isEmpty == false {
               let memoryLocation = onePlan.days[dayIndex].locations[locationIndex]
               return (memoryLocation.memoryPhotos?.count ?? 0)
           } else {
               return 0
           }
       }

   func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "MemoryCollectionViewCell",
            for: indexPath) as? MemoryCollectionViewCell else {
               fatalError("Failed to dequeue ImageCollectionViewCell")
           }
           
           let firestorageDownload = FirebaseStorageManagerDownloadPhotos()
//           firestorageDownload.delegate = self

           // cell 在image download前被reuse 而產生相同照片的cell
           guard let currentSection = currentIndexPath?.section,
             let currentRow = currentIndexPath?.row,
             currentSection < onePlan.days.count,
             currentRow < onePlan.days[currentSection].locations.count,
             let memoryPhotos = onePlan.days[currentSection].locations[currentRow].memoryPhotos else {
           return cell
       }
           let imageIndex = indexPath.item // Subtract 1 because the first item is the "AddPhotoCell"
            let imageURLString = memoryPhotos[imageIndex]

               if let url = URL(string: imageURLString) {
//           for image in memoryPhotos {
//               if let url = URL(string: image) {
                   let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                   firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                       DispatchQueue.main.async {
                           if let image = image {
                               cell.memoryImageView.image = image
                           } else {
                               cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                           }
                       }

           }}
           return cell
       
   }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthperItem: CGFloat = 0
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
            widthperItem = availableWidth / 1.1
        return CGSize(width: widthperItem, height: 170)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}
