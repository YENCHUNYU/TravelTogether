//
//  PlanDetailViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/10.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import SwiftEntryKit
import NVActivityIndicatorView

class PlanDetailViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = ""
    var dayCounts = 1
    var selectedSectionForAddLocation = 0 // 新增景點
    var days: [String] = ["第1天"]
    let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
    var userId = ""
    var isFromFavorite = false
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 50, height: 50),
              type: .ballBeat,
              color: UIColor(named: "darkGreen") ?? .white,
              padding: 0
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
        firestoreFetch.fetchOneTravelPlan(userId: userId, byId: travelPlanId) { (memory, error) in
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
        firestorePost.postPlanToFavorite(memory: self.onePlan) { error in
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
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        
        // tableView header
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        //        headerView.delegate = self
        headerView.travelPlanId = travelPlanId
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        print("travelPlanId\(travelPlanId)")
        if isFromFavorite == false {
            let firestoreManagerForOne = FirestoreManagerForOne()
            //        firestoreManagerForOne.delegate = self
            firestoreManagerForOne.fetchOneTravelPlan(userId: userId, byId: travelPlanId) { (travelPlan, error) in
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
            }} else {
                let firestoreManagerForOne = FirestoreManagerForOne()
                //        firestoreManagerForOne.delegate = self
                userId = Auth.auth().currentUser?.uid ?? ""
                firestoreManagerForOne.fetchOneTravelPlanFromFavorite(userId: userId, byId: travelPlanId) { (travelPlan, error) in
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
            }}
    
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
            let firestoreManagerForOne = FirestoreManagerForOne()
            //        firestoreManagerForOne.delegate = self
            firestoreManagerForOne.fetchOneTravelPlan(userId: userId, byId: travelPlanId) { (travelPlan, error) in
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
            }} else {
                let firestoreManagerForOne = FirestoreManagerForOne()
                //        firestoreManagerForOne.delegate = self
                userId = Auth.auth().currentUser?.uid ?? ""
                firestoreManagerForOne.fetchOneTravelPlanFromFavorite(userId: userId, byId: travelPlanId) { (travelPlan, error) in
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

extension PlanDetailViewController: UITableViewDataSource {
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
            withIdentifier: "PlanDetailCell",
            for: indexPath) as? PlanDetailCell
        else { fatalError("Could not create PlanDetailCell") }

        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.placeAddressLabel.text = location.address
        let firestorage = FirebaseStorageManagerDownloadPhotos()
        let urlString = location.photo
        
        // Record the URL being processed by this cell
        cell.currentImageUrl = urlString
        
        if !urlString.isEmpty, let url = URL(string: urlString) {
            firestorage.downloadPhotoFromFirebaseStorage(url: url) { image in
                DispatchQueue.main.async {
                    // Check if the URL still matches the current cell's URL
                    if cell.currentImageUrl == urlString {
                        if let image = image {
                            cell.locationImageView.image = image
                            self.activityIndicatorView.stopAnimating()
                            self.blurEffectView.removeFromSuperview()
                            self.activityIndicatorView.removeFromSuperview()
                        } else {
                            cell.locationImageView.image = UIImage(named: "Image_Placeholder")
                        }
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
}

extension PlanDetailViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            100
    }
}
