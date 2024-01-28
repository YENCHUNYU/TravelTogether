//
//  CreatePlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore
import SwiftUI
import FirebaseAuth

class CreatePlanViewController: UIViewController {

    var planName = ""
    var startDate: Date?
    var endDate: Date?
    var newTravelPlan = TravelPlan(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])
    
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton! {
        didSet {
            saveButton.layer.cornerRadius = 10
        }
    }
    
    @IBOutlet weak var startLabel: UILabel! {
        didSet {
            startLabel.layer.cornerRadius = 5
            startLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var startDatePicker: UIDatePicker! {
        didSet {
            startDatePicker.layer.cornerRadius = 8
            startDatePicker.layer.masksToBounds = true
            startDatePicker.backgroundColor = UIColor(named: "lightGreen")
            startDatePicker.addTarget(self, action: #selector(startDateValueChanged(_:)), for: .valueChanged)
              }
          }

    @objc func startDateValueChanged(_ sender: UIDatePicker) {
      startDate = sender.date
      endDatePicker.minimumDate = startDate
    }
    
    @IBOutlet weak var endDatePicker: UIDatePicker! {
        didSet {
            endDatePicker.layer.cornerRadius = 8
            endDatePicker.layer.masksToBounds = true
            endDatePicker.backgroundColor = UIColor(named: "lightGreen")
            endDatePicker.addTarget(self, action: #selector(endDateValueChanged(_:)), for: .valueChanged)
        }
    }
    @objc func endDateValueChanged(_ sender: UIDatePicker) {
        endDate = sender.date
    }
    
    @IBOutlet weak var endLabel: UILabel! {
        didSet {
            endLabel.layer.cornerRadius = 5
            endLabel.layer.masksToBounds = true
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        fetchUserInfo { [weak self] userData in
            guard let self = self else { return }
            self.newTravelPlan.user = userData.name
            self.newTravelPlan.userPhoto = userData.photo
            self.newTravelPlan.userId = userData.id
            
            if let planName = self.planNameTextField.text {
                self.newTravelPlan.planName = planName
            }
            
            self.newTravelPlan.startDate = self.startDate ?? Date()
            self.newTravelPlan.endDate = self.endDate ?? Date()
            self.postNewPlanToDB()
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func fetchUserInfo(completion: @escaping(UserInfo) -> Void) {
        let firestore = FirestoreManagerFetchUser()
        firestore.fetchUserInfo { userData, error  in
            if error != nil {
                print("Error fetching one plan: \(String(describing: error))")
            } else {
                completion(userData ?? UserInfo(email: "", name: "", id: ""))
            }
        }
    }
    
    func postNewPlanToDB() {
        let firestoreManagerForPost = FirestoreManagerForPostPlan()
        firestoreManagerForPost.postTravelPlan(travelPlan: self.newTravelPlan) { error in
            if let error = error {
                print("Error posting travel plan: \(error)")
            } else {
                print("Travel plan posted successfully!")
            }
        }
    }
}
