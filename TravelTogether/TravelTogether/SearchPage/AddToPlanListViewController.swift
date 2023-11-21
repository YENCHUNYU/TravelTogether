//
//  addToPlanListViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore

class AddToPlanListViewController: UIViewController {

    var plans: [TravelPlan] = []
    var spotName = ""
    var spotAddress = ""
    var places = Place(name: "", identifier: "", address: "")
    var travelPlanIndex = 0
    var spotsPhotoUrl = ""

    @IBOutlet weak var tableView: UITableView!
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(AddToListFooterView.self, forHeaderFooterViewReuseIdentifier: "AddToListFooterView")
            
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
        
//        appendToTravelPlan(id: self.plans[indexPath.row].id ?? "", newSpots: [spotName]) { error in
//            if let error = error {
//                print("Error posting travel plan: \(error)")
//            } else {
//                print("Travel plan posted successfully!")
//            }
//        }
        
        addSpotsToTravelPlan(id: self.plans[self.travelPlanIndex].id ?? "", day: 1, spots: self.places.name, spotsPhotos: self.spotsPhotoUrl) { error in
            if let error = error {
                print("Error posting travel plan: \(error)")
            } else {
                print("Travel plan posted for day successfully!")
                if let navigationController = self.navigationController {
                 let viewControllers = navigationController.viewControllers
                 if viewControllers.count >= 2 {
                     let targetViewController = viewControllers[viewControllers.count - 2]
                     navigationController.popToViewController(targetViewController, animated: true)
                                 }
                             }
            }
        }
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

extension AddToPlanListViewController {
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
    //先不用
    func appendToTravelPlan(id: String, newSpots: [String], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        let travelPlanReference = db.collection("TravelPlan").document(id)

        // Fetch the current array from Firestore
        travelPlanReference.getDocument { (document, error) in
            if let document = document, document.exists {
                var currentSpots = document.data()?["allSpots"] as? [String] ?? []
                
                // Append new values
                currentSpots.append(contentsOf: newSpots)

                // Update the document with the new array
                let data: [String: Any] = ["allSpots": currentSpots]
                travelPlanReference.setData(data, merge: true) { error in
                    if let error = error {
                        print("Error updating document: \(error)")
                        completion(error)
                    } else {
                        print("Document updated successfully")
                        completion(nil)
                    }
                }
            } else {
                print("Document does not exist")
                completion(nil) // You may want to handle this case differently based on your requirements
            }
        }
    }
    
    func addSpotsToTravelPlan(id: String, day: Int, spots: String, spotsPhotos: String, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanReference = db.collection("TravelPlan").document(id)

        // 準備 spots 的子集合參考
        let spotsCollectionReference = travelPlanReference.collection("SpotsPerDay").document("Day\(day)").collection("SpotsForADay")

        // 查詢最大的 spotNumber
        spotsCollectionReference.order(by: "spotNumber", descending: true).limit(to: 1).getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting max spotNumber: \(error)")
                completion(error)
                return
            }

            var nextSpotNumber = 1

            if let documents = snapshot?.documents, !documents.isEmpty,
                let maxSpotNumber = documents[0].data()["spotNumber"] as? Int {
                nextSpotNumber = maxSpotNumber + 1
            }

            // 在子集合中添加一個新文件，包含當天的景點
            let newSpotReference = spotsCollectionReference.document("spot\(nextSpotNumber)")
            let data: [String: Any] = ["name": spots, "photo": spotsPhotos, "spotNumber": nextSpotNumber]
            newSpotReference.setData(data, merge: true) { error in
                if let error = error {
                    print("Error adding spots: \(error)")
                    completion(error)
                } else {
                    print("Spots added successfully")
                    completion(nil)
                }
            }
        }
    }

}
