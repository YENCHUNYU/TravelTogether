//
//  PlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PlanViewController: UIViewController { 
    
    @IBOutlet weak var addNewButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView! 
    
    var planIndex = 0
    var plans: [TravelPlan] = []
    var spotsData: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = PlanHeaderView(reuseIdentifier: "PlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        
        fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    @IBAction func addNewPlanButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToCreate", sender: self)
    }
    
    
}

extension PlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if planIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as? MyPlanCell
            else { fatalError("Could not create PlanCell") }
            cell.planNameLabel.text = plans[indexPath.row].planName
            let start = changeDateFormat(date: "\(plans[indexPath.row].startDate)")
            let end = changeDateFormat(date: "\(plans[indexPath.row].endDate)")
            cell.planDateLabel.text = "\(start)-\(end)"
            
            fetchAllSpotsForTravelPlan(id: plans[indexPath.row].id ?? "", day: 1) { spots, error in
                if let error = error {
                    print("Error fetching spots for Day 1: \(error)")
                } else {
                        print("Spots for Day 1: \(spots)")
                    self.spotsData = spots
                  //  self.tableView.reloadData()
                }
            }
            
//            // swiftlint: disable line_length
//            let spotData = spotsData[indexPath.row]
//            if let url = URL(string: spotData["photo"] as? String ?? "") {
//                downloadPhotoFromFirebaseStorage(url: url) { image in
//                    if let image = image {
//                        cell.planImageView.image = image
//                    } else {
//                        cell.planImageView.image = UIImage(named: "Image_Placeholder")
//                    }
//                }
//            }
          
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TogetherPlanCell", for: indexPath) as? TogetherPlanCell
            else { fatalError("Could not create TogetherPlanCell") }
            
            // ...
// swiftlint: disable line_length

let urlString = "https://firebasestorage.googleapis.com:443/v0/b/traveltogether-365af.appspot.com/o/photos%2F8BF1F88C-FC9E-46E5-9936-851A9AEFFDF6.jpg?alt=media&token=1e33c1c5-c527-4512-8ff3-350e0dfc1e9c"

// swiftlint: enable line_length
            if let url = URL(string: urlString) {
                downloadPhotoFromFirebaseStorage(url: url) { image in
                    if let image = image {
                        cell.planImageView.image = image
                    } else {
                        cell.planImageView.image = UIImage(named: "Image_Placeholder")
                    }
                }}
            
            return cell
        }
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
        performSegue(withIdentifier: "goToEdit", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEdit", let indexPath = sender as? IndexPath {
            guard let destinationVC = segue.destination as? EditPlanViewController else { fatalError("Can not create EditPlanViewController") }
//                   let selectedTravelPlan = plans[indexPath.row]
//                   destinationVC.travelPlan = selectedTravelPlan
            let selectedTravelPlanIndex = indexPath.row
            destinationVC.travelPlanIndex = selectedTravelPlanIndex
            destinationVC.travelPlanId = plans[indexPath.row].id ?? ""
           
               }
    }
}

extension PlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if planIndex == 0 {
           return 280
        } else {
            return 280
        }
    }
}

extension PlanViewController: PlanHeaderViewDelegate {
    func change(to index: Int) {
        planIndex = index
        tableView.reloadData()
    }
}

extension PlanViewController {
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
                completion(image)
            } else {
                print("Failed to create UIImage from data.")
                completion(nil)
            }
        }
    }
    //抓取景點名和照片
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

