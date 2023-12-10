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
    @IBOutlet weak var datePickerContrainerView: UIView! {
        didSet {
            datePickerContrainerView.layer.cornerRadius = 15
            datePickerContrainerView.clipsToBounds = true
        }
    }

    @IBOutlet weak var startLabel: UILabel! {
        didSet {
            startLabel.layer.cornerRadius = 5
            startLabel.layer.masksToBounds = true
        }
    }
    
    @IBOutlet weak var endLabel: UILabel! {
        didSet {
            endLabel.layer.cornerRadius = 5
            endLabel.layer.masksToBounds = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let datePickerView = DatePickerView { [weak self] start, end in
            self?.startDate = start
            self?.endDate = end
        }
        let hostingController = UIHostingController(rootView: datePickerView)
        addChild(hostingController)
        hostingController.view.frame = datePickerContrainerView.bounds
        datePickerContrainerView.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    //    let emptyDay = TravelDay(locations: [])
        if let planName = planNameTextField.text {
            newTravelPlan = TravelPlan(
                id: "",
                planName: planName,
                destination: "Destination",
                startDate: startDate ?? Date(),
                endDate: endDate ?? Date(),
                days: [],
                user: Auth.auth().currentUser?.displayName,
                userPhoto: Auth.auth().currentUser?.photoURL?.absoluteString,
                userId: Auth.auth().currentUser?.uid
            )
        }
        
        let firestoreManagerForPost = FirestoreManagerForPost()
        firestoreManagerForPost.delegate = self
        firestoreManagerForPost.postTravelPlan(travelPlan: newTravelPlan) { error in
            if let error = error {
                print("Error posting travel plan: \(error)")
            } else {
                print("Travel plan posted successfully!")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
}

extension CreatePlanViewController: FirestoreManagerForPostDelegate {
    func manager(_ manager: FirestoreManagerForPost, didPost firestoreData: TravelPlan) {
        newTravelPlan = firestoreData
    }
}
