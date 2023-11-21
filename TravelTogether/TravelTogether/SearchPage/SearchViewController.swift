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

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    

    @IBOutlet weak var button: UIButton!
    
    var searchIndex = 0
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    var spotsData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
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
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToMapFromSearch", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromSearch" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = true
            }
        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIndex == 0 {
            return 1
        } else if searchIndex == 1 {
            return plans.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMemoriesCell", for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = "Jenny"
            if let image = UIImage(named: "台北景點") {
                cell.memoryImageView.image = image
                   }
            cell.memoryNameLabel.text = "台北一日遊"
            return cell
        } else if searchIndex == 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchMemoriesCell", for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = "Jenny"
            cell.memoryImageView.image = mockImage
            cell.memoryNameLabel.text = plans[indexPath.row].planName
            
            if spotsData.isEmpty == false {
                let spotData = spotsData[0]
                if let urlString = spotData["photo"] as? String,
                   let url = URL(string: urlString) {
                    downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                print("url\(url)")
                                cell.memoryImageView.image = image
                            } else {
                                print("url\(url)")
                                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                }
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath) as? SpotCell
            else { fatalError("Could not create SpotCell") }
            if let image = UIImage(named: "雲林古坑") {
                cell.spotImageView.image = image
                   }
            cell.spotNameLabel.text = "雲林古坑"
            return cell
        }   
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchIndex == 0 {
            performSegue(withIdentifier: "MemoryDetail", sender: self)
        }
        
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchIndex == 0 {
           return 350
        } else if searchIndex == 1  {
            return 350
        } else {
            return 300
        }
    }
}

extension SearchViewController: SearchHeaderViewDelegate {
    func change(to index: Int) {
        searchIndex = index
        tableView.reloadData()
    }
}

extension SearchViewController {
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
