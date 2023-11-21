//
//  SearchViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit
import GoogleMaps
import FirebaseFirestore

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    

    @IBOutlet weak var button: UIButton!
    
    var searchIndex = 0
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    
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
}
