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
    var plans: [TravelPlan2] = []
    var spotsData: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = PlanHeaderView(reuseIdentifier: "PlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
       
        fetchTravelPlans { (travelPlan, error) in
            if let error = error {
                print("Error fetching travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched travel plan: \(travelPlan)")
                self.plans = travelPlan
                self.tableView.reloadData()
            } else {
                print("Travel plan not found.")
            }
        }
           
    }
    
    override func viewWillAppear(_ animated: Bool) {

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

            print("spotsData\(spotsData)")
            if spotsData.isEmpty == false {
                let spotData = spotsData[0]
                if let urlString = spotData["photo"] as? String,
                   let url = URL(string: urlString) {
                    downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                print("url\(url)")
                                cell.planImageView.image = image
                            } else {
                                print("url\(url)")
                                cell.planImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                }
            }
    
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "TogetherPlanCell", for: indexPath) as? TogetherPlanCell
            else { fatalError("Could not create TogetherPlanCell") }
            
            if let image = UIImage(named: "日本") {
                cell.planImageView.image = image
                   }
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
    
    
    func fetchTravelPlans(completion: @escaping ([TravelPlan2]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        let travelPlansRef = db.collection("TravelPlan")
        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var travelPlans: [TravelPlan2] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // Convert Firestore Timestamp to Date
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Retrieve the "days" array
                    guard let daysArray = data["days"] as? [[String: Any]] else {
                        continue // Skip this document if "days" is not an array
                    }
                    
                    // Convert each day data to a TravelDay object
                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                        let dayDate = (dayData["date"] as? Timestamp)?.dateValue() ?? Date()
                        
                        // Retrieve the "locations" array for each day
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            continue // Skip this day if "locations" is not an array
                        }
                        
                        // Convert each location data to a Location object
                        var locations: [Location] = []
                        for locationData in locationsArray {
                            let location = Location(
                                name: locationData["name"] as? String ?? "",
                                photo: locationData["photo"] as? String ?? "",
                                address: locationData["address"] as? String ?? ""
                            )
                            locations.append(location)
                        }
                        
                        // Create a TravelDay object
                        let travelDay = TravelDay(date: dayDate, locations: locations)
                        travelDays.append(travelDay)
                    }
                    
                    // Create a TravelPlan object
                    let travelPlan = TravelPlan2(
                        id: document.documentID,
                        planName: data["planName"] as? String ?? "",
                        destination: data["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
                    )
                    
                    travelPlans.append(travelPlan)
                    
                }
                
                completion(travelPlans, nil)
            }
        }
    }
    
}
