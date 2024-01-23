//
//  addToPlanListViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class AddToPlanListViewController: UIViewController {
    
    var plans: [TravelPlan] = []
    var location = Location(name: "", photo: "", address: "")
    var planId = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(AddToListFooterView.self, forHeaderFooterViewReuseIdentifier: "AddToListFooterView")
        fetchTravelPlans()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchTravelPlans()
    }
    
    func fetchTravelPlans() {
        let firestoreManager = FirestoreManager()
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

extension AddToPlanListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        plans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "AddToListCell", for: indexPath) as? AddToListCell
        else { fatalError("Could not create AddToListCell") }
        cell.planTitleLabel.text = plans[indexPath.row].planName
        let start = DateUtils.changeDateFormat("\(plans[indexPath.row].startDate)")
        let end = DateUtils.changeDateFormat("\(plans[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        planId = plans[indexPath.row].id
        performSegue(withIdentifier: "goToSelectDate", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectDate" {
            if let destinationVC = segue.destination as? SelectDateViewController {
                destinationVC.planId = self.planId
                destinationVC.location = self.location
            }
        }
    }
    
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "AddToListFooterView") as? AddToListFooterView
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
        60
    }
}
