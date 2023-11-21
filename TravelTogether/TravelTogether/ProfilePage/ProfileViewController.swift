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
        
        fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
            }
        }
        
        
        fetchTravelPlans { (travelPlans, error) in
               if let error = error {
                   print("Error fetching travel plans: \(error)")
               } else {
                   // Handle the retrieved travel plans
                   print("Fetched travel plans: \(travelPlans ?? [])")
                   self.plans = travelPlans ?? []

                   // Use a dispatch group to wait for all fetch operations to finish
                   let dispatchGroup = DispatchGroup()

                   for plan in self.plans {
                       dispatchGroup.enter()

                       self.fetchAllSpotsForTravelPlan(id: plan.id ?? "", day: 1) { spots, error in
                           defer {
                               dispatchGroup.leave()
                           }

                           if let error = error {
                               print("Error fetching spots for Day 1: \(error)")
                           } else {
                               print("Spots for Day 1: \(spots)")
                               self.spotsData.append(contentsOf: spots)
                           }
                       }
                   }

                   // Notify when all fetch operations are complete
                   dispatchGroup.notify(queue: .main) {
                       self.tableView.reloadData()
                   }
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
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            if let image = UIImage(named: "台北景點") {
                cell.profileImageView.image = image
            }
            cell.profileImageNameLabel.text = "台北一日遊"
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as? ProfileCell
            else { fatalError("Could not create ProfileCell") }
            cell.profileImageNameLabel.text = plans[indexPath.row].planName
//            if let image = UIImage(named: "Image_Placeholder") {
//                cell.profileImageView.image = image
//            }
            
            if spotsData.isEmpty == false {
                let spotData = spotsData[0]
                if let urlString = spotData["photo"] as? String,
                   let url = URL(string: urlString) {
                    downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                print("url\(url)")
                                cell.profileImageView.image = image
                            } else {
                                print("url\(url)")
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
    // Firebase
    
    func fetchTravelPlans(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let db = Firestore.firestore()

        let travelPlansRef = db.collection("TravelPlan")
        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var travelPlans: [TravelPlan] = []

                for document in querySnapshot!.documents {
                    let data = document.data()

                    // Convert Firestore Timestamp to Date
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    // Create a TravelPlan object
                    let travelPlan = TravelPlan(
                        id: document.documentID,
                        planName: data["planName"] as? String ?? "",
                        destination: data["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate
                        // Add other properties as needed
                    )

                    travelPlans.append(travelPlan)
                    
                }

                completion(travelPlans, nil)
            }
        }
    }
    
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
    
    func fetchAllSpotsForTravelPlan(id: String, day: Int, completion: @escaping ([[String: Any]], Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanReference = db.collection("TravelPlan").document(id)
        let spotsCollectionReference = travelPlanReference.collection("SpotsPerDay").document("Day\(day)").collection("SpotsForADay")
        var allSpotsData: [[String: Any]] = []  // Ensure it's a local variable
        // 查询所有文档
        spotsCollectionReference.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching spots: \(error)")
                completion([], error)
                return
            }

            // 遍历文档并提取数据
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                allSpotsData.append(data)
                
            }

            completion(allSpotsData, nil)
        }
    }
}
