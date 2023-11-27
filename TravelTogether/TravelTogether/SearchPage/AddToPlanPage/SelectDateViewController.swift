//
//  SelectDateViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/27.
//

import UIKit
import FirebaseFirestore

class SelectDateViewController: UIViewController {

    var plans: [TravelPlan] = []
    var location = Location(name: "", photo: "", address: "")
    var planId = ""
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(SelectDateFooterView.self, forHeaderFooterViewReuseIdentifier: "SelectDateFooterView")
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: planId) { (travelPlan, error) in
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
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: planId) { (travelPlan, error) in
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
    }

extension SelectDateViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        onePlan.days.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SelectDateCell", for: indexPath) as? SelectDateCell
            else { fatalError("Could not create SelectDateCell") }
        cell.dateLabel.text = "第\(indexPath.row + 1)天"
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let firestorePostLocation = FirestoreManagerForPostLocation()
        firestorePostLocation.delegate = self
        firestorePostLocation.addLocationToTravelPlan(planId: planId, location: location, day: indexPath.row) { error in
            if let error = error {
                print("Error posting location: \(error)")
            } else {
                print("Location posted successfully!")
            }
        }
        self.dismiss(animated: true)
    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "SelectDateFooterView") as? SelectDateFooterView
        else { fatalError("Could not create SelectDateFooterView") }
        view.createNewDayButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return view
    }
    
    @objc func createButtonTapped() {
   let firestoreManagerPostDay = FirestoreManagerForPostDay()
        firestoreManagerPostDay.addDayToTravelPlan(planId: planId) { error in
            if let error = error {
                print("Error posting day: \(error)")
            } else {
                print("New Day posted successfully!")
                let firestoreManagerForOne = FirestoreManagerForOne()
                firestoreManagerForOne.delegate = self
                firestoreManagerForOne.fetchOneTravelPlan(byId: self.planId) { (travelPlan, error) in
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
        }
        }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
}

extension SelectDateViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 50
    }
}

extension SelectDateViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
    }
}

extension SelectDateViewController: FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location) {
        location = firestoreData
    }
}
