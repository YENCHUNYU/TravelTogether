//
//  SaveAsDraftorPostViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/12.
//
import UIKit
import FirebaseAuth

class SaveAsDraftorPostViewController: UIViewController {
    var toPostButtonTapped: (() -> Void)?
    var toSaveButtonTapped: (() -> Void)?
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [], coverPhoto: "")
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var saveAsDraftButton: UIButton! {
        didSet {
            saveAsDraftButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var toPostButton: UIButton! {
        didSet {
            toPostButton.layer.cornerRadius = 8
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func saveAsDraftButtonTapped(_ sender: Any) {

    toSaveButtonTapped?()
    }
    
    @IBAction func toPostButtonTapped(_ sender: Any) {
        toPostButtonTapped?()     
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 270,
                            width: UIScreen.main.bounds.width, height: 270 )
    }
      
}
