//
//  CreatePlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore
import SwiftUI

class CreatePlanViewController: UIViewController {

    var planName = ""
    var startDate: Date?
    var endDate: Date?
    var newTravelPlan = TravelPlan(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])
    
    @IBOutlet weak var planNameLabel: UILabel!
    @IBOutlet weak var planNameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var datePickerContrainerView: UIView!
    
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
  
        if let planName = planNameTextField.text {
            newTravelPlan = TravelPlan(
                id: "",
                planName: planName,
                destination: "Destination",
                startDate: startDate ?? Date(),
                endDate: endDate ?? Date(),
                days: [])
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
