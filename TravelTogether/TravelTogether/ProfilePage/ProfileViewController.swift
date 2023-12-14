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
            frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: (UIScreen.main.bounds.height - 173) / 2 - 50, width: 50, height: 50),
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
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = ProfileHeaderView(reuseIdentifier: "ProfileHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        
        userNameLabel.text = "User"
   
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
            }
        }
        
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
        let firestoreUser = FirestoreManagerFetchUser()
        firestoreUser.fetchUserInfo { (userInfo, error) in
            if let error = error {
                print("Error fetching UserInfo: \(error)")
            } else {
                print("Fetched UserInfo: \(String(describing: userInfo))")
                self.userInfo = userInfo ?? UserInfo(email: "", name: "", id: "")
                self.userNameLabel.text = self.userInfo.name
                if let photoURLString = self.userInfo.photo, let photoURL = URL(string: photoURLString) {
                    self.userImageView.kf.setImage(with: photoURL, placeholder: UIImage(systemName: "person.circle.fill"))
                } else {
                    self.userImageView.image = UIImage(systemName: "person.circle.fill")
                }

            }
        }
              
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
    }
    
    @objc func rightButtonTapped() {
        if let settingVC = storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController {
            // Present the login view controller within a navigation controller
            let settingNavController = UINavigationController(rootViewController: settingVC)
            present(settingNavController, animated: true, completion: nil)
        }

       }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
           
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.addSubview(blurEffectView)
        tableView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
            }
        }
        
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
        let firestoreUser = FirestoreManagerFetchUser()
        firestoreUser.fetchUserInfo { (userInfo, error) in
            if let error = error {
                print("Error fetching UserInfo: \(error)")
            } else {
                print("Fetched UserInfo: \(String(describing: userInfo))")
                self.userInfo = userInfo ?? UserInfo(email: "", name: "", id: "")
                self.userNameLabel.text = self.userInfo.name
                if let photoURLString = self.userInfo.photo, let photoURL = URL(string: photoURLString) {
                    self.userImageView.kf.setImage(with: photoURL, placeholder: UIImage(systemName: "person.circle.fill"))
                } else {
                    self.userImageView.image = UIImage(systemName: "person.circle.fill")
                }
            }
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profileIndex == 0 {
            return memories.count
        } else {
            return plans.count
        }
    }
    
    func tableView(
        _ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if profileIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            if memories.isEmpty == false {
                cell.memoryImageView.image = nil
                cell.memoryNameLabel.text = nil
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                    firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                cell.memoryImageView.image = image
                                cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                                self.activityIndicatorView.stopAnimating()
                                self.blurEffectView.removeFromSuperview()
                                self.activityIndicatorView.removeFromSuperview()
                            } else {
                                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                } else {
                    // Handle the case where the URL is empty
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                    cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            cell.memoryImageView.image = nil
            cell.memoryNameLabel.text = nil
            let daysData = plans[indexPath.row].days
            if daysData.isEmpty == false {
                let locationData = daysData[0]
                let theLocation = locationData.locations
                if theLocation.isEmpty == false {
                    let urlString = theLocation[0].photo
                    if let url = URL(string: urlString) {
                        let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                        firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                            DispatchQueue.main.async {
                                if let image = image {
                                    cell.memoryImageView.image = image
                                    cell.memoryNameLabel.text = self.plans[indexPath.row].planName
                                    self.activityIndicatorView.stopAnimating()
                                    self.blurEffectView.removeFromSuperview()
                                    self.activityIndicatorView.removeFromSuperview()
                                } else {
                                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                                }
                            }
                        }
                    } else {
                        cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                    }
                    
                } else {
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                }}
            
            return cell
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if profileIndex == 0 {
           return 230
        } else {
            return 230
        }
    }
}

extension ProfileViewController: ProfileHeaderViewDelegate {
    func change(to index: Int) {
        tableView.addSubview(blurEffectView)
        tableView.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        profileIndex = index
        tableView.reloadData()
    }
}

extension ProfileViewController {
    
    func downloadPhotoFromFirebaseStorage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: url.absoluteString)

        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading photo from Firebase Storage: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
              //  self.tableView.reloadData()
                completion(image)
                
            } else {
                print("Failed to create UIImage from data.")
                completion(nil)
            }
        }
    }
}

extension ProfileViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan]) {
        plans = firestoreData
    }
}
