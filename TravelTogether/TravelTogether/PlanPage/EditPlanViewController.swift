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
    var plans: [TravelPlan] = [TravelPlan(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), allSpots: [])]
    var travelPlanIndex = 0
    var spots: [String] = []
    
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
        
        fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.spots = self.plans[self.travelPlanIndex].allSpots ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToMap", sender: sender)
    }
    
}

extension EditPlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        spots.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlanCell", for: indexPath) as? EditPlanCell
            else { fatalError("Could not create EditPlanCell") }
        cell.placeNameLabel.text = plans[travelPlanIndex].allSpots?[indexPath.row]
     
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
    performSegue(withIdentifier: "goToSearchSpot", sender: self)
       
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
                        endDate: endDate,
                        allSpots: data["allSpots"] as? [String] ?? []
                    )

                    travelPlans.append(travelPlan)
                    
                }

                completion(travelPlans, nil)
            }
        }
    }
}
