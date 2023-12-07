//
//  EditPlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit
import FirebaseFirestore
import MobileCoreServices
import UniformTypeIdentifiers

class EditPlanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = ""
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
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        
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
        let firestoreClearUser = FirestoreManagerForPostLocation()
        firestoreClearUser.delegate = self
        firestoreClearUser.clearLocationsUser(travelPlanId: travelPlanId) { error in
            if error != nil {
                print("Fail to clear users")
            } else {
                print("Clear users successfully!")
            }
        }
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

        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.placeAddressLabel.text = location.address
        cell.userLabel.layer.cornerRadius = 8
        cell.userLabel.layer.masksToBounds = true
        cell.userLabel.isHidden = true
        cell.userLabel.text = location.user
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

extension EditPlanViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            80
    }
    
    func tableView(_ tableView: UITableView, 
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
               
                let deletedLocation = onePlan.days[indexPath.section].locations.remove(at: indexPath.row)
               
                let firestoreManagerForOne = FirestoreManagerForOne()
                firestoreManagerForOne.delegate = self
                firestoreManagerForOne.deleteLocationFromTravelPlan(
                    travelPlanId: travelPlanId, dayIndex: indexPath.section,
                    location: deletedLocation) { error in
                    if let error = error {
                        print("Error deleting location from Firestore: \(error)")
                    } else {
                        print("Location deleted successfully from Firestore.")
                        tableView.reloadData()
                    }
                }
            }
        }
}

extension EditPlanViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension EditPlanViewController: EditPlanHeaderViewDelegate {
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

extension EditPlanViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, 
                   itemsForBeginning session: UIDragSession,
                   at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider()
        let dragItem = UIDragItem(itemProvider: itemProvider)
        return [dragItem]
    }
}

extension EditPlanViewController: UITableViewDropDelegate {
    
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func tableView(
        _ tableView: UITableView,
        performDropWith coordinator: UITableViewDropCoordinator) {
        coordinator.session.loadObjects(ofClass: NSString.self) { _ in
            var updatedIndexPaths = [IndexPath]()
            
            if let sourceIndexPath = coordinator.items.first?.sourceIndexPath,
               let destinationIndexPath = coordinator.destinationIndexPath {
                
                if sourceIndexPath.section == destinationIndexPath.section {
                    if sourceIndexPath.row != destinationIndexPath.row {
                        var locations = self.onePlan.days[sourceIndexPath.section].locations
                        
                        self.onePlan.days[sourceIndexPath.section].locations.remove(at: sourceIndexPath.row)
                        self.onePlan.days[sourceIndexPath.section].locations.insert(
                            locations[sourceIndexPath.row], at: destinationIndexPath.row)
                        updatedIndexPaths.append(destinationIndexPath)
                        
                        let firestoreUserManger = FirestoreManagerFetchUser()
                        firestoreUserManger.delegate = self
                        firestoreUserManger.fetchUserInfo(id: "456@test.com") { userData, error in
                            if error != nil {
                                print("Failed to fetch userInfo")
                            } else {
                                locations[destinationIndexPath.row].user = " \(String(describing: userData?.name ?? ""))已編輯 "
                                let firestoreMangerPostLocation = FirestoreManagerForPostLocation()
                                firestoreMangerPostLocation.updateLocationsOrder(
                                    travelPlanId: self.travelPlanId,
                                    dayIndex: sourceIndexPath.section,
                                    newLocationsOrder: self.onePlan.days[sourceIndexPath.section].locations
                                ) { error in
                                    if error != nil {
                                        print("Failed to reorder the locations")
                                    } else {
                                        print("Reorder the locations successfully!")
                                    }}}}}
                } else {
                    let locations = self.onePlan.days[sourceIndexPath.section].locations
                    self.onePlan.days[sourceIndexPath.section].locations.remove(at: sourceIndexPath.row)
                    tableView.reloadData()
                    let firestoreUserManger = FirestoreManagerFetchUser()
                    firestoreUserManger.delegate = self
                    firestoreUserManger.fetchUserInfo(id: "456@test.com") { userData, error  in
                        if error != nil {
                        } else {
//                            locations[destinationIndexPath.row].user = " \(String(describing: userData?.name ?? ""))已編輯 "
                            let firestoreMangerPostLocation = FirestoreManagerForPostLocation()
                            firestoreMangerPostLocation.updateLocationsOrder(
                                travelPlanId: self.travelPlanId,
                                dayIndex: sourceIndexPath.section,
                                newLocationsOrder: self.onePlan.days[sourceIndexPath.section].locations) { error in
                                    if error != nil {
                                        print("Failed to reorder the locations")
                                    } else {
                                        print("Reorder the locations successfully!")
                                        self.onePlan.days[destinationIndexPath.section].locations.insert(
                                            locations[sourceIndexPath.row], at: destinationIndexPath.row)
                                        updatedIndexPaths.append(destinationIndexPath)
                                        
                                        firestoreMangerPostLocation.updateLocationsOrder(
                                            travelPlanId: self.travelPlanId,
                                            dayIndex: destinationIndexPath.section,
                                            newLocationsOrder: self.onePlan.days[destinationIndexPath.section].locations) { error in
                                                if error != nil {
                                                    print("Failed to reorder the locations")
                                                } else {
                                                    print("Reorder the locations successfully!")
                                                } }}}}}}}
        }
    }
        func tableView(
            _ tableView: UITableView,
            dropSessionDidUpdate session: UIDropSession,
            withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
                return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
            }
}

extension EditPlanViewController: FirestoreManagerFetchUserDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: UserInfo) {
    }
}

extension EditPlanViewController: FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location) {
    }
}
