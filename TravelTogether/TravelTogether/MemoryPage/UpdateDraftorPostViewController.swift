//
//  UpdateDraftorPostViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/12.
//

import UIKit

class UpdateDraftorPostViewController: UIViewController {
    var updateButtonTapped: (() -> Void)?
    var postButtonTapped: (() -> Void)?
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setTitle("", for: .normal)
        }
    }
    @IBOutlet weak var updateDraftButton: UIButton! {
        didSet {
            updateDraftButton.layer.cornerRadius = 8
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
    
    @IBAction func updateButtonTapped(_ sender: Any) {
        updateButtonTapped?()
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        postButtonTapped?()
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
