//
//  CreatePlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit

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
        if let planName = planNameTextField.text {
            onSave?(planName)
        }
        navigationController?.popViewController(animated: true)
    }
    
}
