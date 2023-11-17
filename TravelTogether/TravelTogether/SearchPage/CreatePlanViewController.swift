//
//  CreatePlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore

class CreatePlanViewController: UIViewController {

    var planName = ""
    var onSave: ((String) -> Void)?
    
    @IBOutlet weak var planNameLabel: UILabel!
    
    @IBOutlet weak var planNameTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        var newTravelPlan = TravelPlan(id: nil, planName: "", destination: "", startDate: Date(), endDate: Date())
        if let planName = planNameTextField.text {
            onSave?(planName)
            newTravelPlan = TravelPlan(id: nil, planName: planName, destination: "Destination", startDate: Date(), endDate: Date())
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
        let travelPlanData = travelPlan.dictionary // Assuming TravelPlan has a dictionary property

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
