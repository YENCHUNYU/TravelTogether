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
//    var onSave: ((String) -> Void)?
    var startDate: Date?
    var endDate: Date?
    
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
        var newTravelPlan = TravelPlan(id: nil, planName: "", destination: "", startDate: Date(), endDate: Date())
        
        if let planName = planNameTextField.text {
            newTravelPlan = TravelPlan(id: nil, planName: planName, destination: "Destination", startDate: startDate ?? Date(), endDate: endDate ?? Date())
//            navigationController?.popViewController(animated: true)
        }
        
        postTravelPlan(travelPlan: newTravelPlan) { error in
            if let error = error {
                print("Error posting travel plan: \(error)")
            } else {
                print("Travel plan posted successfully!")
            }
        }
        navigationController?.popViewController(animated: true)
    }
    
}

extension CreatePlanViewController {
    // Firestore
    func postTravelPlan(travelPlan: TravelPlan, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        var ref: DocumentReference? = nil
        let travelPlanData = travelPlan.dictionary

        ref = db.collection("TravelPlan").addDocument(data: travelPlanData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                completion(nil)
            }
        }
    }
}
