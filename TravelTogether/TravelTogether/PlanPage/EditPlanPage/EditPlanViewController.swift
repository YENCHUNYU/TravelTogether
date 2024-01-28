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
import Kingfisher

class EditPlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var dayCounts = 1
    var selectedSectionForAddLocation = 0 // 新增景點
    var days: [String] = ["第1天", "＋"]
    let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: UIScreen.main.bounds.height / 2 - 25,
            width: 50, height: 50),
        type: .ballBeat,
        color: UIColor(named: "darkGreen") ?? .white,
        padding: 0
    )
    var blurEffectView: UIVisualEffectView!
    var userId: String = ""
    var travelPlanId: String = ""
    var url = ""
    var fetchedImageCounts = 0
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
        let userIdS = "\(String(describing: Auth.auth().currentUser?.uid ?? ""))"
        let urlScheme = "traveltogether://userId/\(userIdS)/planId/\(self.travelPlanId)"

        showAlert(title: title, message: message, completion: {
            let activityVC = UIActivityViewController(activityItems: [urlScheme], applicationActivities: nil)
            activityVC.completionWithItemsHandler = { (_, completed: Bool, _, error: Error?) in
                    if error != nil {
                        self.showAlert(title: "錯誤", message: "無法傳送連結")
                        return
                    }
                    if completed {
                        self.showAlert(title: "成功", message: "已傳送連結！")
                    }
                }
                self.present(activityVC, animated: true, completion: nil)
        })
    }
    
    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
    }
    
    func configureTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = self
        tableView.dropDelegate = self
    }
    
    func configureHeaderView() {
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        tableView.register(
                   EditPlanHeaderViewForSection.self,
                   forHeaderFooterViewReuseIdentifier: "EditPlanHeaderViewForSection")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.travelPlanId = travelPlanId
        headerView.delegate = self
        tableView.tableHeaderView = headerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(inviteUserButton)
        setUpButton()
        configureBlurEffectView()
        configureTableView()
        configureHeaderView()
        fetchTravelPlan()
        postPlanRef()
    }
    
    func postPlanRef() {
        if url != "" {
            let userRef = Firestore.firestore().collection("UserInfo").document(self.userId)
            let planRef = userRef.collection("TravelPlan").document(self.travelPlanId)
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
    
    func addLoadingView() {
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func stopLoading() {
        self.activityIndicatorView.stopAnimating()
        self.blurEffectView.removeFromSuperview()
        self.activityIndicatorView.removeFromSuperview()
    }
    
    func checkAndRemoveLoading() {
        guard onePlan.days.first?.locations.count ?? 0 > 0 else {
            stopLoading()
            return
        }
        if onePlan.days.count > 1 {
            if fetchedImageCounts >= onePlan.days.first?.locations.count ?? 0 + onePlan.days[1].locations.count {
                stopLoading()
                fetchedImageCounts = 0
            }
        } else {
            if fetchedImageCounts >= onePlan.days.first?.locations.count ?? 0 {
                stopLoading()
                fetchedImageCounts = 0
            }
        }
    }
    
    func fetchTravelPlan() {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.fetchOneTravelPlan(
            dbCollection: "TravelPlan", userId: userId,
            byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
                self.tableView.reloadData()
                self.checkIfEmpty()
                self.configureDays()
            } else {
                print("One travel plan not found.")
            }
        }
    }
    
    func configureDays() {
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
    }
    
    func checkIfEmpty() {
        let allDaysHaveNoLocations = self.onePlan.days.allSatisfy { $0.locations.isEmpty }
            if allDaysHaveNoLocations {
                self.stopLoading()
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
        
        let okAction = UIAlertAction(title: "確定", style: .default) { _ in
            completion?()
        }
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadingView()
        fetchTravelPlan()
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
            fatalError("Could not create EditPlanCell")
        }
        cell.locationImageView.image = nil
        let location = onePlan.days[indexPath.section].locations[indexPath.row]
        cell.placeNameLabel.text = location.name
        cell.placeAddressLabel.text = location.address
        let urlString = location.photo
        cell.currentImageURL = urlString
        if !urlString.isEmpty, let url = URL(string: urlString) {
            downloadImages(url: url, cell: cell)
        } else {
            stopLoading()
        }
        return cell
    }
    
    func downloadImages(url: URL, cell: EditPlanCell) {
        cell.locationImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Image_Placeholder"),
            options: [
                .transition(.fade(0.2)), 
                .cacheOriginalImage
            ],
            completionHandler: { _ in
                self.fetchedImageCounts += 1
                self.checkAndRemoveLoading()
            }
        )
    }

// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: "EditPlanFooterView") as? EditPlanFooterView
        else { 
            fatalError("Could not create EditPlanFooterView")
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
           addLoadingView()
           let allDaysHaveNoLocations = onePlan.days.allSatisfy { $0.locations.isEmpty }

               if allDaysHaveNoLocations {
                   stopLoading()
               }
           onePlan.days.remove(at: index)
           days.remove(at: days.count - 2)
           deleteADay(index: index)
       }
    
    func deleteADay(index: Int) {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.deleteDayFromTravelPlan(
         userId: userId, travelPlanId: travelPlanId, dayIndex: index) { error in
            if let error = error {
                print("Error deleting section from Firestore: \(error)")
            } else {
                print("Section deleted successfully from Firestore.")
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
                addLoadingView()
                let allDaysHaveNoLocations = onePlan.days.allSatisfy { $0.locations.isEmpty }

                    if allDaysHaveNoLocations {
                        stopLoading()
                    }
                let deletedLocation = onePlan.days[indexPath.section].locations.remove(at: indexPath.row)
                deleteLocation(indexPath: indexPath, deletedLocation: deletedLocation)
            }
        }
    
    func deleteLocation(indexPath: IndexPath, deletedLocation: Location) {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.deleteLocationFromTravelPlan(
            travelPlanId: travelPlanId, dayIndex: indexPath.section,
            location: deletedLocation, userId: userId) { error in
            if let error = error {
                print("Error deleting location from Firestore: \(error)")
            } else {
                print("Location deleted successfully from Firestore.")
                self.tableView.reloadData()
            }
        }
    }
}

extension EditPlanViewController: EditPlanHeaderViewDelegate {
    func reloadNewData() {
        addLoadingView()
        fetchTravelPlan()
    }
    
    func passDays(daysData: [String]) {
        self.days = daysData
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
        addLoadingView()
        coordinator.session.loadObjects(ofClass: NSString.self) { _ in
            if let sourceIndexPath = coordinator.items.first?.sourceIndexPath,
               let destinationIndexPath = coordinator.destinationIndexPath {
                if sourceIndexPath.section == destinationIndexPath.section {
                    self.handleSameSectionDrop(sourceIndexPath: sourceIndexPath,
                                               destinationIndexPath: destinationIndexPath)
                } else {
                    self.handleDifferentSectionDrop(sourceIndexPath: sourceIndexPath,
                                                    destinationIndexPath: destinationIndexPath)
                }
            }
        }
    }
    
    func handleSameSectionDrop(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        guard sourceIndexPath.row != destinationIndexPath.row else {
            stopLoading()
            return }
        let locations = self.onePlan.days[sourceIndexPath.section].locations
        self.onePlan.days[sourceIndexPath.section].locations.remove(at: sourceIndexPath.row)
        self.onePlan.days[sourceIndexPath.section].locations.insert(
            locations[sourceIndexPath.row], at: destinationIndexPath.row)
        self.updateLocationOrder(dayIndex: sourceIndexPath.section)
    }
    
    func handleDifferentSectionDrop(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let locations = self.onePlan.days[sourceIndexPath.section].locations
        self.onePlan.days[sourceIndexPath.section].locations.remove(at: sourceIndexPath.row)
        tableView.reloadData()
        updateLocationOrder(dayIndex: sourceIndexPath.section) {
            self.onePlan.days[destinationIndexPath.section].locations.insert(
                locations[sourceIndexPath.row], at: destinationIndexPath.row)
            self.updateLocationOrder(dayIndex: destinationIndexPath.section)
        }
    }
    
    func updateLocationOrder(dayIndex: Int, completion: (() -> Void)? = nil) {
        let firestoreMangerPostLocation = FirestoreManagerForPostLocation()
        firestoreMangerPostLocation.updateLocationsOrder(
            travelPlanId: self.travelPlanId,
            dayIndex: dayIndex,
            newLocationsOrder: self.onePlan.days[dayIndex].locations
        ) { error in
            if error != nil {
                print("Failed to reorder the locations")
            } else {
                print("Reorder the locations successfully!")
                completion?()
            }
        }
    }
    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}
