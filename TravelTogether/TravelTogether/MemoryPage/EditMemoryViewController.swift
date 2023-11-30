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
//    var selectedSectionForAddLocation = 0 // 新增景點
    var days: [String] = ["第1天"]
    let headerView = EditMemoryHeaderView(reuseIdentifier: "EditMemoryHeaderView")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

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
                    if counts > originalCount {
                        for _ in originalCount...counts - 1 {
                            let number = self.days.count
                            self.days.insert("第\(number + 1)天", at: number)
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
            withIdentifier: "EditMemoryCell",
            for: indexPath) as? EditMemoryCell
        else { fatalError("Could not create EditMemoryCell") }

        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.addressLabel.text = location.address
        return cell
    }
}

extension EditMemoryViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            200
    }
}

extension EditMemoryViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension EditMemoryViewController: EditMemoryHeaderViewDelegate {
    
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

extension EditMemoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func choosePhoto() {
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .photoLibrary
           present(imagePicker, animated: true, completion: nil)
       }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[.originalImage] as? UIImage {
               // 处理选中的照片，例如显示在UIImageView中
//               yourImageView.image = selectedImage
           }

           picker.dismiss(animated: true, completion: nil)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
}
