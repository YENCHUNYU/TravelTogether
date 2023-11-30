//
//  EditMemoryViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import UIKit
import FirebaseFirestore

class EditMemoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = "1sXW0pQVIAKEdFuLNeHK"
    var dayCounts = 1
    var selectedSectionForAddLocation = 0 // 新增景點
    var days: [String] = ["第1天", "＋"]
    let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        // section header
        tableView.register(
            EditPlanHeaderViewForSection.self,
            forHeaderFooterViewReuseIdentifier: "EditPlanHeaderViewForSection")
        
        // tableView header
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.delegate = self
        headerView.travelPlanId = travelPlanId
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        
        tableView.dragInteractionEnabled = true
        
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
                let counts = self.onePlan.days.count
                let originalCount = self.days.count
                    if counts >= originalCount {
                        for _ in originalCount...counts {
                            let number = self.days.count
                            self.days.insert("第\(number)天", at: number - 1)
                        }
                    }
                self.headerView.days = self.days
                self.headerView.onePlan = self.onePlan
                self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                self.onePlan = travelPlan
                self.tableView.reloadData()
//               self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
}

extension EditMemoryViewController: UITableViewDataSource {
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

        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.placeAddressLabel.text = location.address
        return cell
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
        selectedSectionForAddLocation = sender.tag
        performSegue(withIdentifier: "goToMapFromEditPlan", sender: self)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromEditPlan" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = false
                destinationVC.travelPlanId = travelPlanId
                destinationVC.selectedSection = selectedSectionForAddLocation
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }

    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
// HEADER FOR SECTIONS
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
           guard let headerView = tableView.dequeueReusableHeaderFooterView(
               withIdentifier: "EditPlanHeaderViewForSection") as? EditPlanHeaderViewForSection else {
                   return nil
           }

           headerView.deleteButtonHandler = { [weak self] in
               self?.deleteSection(at: section)
           }
           return headerView
       }

       func deleteSection(at index: Int) {
           onePlan.days.remove(at: index)
           days.remove(at: days.count - 2)

           let firestoreManagerForOne = FirestoreManagerForOne()
           firestoreManagerForOne.delegate = self
           firestoreManagerForOne.deleteDayFromTravelPlan(
            travelPlanId: travelPlanId, dayIndex: index) { error in
               if let error = error {
                   print("Error deleting section from Firestore: \(error)")
               } else {
                   print("Section deleted successfully from Firestore.")
//                   self.tableView.deleteSections(IndexSet(integer: index), with: .fade)
                   self.tableView.reloadData()
                   self.headerView.days = self.days
                   self.headerView.collectionView.reloadData()
               }
           }
       }
}

extension EditMemoryViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            80
    }
}

extension EditMemoryViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension EditMemoryViewController: EditPlanHeaderViewDelegate {
    func reloadNewData() {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
                let counts = self.onePlan.days.count
                self.days = ["+"]
                for count in 1...counts {
                    self.days.insert("第\(count)天", at: count - 1)
                }
                self.headerView.days = self.days
//                self.headerView.onePlan = self.onePlan
//                self.headerView.collectionView.reloadData()
               
                self.tableView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
    
    func passDays(daysData: [String]) {
        self.days = daysData
    }
    
    func reloadData() {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                self.onePlan = travelPlan
                self.tableView.reloadData()
                self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
}
