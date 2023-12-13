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
        frame: CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: 50, height: 50),
              type: .ballBeat,
              color: UIColor(named: "darkGreen") ?? .white,
              padding: 0
          )
    var blurEffectView: UIVisualEffectView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
        tableView.tableHeaderView = headerView
        view.addSubview(searchButton)
        setUpButton()
        self.tabBarController?.delegate = self
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchAllTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
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
        
        if Auth.auth().currentUser != nil {
            LoginViewController.loginStatus = true
        } else {
            LoginViewController.loginStatus = false
        }
    }
    
    func setUpButton() {
        searchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromSearch" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = true
            }
        }
        if segue.identifier == "MemoryDetail" {
            if let destinationVC = segue.destination as? MemoryDetailViewController {
                destinationVC.memoryId = self.memoryId
                destinationVC.userId = self.userId
                print("userid@\(destinationVC.userId)")
            }
        }
        if segue.identifier == "PlanDetail" {
            if let destinationVC = segue.destination as? PlanDetailViewController {
                destinationVC.travelPlanId = self.planId
                destinationVC.userId = self.userId
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if searchIndex == 1 {
            let firestoreManager = FirestoreManager()
            firestoreManager.delegate = self
            firestoreManager.fetchAllTravelPlans { (travelPlans, error) in
                if let error = error {
                    print("Error fetching travel plans: \(error)")
                } else {
                    print("Fetched travel plans: \(travelPlans ?? [])")
                    self.plans = travelPlans ?? []
                    self.tableView.reloadData()
                }
            }
        } else if searchIndex == 0 {
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
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIndex == 0 {
            return memories.count
        } else if searchIndex == 1 {
            return plans.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchIndex == 0 {
            view.addSubview(blurEffectView)
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchMemoriesCell",
                for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
// userinfo
            cell.userImageView.image = UIImage(systemName: "person.circle")
            cell.userNameLabel.text = memories[indexPath.row].user
            if let userPhotoURL = URL(string: memories[indexPath.row].userPhoto ?? "") {
                cell.userImageView.kf.setImage(
                    with: userPhotoURL,
                    placeholder: UIImage(systemName: "person.circle.fill"),
                    completionHandler: { result in
                        switch result {
                        case .success(_):
                            print("user photo was set up by kingfisher")
                            break
                        case .failure(_):
                            // Image failed to load, fetch from Firestore
                            let firestorageManager = FirebaseStorageManagerDownloadPhotos()
                            firestorageManager.downloadPhotoFromFirebaseStorage(url: userPhotoURL) { image in
                                DispatchQueue.main.async {
                                    if let image = image {
                                        cell.userImageView.image = image
                                        cell.userImageView.contentMode = .scaleAspectFill
                                    } else {
                                        cell.userImageView.image = UIImage(systemName: "person.circle.fill")}}}}})}
            if memories.isEmpty == false {
                loadingCounter += 1
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                    firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            
                            self.loadingCounter -= 1
                            
                            if let image = image {
                                cell.memoryImageView.image = image
                                cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                                let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
                                let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
                                cell.dateLabel.text = "\(start)-\(end)"
                                
                                if self.loadingCounter == 0 {
                                   // Remove the loading indicator when all tasks are finished
                                   self.activityIndicatorView.stopAnimating()
                                   self.blurEffectView.removeFromSuperview()
                                    self.activityIndicatorView.removeFromSuperview()
                                               }
                            } else {
                                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                } else {
                    // Handle the case where the URL is empty
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                    cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                    let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
                    let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
                    cell.dateLabel.text = "\(start)-\(end)"
                }
            }
            return cell
        } else {
// searchindex == 1 userinfo照片
            view.addSubview(blurEffectView)
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchMemoriesCell",
                for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = plans[indexPath.row].user
            cell.memoryImageView.image = mockImage
            cell.memoryNameLabel.text = plans[indexPath.row].planName
            cell.userImageView.kf.setImage(with: URL(string: plans[indexPath.row].userPhoto ?? ""), placeholder: UIImage(systemName: "person.circle.fill"))
            let start = self.changeDateFormat(date: "\(self.plans[indexPath.row].startDate)")
            let end = self.changeDateFormat(date: "\(self.plans[indexPath.row].endDate)")
            cell.dateLabel.text = "\(start)-\(end)"
            let daysData = plans[indexPath.row].days
            if daysData.isEmpty == false {
                let locationData = daysData[0]
                let theLocation = locationData.locations
                if theLocation.isEmpty == false {
                    self.loadingCounter += 1
                    let urlString = theLocation[0].photo
                    if let url = URL(string: urlString) {
                        let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                        firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                            DispatchQueue.main.async {
                                
                                self.loadingCounter -= 1
                                
                                if let image = image {
                                    cell.memoryImageView.image = image
                                    if self.loadingCounter == 0 {
                                       self.activityIndicatorView.stopAnimating()
                                       self.blurEffectView.removeFromSuperview()
                                    self.activityIndicatorView.removeFromSuperview()}
                                } else {
                                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")}}}}} }
            
            return cell} 
    }
    
    func changeDateFormat(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set the locale to handle the date format

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
        tableView.reloadData()
    }
}

extension SearchViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan]) {
        plans = firestoreData
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
        if !LoginViewController.loginStatus {
            if viewController.tabBarItem.tag > 0 {
                if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                    // Present the login view controller within a navigation controller
                    let loginNavController = UINavigationController(rootViewController: loginVC)
                    present(loginNavController, animated: true, completion: nil)
                    return false
                }
            }
            return false
        } else {
            return true
        }
    }
}
