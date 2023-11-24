//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIntroduction: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var fanNumberLabel: UILabel!
    @IBOutlet weak var fanLabel: UILabel!
    @IBOutlet weak var followNumberLabel: UILabel!
    @IBOutlet weak var followLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var profileIndex = 0
    var plans: [TravelPlan] = []
    var spotsData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = ProfileHeaderView(reuseIdentifier: "ProfileHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        
        userNameLabel.text = "Jenny"
        userIntroduction.text = "什麼時候可以出去玩:D"
        
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
            }
        }
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profileIndex == 0 {
           return 1
        } else {
            return plans.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if profileIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            if let image = UIImage(named: "台北景點") {
                cell.profileImageView.image = image
            }
            cell.profileImageNameLabel.text = "台北三日遊"
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            cell.profileImageNameLabel.text = plans[indexPath.row].planName
            
            let daysData = plans[indexPath.row].days
            if daysData.isEmpty == false {
                let locationData = daysData[0]
                let theLocation = locationData.locations
                let urlString = theLocation[0].photo
                if let url = URL(string: urlString) {
                    let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                    firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                cell.profileImageView.image = image
                            } else {
                                cell.profileImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                }
            }
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
