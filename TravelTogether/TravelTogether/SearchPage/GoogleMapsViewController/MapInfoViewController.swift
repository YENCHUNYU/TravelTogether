//
//  MapInfoViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit

class MapInfoViewController: UIViewController {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    @IBOutlet weak var addToPlanButton: UIButton!
    
    var places = Place(name: "", identifier: "", address: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeNameLabel.text = places.name
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 400 , width: UIScreen.main.bounds.width, height: 400 )
    }
    
    @IBAction func addToPlanButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToPlanList", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlanList" {
                guard let navigationController = segue.destination as? UINavigationController,
                      let destinationVC = navigationController.viewControllers.first as? AddToPlanListViewController else {
                    fatalError("Cannot access AddToPlanListViewController")
                }

                let spotName = places.name
                destinationVC.spotName = spotName
            }
    }
    
}
