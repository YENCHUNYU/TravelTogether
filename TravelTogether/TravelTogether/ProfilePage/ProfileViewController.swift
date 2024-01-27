//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Kingfisher
import NVActivityIndicatorView

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var userImageView: UIImageView! {
        didSet {
            userImageView.layer.cornerRadius = 45
            userImageView.clipsToBounds = true
            userImageView.contentMode = .scaleAspectFill
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIntroduction: UILabel!
    @IBOutlet weak var followButton: UIButton! {
        didSet {
            followButton.layer.cornerRadius = 15
        }
    }
    @IBOutlet weak var fanNumberLabel: UILabel!
    @IBOutlet weak var fanLabel: UILabel!
    @IBOutlet weak var followNumberLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var profileIndex = 0
    var plans: [TravelPlan] = []
    var spotsData: [[String: Any]] = []
    var memories: [TravelPlan] = []
    var userInfo = UserInfo(email: "", name: "", id: "")
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: (UIScreen.main.bounds.height - 173) / 2 - 50, width: 50, height: 50),
        type: .ballBeat,
        color: UIColor(named: "darkGreen") ?? .white,
        padding: 0
    )
    let activityIndicatorViewFull = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
        type: .ballBeat, color: UIColor(named: "darkGreen") ?? .white, padding: 0
    )
    var blurEffectView: UIVisualEffectView!
    var blurEffectViewFull: UIVisualEffectView!
    var memoryId = ""
    var planId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlurEffectView()
        configureTableView()
        configureHeaderView()
        userNameLabel.text = ""
        fetchTravelPlans()
        fetchMemories()
        fetchUserInfo()
        configureRightButton()
    }
    
    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectViewFull = UIVisualEffectView(effect: blurEffect)
        blurEffectViewFull.frame = view.bounds
    }

    func configureTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configureHeaderView() {
        let headerView = ProfileHeaderView(reuseIdentifier: "ProfileHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
        tableView.tableHeaderView = headerView
    }
    
    func fetchTravelPlans() {
        let firestoreManager = FirestoreManager()
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
                if self.plans.isEmpty && self.profileIndex == 1 {
                    self.removeLoadingView(with: self.blurEffectView, by: self.activityIndicatorView)
                }
            }
        }
    }
    
    func fetchMemories() {
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
                if self.memories.isEmpty && self.profileIndex == 0 {
                    self.removeLoadingView(with: self.blurEffectView, by: self.activityIndicatorView)
                }
            }
        }
    }
    
    func fetchUserInfo() {
        let firestoreUser = FirestoreManagerFetchUser()
        firestoreUser.fetchUserInfo { (userInfo, error) in
            if let error = error {
                print("Error fetching UserInfo: \(error)")
            } else {
                print("Fetched UserInfo: \(String(describing: userInfo))")
                self.updateUserData(
                    with: userInfo ?? UserInfo(email: "", name: "", id: ""))
                
            }
        }
    }
    
    func updateUserData(with userInfo: UserInfo) {
        self.userInfo = userInfo
        self.userNameLabel.text = self.userInfo.name
        if let photoURLString = self.userInfo.photo, let photoURL = URL(string: photoURLString) {
            self.userImageView.kf.setImage(with: photoURL, placeholder: UIImage(systemName: "person.circle.fill"))
        } else {
            self.userImageView.image = UIImage(systemName: "person.circle.fill")
        }
        self.removeLoadingView(with: self.blurEffectViewFull, by: self.activityIndicatorViewFull)
    }
    
    func configureRightButton() {
        let rightButton = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain, target: self, 
            action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func rightButtonTapped() {
        if let settingVC = storyboard?.instantiateViewController(
            withIdentifier: "SettingViewController") as? SettingViewController {
            present(settingVC, animated: true, completion: nil)
            
            settingVC.signOutButtonTap = { [weak self] in
                if let tabBarController = self?.tabBarController {
                    tabBarController.selectedIndex = 0
                    self?.dismiss(animated: true)
                }
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    func addLoadingView(
        with loadingView: UIVisualEffectView,
        by indicator: NVActivityIndicatorView,
        on theView: UIView) {
        theView.addSubview(loadingView)
        theView.addSubview(indicator)
        indicator.startAnimating()
    }
    
    func removeLoadingView(
        with loadingView: UIVisualEffectView,
        by indicator: NVActivityIndicatorView) {
        indicator.stopAnimating()
        loadingView.removeFromSuperview()
        indicator.removeFromSuperview()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadingView(with: blurEffectViewFull, by: activityIndicatorViewFull, on: view)
        addLoadingView(with: blurEffectView, by: activityIndicatorView, on: tableView)
        fetchUserInfo()
        fetchTravelPlans()
        fetchMemories()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileIndex == 0 ? memories.count : plans.count
    }
    
    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if profileIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            configureMemoryCell(for: cell, in: indexPath)
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            configurePlanCell(for: cell, in: indexPath)
            return cell
        }
    }
    
    func configureMemoryCell(for cell: ProfileCell, in indexPath: IndexPath) {
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
            cell.memoryNameLabel.text = self.memories[indexPath.row].planName
        cell.memoryImageView.image = nil
        guard !memories.isEmpty else {
            removeLoadingView(with: blurEffectView, by: activityIndicatorView)
            return
        }

        let urlString = memories[indexPath.row].coverPhoto ?? ""

        loadMemoryImage(cell: cell, urlString: urlString)
    }
    
    func configurePlanCell(for cell: ProfileCell, in indexPath: IndexPath) {
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        cell.memoryImageView.image = nil
        cell.memoryNameLabel.text = self.plans[indexPath.row].planName
        let daysData = plans[indexPath.row].days
        if daysData.isEmpty == false {
            let locationData = daysData[0]
            let theLocation = locationData.locations
            guard theLocation.isEmpty == false else {
                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                self.removeLoadingView(with: blurEffectView, by: activityIndicatorView)
                return
            }
            let urlString = theLocation[0].photo
            guard let url = URL(string: urlString) else {
                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                self.removeLoadingView(with: blurEffectView, by: activityIndicatorView)
                return
            }
            loadMemoryImage(cell: cell, urlString: urlString)
        }
    }
       
    func loadMemoryImage(cell: ProfileCell, urlString: String) {
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            cell.memoryImageView.image =  UIImage(named: "Image_Placeholder")
            removeLoadingView(with: blurEffectView, by: activityIndicatorView)
            return
        }

        cell.memoryImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Image_Placeholder"),
            options: [
                .transition(.fade(0.2)), // Add a fade transition
                .cacheOriginalImage
            ],
            completionHandler: { _ in
                self.removeLoadingView(with: self.blurEffectView, by: self.activityIndicatorView)
            }
        )
    }
    func stopLoading() {
        self.activityIndicatorView.stopAnimating()
        self.blurEffectView.removeFromSuperview()
        self.activityIndicatorView.removeFromSuperview()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if profileIndex == 0 {
            memoryId = memories[indexPath.row].id
            performSegue(withIdentifier: "ProfileToMemory", sender: self)
        } else {
            planId = plans[indexPath.row].id
            performSegue(withIdentifier: "ProfileToPlan", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProfileToMemory" {
            if let destinationVC = segue.destination as? MemoryDetailViewController {
                destinationVC.memoryId = self.memoryId
                destinationVC.isFromProfile = true
            }
        }
        if segue.identifier == "ProfileToPlan" {
            if let destinationVC = segue.destination as? PlanDetailViewController {
                destinationVC.travelPlanId = self.planId
                destinationVC.isFromProfile = true
            }
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        230
    }
}

extension ProfileViewController: ProfileHeaderViewDelegate {
    func change(to index: Int) {
        addLoadingView(with: blurEffectView, by: activityIndicatorView, on: tableView)
        profileIndex = index
        tableView.reloadData()
        if plans.isEmpty && profileIndex == 1 {
            removeLoadingView(with: blurEffectView, by: activityIndicatorView)
        }
        if memories.isEmpty && profileIndex == 0 {
            removeLoadingView(with: blurEffectView, by: activityIndicatorView)
        }
    }
}
