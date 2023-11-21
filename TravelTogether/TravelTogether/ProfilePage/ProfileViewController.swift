//
//  ProfileViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore

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
            if let image = UIImage(named: "Image_Placeholder") {
                cell.profileImageView.image = image
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
}
