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

    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = ""
    var dayCounts = 1
    var selectedSection = 0
    var days: [String] = ["第1天", "＋"]
    let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.delegate = self
        headerView.travelPlanId = travelPlanId

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
                self.headerView.onePlan = self.onePlan
                self.headerView.collectionView.reloadData()
                var counts = self.onePlan.days.count
                let originalCount = self.days.count
                print("rrrrr\(counts)")
                    if counts > originalCount {
                        for _ in originalCount...counts {
                            let count = self.days.count
                            self.days.insert("第\(count)天", at: count - 1)
                            print("days!!!\(self.days)")
                        }
                    }
                self.headerView.days = self.days
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
                self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
}

extension EditPlanViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        onePlan.days.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "第\(section + 1)天"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !onePlan.days.isEmpty, section < onePlan.days.count else {
               return 0
           }
           return onePlan.days[section].locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "EditPlanCell",
                for: indexPath) as? EditPlanCell
            else { fatalError("Could not create EditPlanCell") }
        cell.placeNameLabel.text = onePlan.days[indexPath.section].locations[indexPath.row].name
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "EditPlanFooterView") as? EditPlanFooterView
        else { fatalError("Could not create EditPlanFooterView") }
        view.addNewLocationButton.addTarget(
            self,
            action: #selector(addNewLocationButtonTapped(_:)),
            for: .touchUpInside)
        view.addNewLocationButton.tag = section
        return view
    }
  
    @objc func addNewLocationButtonTapped(_ sender: UIButton) {
        selectedSection = sender.tag
        performSegue(withIdentifier: "goToMapFromEditPlan", sender: self)
        print("eeee\(selectedSection)")
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromEditPlan" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = false
                destinationVC.travelPlanId = travelPlanId
                destinationVC.selectedSection = selectedSection
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

extension EditPlanViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension EditPlanViewController: EditPlanHeaderViewDelegate {
    func reloadData() {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
                self.tableView.reloadData()
                self.headerView.onePlan = travelPlan
                self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
}
