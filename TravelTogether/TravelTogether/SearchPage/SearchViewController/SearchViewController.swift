//
//  SearchViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Kingfisher
import AuthenticationServices
import NVActivityIndicatorView

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var searchIndex = 0
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    var spotsData: [[String: Any]] = []
    var memories: [TravelPlan] = []
    var memoryId = ""
    var userId = ""
    var planId = ""
    var loadingCounter = 0
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 25
        button.setImage(UIImage(named: "search"), for: .normal)
        button.currentImage?.withTintColor(.blue)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(searchLocation), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
       
        return button
    }()
    
    @objc func searchLocation() {
        performSegue(withIdentifier: "goToMapFromSearch", sender: self)
    }
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: UIScreen.main.bounds.height / 2 - 25,
            width: 50, height: 50),
              type: .ballBeat,
              color: UIColor(named: "darkGreen") ?? .white,
              padding: 0
          )
    var blurEffectView: UIVisualEffectView!
    let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        
        setUpHeaderView()
//        tableView.tableHeaderView = headerView
        view.addSubview(searchButton)
        setUpButton()
        self.tabBarController?.delegate = self
        fetchPlans()
        fetchMemories()
        LoginViewController.loginStatus = setUpLoginStatus()
    }
    
    func setUpLoginStatus() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
    }
    
    func setUpHeaderView() {
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
    }
    
    func fetchPlans() {
        let firestoreManager = FirestoreManager()
        firestoreManager.fetchTravelPlans(userId: nil) { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchMemories() {
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchAllMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
 
    func setUpButton() {
        searchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }

        switch identifier {
        case "goToMapFromSearch":
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = true
            }
        case "MemoryDetail":
            if let destinationVC = segue.destination as? MemoryDetailViewController {
                destinationVC.memoryId = self.memoryId
                print("self.memoryId\(self.memoryId)")
                destinationVC.userId = self.userId
                print("userid@\(destinationVC.userId)")
            }
        case "PlanDetail":
            if let destinationVC = segue.destination as? PlanDetailViewController {
                destinationVC.travelPlanId = self.planId
                destinationVC.userId = self.userId
                print("self.planid userid\(self.planId)&\(self.userId)")
            }
        default:
            break
        }
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
        addLoadingView()
        fetchPlans()
        if self.plans.isEmpty && self.searchIndex == 1 {
            removeLoadingView()
        }
        fetchMemories()
        if self.memories.isEmpty && self.searchIndex == 0 {
            removeLoadingView()
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchIndex == 0 ? memories.count: plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SearchMemoriesCell",
            for: indexPath) as? SearchMemoriesCell
        else { fatalError("Could not create SearchMemoriesCell") }
        if searchIndex == 0 {
            return setUpCellForMemories(indexPath: indexPath, cell: cell, plans: memories)
        } else {
            return setUpCellForPlans(indexPath: indexPath, cell: cell, plans: plans)
        }
    }
    
    func setUpCellForMemories(indexPath: IndexPath, cell: SearchMemoriesCell, plans: [TravelPlan]) -> UITableViewCell {
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        cell.userNameLabel.text = memories[indexPath.row].user
        cell.userImageView.kf.setImage(
            with: URL(string: memories[indexPath.row].userPhoto ?? ""),
            placeholder: UIImage(systemName: "person.circle.fill"))
        cell.memoryNameLabel.text = memories[indexPath.row].planName
        cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
        let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
        let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
        setUpImagesForMemories(indexPath: indexPath, cell: cell)
        return cell
    }
    func setUpImagesForMemories(indexPath: IndexPath, cell: SearchMemoriesCell) {
        guard memories.isEmpty == false else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
            return
        }
        let urlString = memories[indexPath.row].coverPhoto ?? ""
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
            return
        }
        downloadImageFromFirestorage(url: url, cell: cell, indexPath: indexPath)
    }
    
    func setUpCellForPlans(indexPath: IndexPath, cell: SearchMemoriesCell, plans: [TravelPlan]) -> UITableViewCell {
        cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
        cell.userNameLabel.text = plans[indexPath.row].user
        cell.userImageView.kf.setImage(
            with: URL(string: plans[indexPath.row].userPhoto ?? ""),
            placeholder: UIImage(systemName: "person.circle.fill"))
        cell.memoryNameLabel.text = plans[indexPath.row].planName
        let start = self.changeDateFormat(date: "\(self.plans[indexPath.row].startDate)")
        let end = self.changeDateFormat(date: "\(self.plans[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
        setUpImageForPlans(indexPath: indexPath, cell: cell)
        return cell
    }
    
    func setUpImageForPlans(indexPath: IndexPath, cell: SearchMemoriesCell) {
        let daysData = plans[indexPath.row].days
        guard daysData.isEmpty == false else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
            return
        }
        let locationData = daysData[0]
        let theLocation = locationData.locations
        guard theLocation.isEmpty == false else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
            return
        }
        let urlString = theLocation[0].photo
        guard let url = URL(string: urlString) else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
            return
        }
        downloadImageFromFirestorage(url: url, cell: cell, indexPath: indexPath)
        removeLoadingView()
    }
    
    func downloadImageFromFirestorage(url: URL, cell: SearchMemoriesCell, indexPath: IndexPath) {
        cell.memoryImageView.image = nil
        let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
            DispatchQueue.main.async {
                guard cell.taskIdentifier == taskIdentifier else {
                    return
                }
                if let image = image {
                    cell.memoryImageView.image = image
                } else {
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                }
                self.removeLoadingView()
            }
        }
    }
    
    func changeDateFormat(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if let date = dateFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy年MM月dd日"
            let formattedString = outputFormatter.string(from: date)
            return formattedString
        } else {
            print("Failed to convert the date string.")
            return ""
        }

    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchIndex == 0 {
            memoryId = memories[indexPath.row].id
            userId = memories[indexPath.row].userId ?? ""
            performSegue(withIdentifier: "MemoryDetail", sender: self)
        } else {
            planId = plans[indexPath.row].id
            print("planId\(planId)")
            userId = plans[indexPath.row].userId ?? ""
            performSegue(withIdentifier: "PlanDetail", sender: self)
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          330
    }
}

extension SearchViewController: SearchHeaderViewDelegate {
    func change(to index: Int) {
        searchIndex = index
        addLoadingView()
        tableView.reloadData()
        if plans.isEmpty && searchIndex == 1 {
            removeLoadingView()
        } else if memories.isEmpty && searchIndex == 0 {
            removeLoadingView()
        }
    }
}

extension SearchViewController {
   
    func downloadPhotoFromFirebaseStorage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: url.absoluteString)

        storageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading photo from Firebase Storage: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Failed to create UIImage from data.")
                completion(nil)
            }
        }
    }
}

extension SearchViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !LoginViewController.loginStatus else { // 登入中 return true
            return true
        }
        guard viewController.tabBarItem.tag > 0 else { // 未登入 且點擊tag>0
            return false
        }
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") 
                as? LoginViewController else {
            return false
        }
        let loginNavController = UINavigationController(rootViewController: loginVC)
        present(loginNavController, animated: true, completion: nil)
        return false
    }
}
