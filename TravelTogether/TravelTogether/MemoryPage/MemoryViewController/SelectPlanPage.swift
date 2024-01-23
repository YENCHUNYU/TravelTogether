//
//  SelectPlanPage.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SelectPlanViewController: UIViewController {

    var plans: [TravelPlan] = []
    var location = Location(name: "", photo: "", address: "")
    var planId = ""

    @IBOutlet weak var tableView: UITableView!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
           
            let firestoreManager = FirestoreManager()
            firestoreManager.delegate = self
            firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
                if let error = error {
                    print("Error fetching travel plans: \(error)")
                } else {
                    print("Fetched travel plans: \(travelPlans ?? [])")
                    self.plans = travelPlans ?? []
                    self.tableView.reloadData()
                }
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
    }

extension SelectPlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SelectPlanCell", for: indexPath) as? SelectPlanCell
            else { fatalError("Could not create SelectPlanCell") }
        cell.planNameLabel.text = plans[indexPath.row].planName
        let start = DateUtils.changeDateFormat("\(plans[indexPath.row].startDate)")
        let end = DateUtils.changeDateFormat("\(plans[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
            return cell
    }
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        planId = plans[indexPath.row].id
        performSegue(withIdentifier: "goToEditMemory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditMemory" {
            if let destinationVC = segue.destination as? EditMemoryViewController {
                destinationVC.travelPlanId = self.planId
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "製作旅遊回憶"
    }
}

extension SelectPlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 67
    }
}

extension SelectPlanViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan]) {
        plans = firestoreData
    }
}

extension SelectPlanViewController: FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location) {
        location = firestoreData
    }
}
