//
//  EditPlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit
import FirebaseFirestore

class EditPlanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var planIndex = 0
    var onePlan: TravelPlan2 = TravelPlan2(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])
    var travelPlanIndex = 0
    var planSpots: [String] = []
    var travelPlanId = ""
    var spotsData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none

        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
                self.tableView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
}

extension EditPlanViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "第\(section + 1)天"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if onePlan.days.isEmpty == false {
           return onePlan.days[0].locations.count
        } else {
           return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlanCell", for: indexPath) as? EditPlanCell
            else { fatalError("Could not create EditPlanCell") }
        cell.placeNameLabel.text = onePlan.days[0].locations[indexPath.row].name
            return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EditPlanFooterView") as? EditPlanFooterView
        else { fatalError("Could not create EditPlanFooterView") }
        view.createNewPlanButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return view
    }
    
    @objc func createButtonTapped() {
    performSegue(withIdentifier: "goToMapFromEditPlan", sender: self)
       
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromEditPlan" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = false
                destinationVC.travelPlanIndex = travelPlanIndex
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
}

extension EditPlanViewController: UITableViewDelegate {
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    80
}
}

extension EditPlanViewController: EditPlanHeaderViewDelegate {
    func change(to index: Int) {
        planIndex = index
        tableView.reloadData()
    }
}

extension EditPlanViewController {
  
//    func fetchOneTravelPlan(byId planId: String, completion: @escaping (TravelPlan2?, Error?) -> Void) {
//        let db = Firestore.firestore()
//        let travelPlanRef = db.collection("TravelPlan").document(planId)
//
//        travelPlanRef.getDocument { document, error in
//            if let error = error {
//                print("Error getting document: \(error)")
//                completion(nil, error)
//            } else {
//                do {
//                    guard let document = document, document.exists else {
//                        completion(nil, nil) // Document doesn't exist
//                        return
//                    }
//
//                    let data = document.data()
//
//                    // Convert Firestore Timestamp to Date
//                    let startDate = (data?["startDate"] as? Timestamp)?.dateValue() ?? Date()
//                    let endDate = (data?["endDate"] as? Timestamp)?.dateValue() ?? Date()
//
//                    // Retrieve the "days" array
//                    guard let daysArray = data?["days"] as? [[String: Any]] else {
//                        completion(nil, NSError(domain: "YourAppDomain", code: 1, userInfo: ["message": "Missing 'days' array"]))
//                        return
//                    }
//
//                    // Convert each day data to a TravelDay object
//                    var travelDays: [TravelDay] = []
//                    for dayData in daysArray {
//                        let dayDate = (dayData["date"] as? Timestamp)?.dateValue() ?? Date()
//
//                        // Retrieve the "locations" array for each day
//                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
//                            completion(nil, NSError(domain: "YourAppDomain", code: 2, userInfo: ["message": "Missing 'locations' array"]))
//                            return
//                        }
//
//                        // Convert each location data to a Location object
//                        var locations: [Location] = []
//                        for locationData in locationsArray {
//                            let location = Location(
//                                name: locationData["name"] as? String ?? "",
//                                photo: locationData["photo"] as? String ?? "",
//                                address: locationData["address"] as? String ?? ""
//                            )
//                            locations.append(location)
//                        }
//
//                        // Create a TravelDay object
//                        let travelDay = TravelDay(date: dayDate, locations: locations)
//                        travelDays.append(travelDay)
//                    }
//                    // Create a TravelPlan2 object
//                    let travelPlan = TravelPlan2(
//                        id: document.documentID,
//                        planName: data?["planName"] as? String ?? "",
//                        destination: data?["destination"] as? String ?? "",
//                        startDate: startDate,
//                        endDate: endDate,
//                        days: travelDays
//                    )
//                    completion(travelPlan, nil)
//                } catch {
//                    completion(nil, error)
//                }
//            }
//        }
//    }
}

extension EditPlanViewController: FirestoreManagerForeOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan2) {
        onePlan = firestoreData
    }
}
