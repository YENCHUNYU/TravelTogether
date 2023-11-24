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
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = ""
    var dayCounts = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
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
}

extension EditPlanViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        dayCounts
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "第\(section + 1)天"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if onePlan.days.isEmpty == false {
            if section == 0 {
                return onePlan.days[0].locations.count
            } else {
                return 0
            }
        } else {
           return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditPlanCell",
                for: indexPath) as? EditPlanCell
            else { fatalError("Could not create EditPlanCell") }
        cell.placeNameLabel.text = onePlan.days[0].locations[indexPath.row].name
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "EditPlanFooterView") as? EditPlanFooterView
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
                destinationVC.travelPlanId = travelPlanId
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

extension EditPlanViewController: FirestoreManagerForeOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension EditPlanViewController: EditPlanHeaderViewDelegate {
    func passDayCouts(number: Int) {
        dayCounts = number
            self.tableView.reloadData()
    }   
}
