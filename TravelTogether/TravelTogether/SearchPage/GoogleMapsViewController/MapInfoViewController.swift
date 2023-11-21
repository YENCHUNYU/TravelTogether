//
//  MapInfoViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore

class MapInfoViewController: UIViewController {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addToPlanButton: UIButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    var places = Place(name: "", identifier: "", address: "")
    var isFromSearch = false
    var plans: [TravelPlan] = []
    var travelPlanIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        placeNameLabel.text = places.name
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 400, width: UIScreen.main.bounds.width, height: 400 )
    }
    
    @IBAction func addToPlanButtonTapped(_ sender: Any) {
        if isFromSearch {
            performSegue(withIdentifier: "goToPlanList", sender: sender)
        } else {
            
            appendToTravelPlan(id: self.plans[travelPlanIndex].id ?? "", newSpots: [places.name]) { error in
                if let error = error {
                    print("Error posting travel plan: \(error)")
                } else {
                    print("Travel plan posted successfully!")
//                    if let navigationController = self.navigationController {
//                     let viewControllers = navigationController.viewControllers
//                     if viewControllers.count >= 2 {
//                         let targetViewController = viewControllers[viewControllers.count - 2]
//                         navigationController.popToViewController(targetViewController, animated: true)
//                                     }
//                                 }
                }
            }
            
            addSpotsToTravelPlan(id: self.plans[travelPlanIndex].id ?? "", day: 1, spots: [places.name]) { error in
                if let error = error {
                    print("Error posting travel plan: \(error)")
                } else {
                    print("Travel plan posted successfully!")
                    if let navigationController = self.navigationController {
                     let viewControllers = navigationController.viewControllers
                     if viewControllers.count >= 2 {
                         let targetViewController = viewControllers[viewControllers.count - 2]
                         navigationController.popToViewController(targetViewController, animated: true)
                                     }
                                 }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlanList" {
                guard let navigationController = segue.destination as? UINavigationController,
                      let destinationVC = navigationController.viewControllers.first as? AddToPlanListViewController else {
                    fatalError("Cannot access AddToPlanListViewController")
                }

                let spotName = places.name
                destinationVC.spotName = spotName
            }
    }
    
}

extension MapInfoViewController {
    
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
    
    
    func addSpotsToTravelPlan(id: String, day: Int, spots: [String], completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanReference = db.collection("TravelPlan").document(id)

        // 使用 Batch 寫入，以確保原子性
        let batch = db.batch()

        // 準備 spots 的子集合參考
        let spotsCollectionReference = travelPlanReference.collection("SpotsPerDay").document("Day\(day)")

        // 在子集合中添加一個新文件，包含當天的景點
        batch.setData(["spots": FieldValue.arrayUnion(spots)], forDocument: spotsCollectionReference, merge: true)

        // 提交 Batch 寫入
        batch.commit { error in
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
