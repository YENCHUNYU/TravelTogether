//
//  addToPlanListViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore

class AddToPlanListViewController: UIViewController {

    var plans: [TravelPlan2] = []
    var spotName = ""
    var spotAddress = ""
    var places = Place(name: "", identifier: "", address: "")
    var travelPlanIndex = 0
    var spotsPhotoUrl = ""
    
    var location = Location(name: "", photo: "", address: "")
    var planId = ""

    @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(AddToListFooterView.self, forHeaderFooterViewReuseIdentifier: "AddToListFooterView")
           
            let firestoreManager = FirestoreManager()
            firestoreManager.delegate = self
            firestoreManager.fetchTravelPlans { (travelPlans, error) in
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
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans { (travelPlans, error) in
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
    }

extension AddToPlanListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddToListCell", for: indexPath) as? AddToListCell
            else { fatalError("Could not create AddToListCell") }
        cell.planTitleLabel.text = plans[indexPath.row].planName
        let start = changeDateFormat(date: "\(plans[indexPath.row].startDate)")
        let end = changeDateFormat(date: "\(plans[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
            return cell
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
        planId = plans[indexPath.row].id
        let firestorePostLocation = FirestoreManagerForPostLocation()
        firestorePostLocation.delegate = self
        firestorePostLocation.addLocationToTravelPlan(planId: planId, location: location) { error in
            if let error = error {
                print("Error posting location: \(error)")
            } else {
                print("Location posted successfully!")
            }
        }
//        appendToTravelPlan(id: self.plans[indexPath.row].id ?? "", newSpots: [spotName]) { error in
//            if let error = error {
//                print("Error posting travel plan: \(error)")
//            } else {
//                print("Travel plan posted successfully!")
//            }
//        }
        
//        addSpotsToTravelPlan(id: self.plans[self.travelPlanIndex].id ?? "", day: 1, spots: self.places.name, spotsPhotos: self.spotsPhotoUrl) { error in
//            if let error = error {
//                print("Error posting travel plan: \(error)")
//            } else {
//                print("Travel plan posted for day successfully!")
//                if let navigationController = self.navigationController {
//                 let viewControllers = navigationController.viewControllers
//                 if viewControllers.count >= 2 {
//                     let targetViewController = viewControllers[viewControllers.count - 2]
//                     navigationController.popToViewController(targetViewController, animated: true)
//                                 }
//                             }
//            }
//        }
        self.dismiss(animated: true)
  
    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AddToListFooterView") as? AddToListFooterView
        else { fatalError("Could not create AddToListFooterView") }
        view.createNewPlanButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return view
    }
    
    @objc func createButtonTapped() {
    performSegue(withIdentifier: "goToCreate", sender: self)
        }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
}

extension AddToPlanListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 60
    }
}

extension AddToPlanListViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan2]) {
        plans = firestoreData
    }
}

extension AddToPlanListViewController: FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location) {
        location = firestoreData
    }
}
