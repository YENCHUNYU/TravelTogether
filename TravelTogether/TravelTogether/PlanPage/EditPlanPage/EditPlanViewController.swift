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
import FirebaseAuth
import NVActivityIndicatorView
import SwiftEntryKit

class EditPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
//    var travelPlanId = "6PGNVZ0ZNZwgyBi9EcPW"
    var dayCounts = 1
    var selectedSectionForAddLocation = 0 // 新增景點
    var days: [String] = ["第1天", "＋"]
    let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
        type: .ballBeat,
        color: UIColor(named: "darkGreen") ?? .white,
        padding: 0
    )
    var blurEffectView: UIVisualEffectView!
//    var togetherDocref: Any?
//    var userId = "5ZpUJ6ySMnTNY48ChD6YGXEF89j2"
    var userId: String = ""
    var travelPlanId: String = ""
    var url = ""

        // ... other properties and methods ...

        func setProperties(userId: String, planId: String, completion: @escaping () -> Void) {
            self.userId = userId
            self.travelPlanId = planId
            completion()
        }
    lazy var inviteUserButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "person.2.fill"), for: .normal)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(inviteButtonTapped), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.tintColor = .white
        return button
    }()
    
    @objc func inviteButtonTapped() {
        
        let title = "傳送連結邀請"
        let message = "用戶點擊連結並登入即可共同編輯此行程"
//        let urlScheme = "https://traveltogether.page.link/test1"
                
//        let dynamicLinkURL = "https://traveltogether.page.link/test1?userId=\(String(describing: self.onePlan.userId ?? ""))&planId=\(self.travelPlanId)"
        let urlScheme = "traveltogether://userId/\(String(describing: Auth.auth().currentUser?.uid ?? ""))/planId/\(self.travelPlanId)"

        showAlert(title: title, message: message, completion: {
            let activityVC = UIActivityViewController(activityItems: [urlScheme], applicationActivities: nil)
//                self.present(activityVC, animated: true, completion: nil)
            activityVC.completionWithItemsHandler = {(activityType: UIActivity.ActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                    // 如果錯誤存在，跳出錯誤視窗並顯示給使用者。
                    if error != nil {
                        self.showAlert(title: "錯誤", message: "無法傳送連結")
                        return
                    }
                                                         
                    // 如果發送成功，跳出提示視窗顯示成功。
                    if completed {
                        self.showAlert(title: "成功", message: "已傳送連結！")
                    }
                }

                self.present(activityVC, animated: true, completion: nil)

        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(inviteUserButton)
        setUpButton()
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
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
        firestoreManagerForOne.fetchOneTravelPlan(dbCollection: "TravelPlan", userId: userId, byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
//                self.togetherDocref = ref
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
        if url != "" {
            let planRef = Firestore.firestore().collection("UserInfo").document(self.userId).collection("TravelPlan").document(self.travelPlanId)
            let firestoreRef = FirestoreTogether()
            firestoreRef.postFullPlan(planRef: planRef) { error  in
                if error != nil {
                    print("Failed to post planRef")
                } else {
                   print("Post planRef successfully!")
                }
                
            }
        }
    }
    func setUpButton() {
        inviteUserButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        inviteUserButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { [weak self] action in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()

        
        
//        let firestoreClearUser = FirestoreManagerForPostLocation()
//        firestoreClearUser.delegate = self
//        firestoreClearUser.clearLocationsUser(travelPlanId: travelPlanId) { error in
//            if error != nil {
//                print("Fail to clear users")
//            } else {
//                print("Clear users successfully!")
//            }
//        }
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(dbCollection: "TravelPlan", userId: userId, byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                self.onePlan = travelPlan
//                self.togetherDocref = ref
                self.tableView.reloadData()
                let allDaysHaveNoLocations = self.onePlan.days.allSatisfy { $0.locations.isEmpty }

                    if allDaysHaveNoLocations {
                        self.activityIndicatorView.stopAnimating()
                        self.blurEffectView.removeFromSuperview()
                        self.activityIndicatorView.removeFromSuperview()
                    }
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
        else { 
//            fatalError("Could not create EditPlanCell")
            return UITableViewCell()
        }
        cell.locationImageView.image = nil
        
        let location = onePlan.days[indexPath.section].locations[indexPath.row]
        
        cell.placeNameLabel.text = location.name
        cell.placeAddressLabel.text = location.address
        let firestorage = FirebaseStorageManagerDownloadPhotos()
        let urlString = location.photo
        
        // Record the URL being processed by this cell
        cell.currentImageURL = urlString
        
        if !urlString.isEmpty, let url = URL(string: urlString) {
            firestorage.downloadPhotoFromFirebaseStorage(url: url) { image in
                DispatchQueue.main.async {
                    // Check if the URL still matches the current cell's URL
                    if cell.currentImageURL == urlString {
                        if let image = image {
                            cell.locationImageView.image = image
                        } else {
                            cell.locationImageView.image = UIImage(named: "Image_Placeholder")
                        }
                    }
                }
                self.activityIndicatorView.stopAnimating()
                self.blurEffectView.removeFromSuperview()
                self.activityIndicatorView.removeFromSuperview()
            }
        } else {
            self.activityIndicatorView.stopAnimating()
            self.blurEffectView.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
        
        return cell
    }

// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "EditPlanFooterView") as? EditPlanFooterView
        else { 
//            fatalError("Could not create EditPlanFooterView")
            return view
        }
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
           view.addSubview(blurEffectView)
           view.addSubview(activityIndicatorView)
           activityIndicatorView.startAnimating()
           let allDaysHaveNoLocations = onePlan.days.allSatisfy { $0.locations.isEmpty }

               if allDaysHaveNoLocations {
                   self.activityIndicatorView.stopAnimating()
                   self.blurEffectView.removeFromSuperview()
                   self.activityIndicatorView.removeFromSuperview()
               }
           onePlan.days.remove(at: index)
           days.remove(at: days.count - 2)

           let firestoreManagerForOne = FirestoreManagerForOne()
           firestoreManagerForOne.delegate = self
           firestoreManagerForOne.deleteDayFromTravelPlan(
            userId: userId, travelPlanId: travelPlanId, dayIndex: index) { error in
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
            100
    }
    
    func tableView(_ tableView: UITableView, 
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                view.addSubview(blurEffectView)
                view.addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                let allDaysHaveNoLocations = onePlan.days.allSatisfy { $0.locations.isEmpty }

                    if allDaysHaveNoLocations {
                        self.activityIndicatorView.stopAnimating()
                        self.blurEffectView.removeFromSuperview()
                        self.activityIndicatorView.removeFromSuperview()
                    }
                let deletedLocation = onePlan.days[indexPath.section].locations.remove(at: indexPath.row)
               
                let firestoreManagerForOne = FirestoreManagerForOne()
                firestoreManagerForOne.delegate = self
                firestoreManagerForOne.deleteLocationFromTravelPlan(
                    travelPlanId: travelPlanId, dayIndex: indexPath.section,
                    location: deletedLocation, userId: userId) { error in
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
        firestoreManagerForOne.fetchOneTravelPlan(dbCollection: "TravelPlan", userId: userId, byId: travelPlanId)  { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
//                self.togetherDocref = ref
                let counts = self.onePlan.days.count
                self.days = ["+"]
                for count in 1...counts {
                    self.days.insert("第\(count)天", at: count - 1)
                }
                self.headerView.days = self.days
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
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        let allDaysHaveNoLocations = onePlan.days.allSatisfy { $0.locations.isEmpty }

            if allDaysHaveNoLocations {
                self.activityIndicatorView.stopAnimating()
                self.blurEffectView.removeFromSuperview()
                self.activityIndicatorView.removeFromSuperview()
            }
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(dbCollection: "TravelPlan", userId: userId, byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                self.onePlan = travelPlan
//                self.togetherDocref = ref
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
            view.addSubview(blurEffectView)
            view.addSubview(activityIndicatorView)
            activityIndicatorView.startAnimating()
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
                        firestoreUserManger.fetchUserInfo { userData, error in
                            if error != nil {
                                print("Failed to fetch userInfo")
                            } else {
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
                    firestoreUserManger.fetchUserInfo { userData, error  in
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
