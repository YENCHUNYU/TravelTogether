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
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

            performSegue(withIdentifier: "MemoryDetail", sender: self)
  
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
        //
        print("create tapped")
        guard let createPlanViewController = storyboard?.instantiateViewController(withIdentifier: "CreatePlanViewController") as? CreatePlanViewController
        else {fatalError("Can not instantiate CreatePlanViewController")}

                // Set the closure to receive the planName value
//                createPlanViewController.onSave = { [weak self] planName in
//                    // Use the planName value as needed
//                    self?.handlePlanName(planName)
//                }

                navigationController?.pushViewController(createPlanViewController, animated: true)
        }
    
//    func handlePlanName(_ planName: String) {
//      //  plans.append(planName)
//        tableView.reloadData()
//        }
    
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

        db.collection("TravelPlan").getDocuments { (querySnapshot, error) in
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
