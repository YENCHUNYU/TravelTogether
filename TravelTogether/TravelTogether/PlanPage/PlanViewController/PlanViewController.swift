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
       
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans { (travelPlan, error) in
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
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans { (travelPlan, error) in
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
                                cell.planImageView.image = image
                            } else {
                                cell.planImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "TogetherPlanCell",
                for: indexPath) as? TogetherPlanCell
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
            guard let destinationVC = segue.destination
                    as? EditPlanViewController else { fatalError("Can not create EditPlanViewController") }
            destinationVC.travelPlanId = plans[indexPath.row].id 
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

extension PlanViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan]) {
        plans = firestoreData
    }
}

extension PlanViewController: FirebaseStorageManagerDownloadDelegate {
    func manager(_ manager: FirebaseStorageManagerDownloadPhotos) {
    }
}
