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
    var days: [String] = ["第1天"]
    let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
    var userId = ""
    var isFromFavorite = false
    var dbCollection = "TravelPlan"
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
        type: .ballBeat,
        color: UIColor(named: "darkGreen") ?? .white,
        padding: 0
    )
    var blurEffectView: UIVisualEffectView!
    var isFromProfile = false
    
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
        if !LoginViewController.loginStatus {
            if let loginVC = storyboard?.instantiateViewController(
                withIdentifier: "LoginViewController") as? LoginViewController {
                let loginNavController = UINavigationController(rootViewController: loginVC)
                present(loginNavController, animated: true, completion: nil)
            }
        } else {
            fetchUserInfo()
            postAPlanToDB()
        }
    }
    
    func fetchUserInfo() {
        let firestore = FirestoreManagerFetchUser()
        firestore.fetchUserInfo{ userData, error  in
            if error != nil {
                print("Error fetching one plan: \(String(describing: error))")
            } else {
                self.onePlan.user = userData?.name
                self.onePlan.userPhoto = userData?.photo
                self.onePlan.userId = userData?.id
            }
        }
    }
    
    func postAPlanToDB() {
        let firestorePost = FirestoreManagerForPost()
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

    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
    }
    
    func configureTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configureHeaderView() {
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.travelPlanId = travelPlanId
        tableView.tableHeaderView = headerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlurEffectView()
        configureTableView()
        view.addSubview(copyButton)
        setUpButton()
        configureHeaderView()
        fetchAPlan()
    }
    func fetchAPlan() {
        dbCollection = "TravelPlan"
        let firestoreManagerForOne = FirestoreManagerForOne()
        userId = Auth.auth().currentUser?.uid ?? ""
        firestoreManagerForOne.fetchOneTravelPlan(dbCollection: dbCollection, userId: userId, byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
                self.configureDays()
                self.tableView.reloadData()
                let allDaysHaveNoLocations = self.onePlan.days.allSatisfy { $0.locations.isEmpty }

                    if allDaysHaveNoLocations {
                        self.removeLoadingView()
                    }
            } else {
                print("One travel plan not found.")
            }
        }
    }
    
    func configureDays() {
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
    }
    
    func swiftEntryKit(titleText: String, descriptText: String, imageString: String) {
        var attributes = EKAttributes.topFloat
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
    }
    
    func addLoadingView() {
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func removeLoadingView() {
        self.activityIndicatorView.stopAnimating()
        self.blurEffectView.removeFromSuperview()
        self.activityIndicatorView.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadingView()
        fetchAPlan()
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
        let urlString = location.photo
        cell.currentImageUrl = urlString
        loadMemoryImage(with: urlString, cell: cell)
        return cell
    }
    
    func loadMemoryImage(with urlString: String, cell: PlanDetailCell) {

        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            removeLoadingView()
            return
        }

        cell.locationImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Image_Placeholder"),
            options: [
                .transition(.fade(0.2)),
                .cacheOriginalImage
            ],
            completionHandler: { _ in
                self.removeLoadingView()
            }
        )
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
