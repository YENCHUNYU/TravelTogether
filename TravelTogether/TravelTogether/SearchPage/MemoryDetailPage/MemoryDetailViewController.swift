//
//  MemoryDetailViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import SwiftEntryKit
import NVActivityIndicatorView

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
    var isFromFavorite = false

    private var itemsPerRow: CGFloat = 2
    private var sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
        type: .ballBeat, color: UIColor(named: "darkGreen") ?? .white, padding: 0
          )
    var blurEffectView: UIVisualEffectView!
    
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
        self.onePlan.user = Auth.auth().currentUser?.displayName
        self.onePlan.userPhoto = Auth.auth().currentUser?.photoURL?.absoluteString
        self.onePlan.userId = Auth.auth().currentUser?.uid
        firestorePost.postFullPlan(plan: self.onePlan) { error in
            if let error = error {
                print("Error fetching one plan: \(error)")
            } else {
                let copyTitle = "已成功複製到我的行程！"
                let copyDescript = "請前往「我的行程」查看。"
                let copyImage = "doc.on.doc.fill"
                self.swiftEntryKit(titleText: copyTitle, descriptText: copyDescript, imageString: copyImage)
                print("One plan was added.")
            }
        }
    }
    
    lazy var likeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(likeMemory), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
    }()
    
    @objc func likeMemory() {

        let firestorePost = FirestoreManagerFavorite()
//        self.onePlan.user = Auth.auth().currentUser?.displayName
//        self.onePlan.userPhoto = Auth.auth().currentUser?.photoURL?.absoluteString
//        self.onePlan.userId = Auth.auth().currentUser?.uid
        firestorePost.postMemoryToFavorite(memory: self.onePlan) { error in
            if let error = error {
                print("Error fetching one favorite: \(error)")
            } else {
                let likeTitle = "收藏成功！"
                let likeDescript = "請前往「收藏」查看。"
                let likeImage = "heart.fill"
        self.swiftEntryKit(titleText: likeTitle, descriptText: likeDescript, imageString: likeImage)
                print("One favorite was added.")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        
        view.addSubview(copyButton)
        view.addSubview(likeButton)
        setUpButton()
        tableView.dataSource = self
        tableView.delegate = self

        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
//        headerView.delegate = self
        headerView.travelPlanId = travelPlanId
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        
        tableView.dragInteractionEnabled = true
        
        if isFromFavorite == false {
            let firestoreManagerForOne = FirestoreManagerFetchMemory()
            firestoreManagerForOne.fetchOneMemoryFromSearch(byId: memoryId, userId: userId) { (memory, error) in
                if let error = error {
                    print("Error fetching one travel plan: \(error)")
                } else if let memory = memory {
                    print("Fetched one travel plan: \(memory)")
                    self.onePlan = memory
                    let counts = self.onePlan.days.count
                    let originalCount = self.days.count
                    if counts > originalCount {
                        for _ in originalCount...counts - 1 {
                            let number = self.days.count
                            self.days.insert("第\(number + 1)天", at: number)
                        }
                    }
                    self.headerView.days = self.days
                    self.headerView.onePlan = self.onePlan
                    self.headerView.collectionView.reloadData()
                    self.tableView.reloadData()
                } else {
                    print("One travel plan not found.")
                }
            }} else {
                let firestoreManagerForOne = FirestoreManagerFetchMemory()
                firestoreManagerForOne.fetchOneMemoryFromFavorite(byId: memoryId) { (travelPlan, error) in
                    if let error = error {
                        print("Error fetching one travel plan: \(error)")
                    } else if let travelPlan = travelPlan {
                        print("Fetched one travel plan: \(travelPlan)")
                        self.onePlan = travelPlan
                        let counts = self.onePlan.days.count
                        let originalCount = self.days.count
                        if counts > originalCount {
                            for _ in originalCount...counts - 1 {
                                let number = self.days.count
                                self.days.insert("第\(number + 1)天", at: number)
                            }
                        }
                        self.headerView.days = self.days
                        self.headerView.onePlan = self.onePlan
                        self.headerView.collectionView.reloadData()
                        self.tableView.reloadData()
                    } else {
                        print("One travel plan not found.")
                    }
                }
            }
    }
    
    func swiftEntryKit(titleText: String, descriptText: String, imageString: String) {
        // Generate top floating entry and set some properties
        var attributes = EKAttributes.topFloat
//        attributes.entryBackground = .gradient(gradient: .init(colors: [EKColor(.red), EKColor(.green)], startPoint: .zero, endPoint: CGPoint(x: 1, y: 1)))
        attributes.entryBackground = .color(color: EKColor(UIColor(named: "darkGreen") ?? .white))
        attributes.popBehavior = .animated(animation: .init(translate: .init(duration: 5), scale: .init(from: 1, to: 0.7, duration: 0.7)))
        attributes.shadow = .active(with: .init(color: .black, opacity: 0.5, radius: 10, offset: .zero))
        attributes.statusBar = .dark
        attributes.scroll = .enabled(swipeable: true, pullbackAnimation: .jolt)
        attributes.positionConstraints.maxSize = .init(width: .constant(value: UIScreen.main.bounds.width - 40), height: .intrinsic)

        let title = EKProperty.LabelContent(text: titleText, style: .init(font: UIFont.systemFont(ofSize: 14, weight: .light), color: .white))
        let description = EKProperty.LabelContent(text: descriptText, style: .init(font: UIFont.systemFont(ofSize: 12, weight: .light), color: EKColor(UIColor(named: "yellowGreen") ?? .white) ))
        var image = EKProperty.ImageContent(image: UIImage(systemName: imageString) ?? UIImage(), size: CGSize(width: 35, height: 35))
        image.tint = .white
        let simpleMessage = EKSimpleMessage(image: image, title: title, description: description)
        let notificationMessage = EKNotificationMessage(simpleMessage: simpleMessage)

        let contentView = EKNotificationMessageView(with: notificationMessage)
        SwiftEntryKit.display(entry: contentView, using: attributes)
    }
    
    func setUpButton() {
        copyButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        copyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        likeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        likeButton.trailingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: -10).isActive = true
    }
 
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        if isFromFavorite == false {
            let firestoreManagerForOne = FirestoreManagerFetchMemory()
            firestoreManagerForOne.fetchOneMemoryFromSearch(byId: memoryId, userId: userId) { (memory, error) in
                if let error = error {
                    print("Error fetching one travel plan: \(error)")
                } else if let memory = memory {
                    print("Fetched one travel plan: \(memory)")
                    self.onePlan = memory
                    let counts = self.onePlan.days.count
                    let originalCount = self.days.count
                    if counts > originalCount {
                        for _ in originalCount...counts - 1 {
                            let number = self.days.count
                            self.days.insert("第\(number + 1)天", at: number)
                        }
                    }
                    self.headerView.days = self.days
                    self.headerView.onePlan = self.onePlan
                    self.headerView.collectionView.reloadData()
                    self.tableView.reloadData()
                } else {
                    print("One travel plan not found.")
                }
            }} else {
                let firestoreManagerForOne = FirestoreManagerFetchMemory()
                firestoreManagerForOne.fetchOneMemoryFromFavorite(byId: memoryId) { (travelPlan, error) in
                    if let error = error {
                        print("Error fetching one travel plan: \(error)")
                    } else if let travelPlan = travelPlan {
                        print("Fetched one travel plan: \(travelPlan)")
                        self.onePlan = travelPlan
                        let counts = self.onePlan.days.count
                        let originalCount = self.days.count
                        if counts > originalCount {
                            for _ in originalCount...counts - 1 {
                                let number = self.days.count
                                self.days.insert("第\(number + 1)天", at: number)
                            }
                        }
                        self.headerView.days = self.days
                        self.headerView.onePlan = self.onePlan
                        self.headerView.collectionView.reloadData()
                        self.tableView.reloadData()
                    } else {
                        print("One travel plan not found.")
                    }
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }

}

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
                   let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                   firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                       DispatchQueue.main.async {
                           if let image = image {
                               cell.memoryImageView.image = image
                               self.activityIndicatorView.stopAnimating()
                               self.blurEffectView.removeFromSuperview()
                               self.activityIndicatorView.removeFromSuperview()
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
