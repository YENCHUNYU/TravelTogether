//
//  MapInfoViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class MapInfoViewController: UIViewController {
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var addToPlanButton: UIButton!
    
    @IBOutlet weak var addressLabel: UILabel!
    var places = Place(name: "", identifier: "", address: "")
    var isFromSearch = false
    var spotsPhotoUrl = ""
    var travelPlanId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeNameLabel.text = places.name
        GooglePlacesManager.shared.fetchMapPhoto(for: places.identifier) { result in
            switch result {
            case .success(let photo):
                print("fetching photo")
                self.placeImageView.image = photo
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 400, width: UIScreen.main.bounds.width, height: 400 )
    }
    
    @IBAction func addToPlanButtonTapped(_ sender: Any) {
        if isFromSearch {
            
            let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
            firebaseStorageManager.delegate = self
            firebaseStorageManager.uploadPhotoToFirebaseStorage(image: self.placeImageView.image ?? UIImage()) { uploadResult in
                        switch uploadResult {
                        case .success(let downloadURL):
                            print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")
                            self.spotsPhotoUrl = downloadURL.absoluteString
                            // Here, you can save the downloadURL to Firestore or perform other actions.
                        case .failure(let error):
                            print("Error uploading to Firebase Storage: \(error.localizedDescription)")
                        }
                    }
            performSegue(withIdentifier: "goToPlanList", sender: sender)
        } else {
            
            let firestoreManagerPostLocation = FirestoreManagerForPostLocation()
            firestoreManagerPostLocation.delegate = self
            
            let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
            firebaseStorageManager.delegate = self
            firebaseStorageManager.uploadPhotoToFirebaseStorage(image: self.placeImageView.image ?? UIImage()) { uploadResult in
                switch uploadResult {
                case .success(let downloadURL):
                    print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")
                    self.spotsPhotoUrl = downloadURL.absoluteString
                    let theLocation = Location(name: self.places.name, photo: self.spotsPhotoUrl, address: self.places.address)
                    firestoreManagerPostLocation.addLocationToTravelPlan(planId: self.travelPlanId, location: theLocation) { error in
                        if let error = error {
                            print("Error posting travel plan: \(error)")
                        } else {
                            print("Travel plan posted for day successfully!")
                            if let navigationController = self.navigationController {
                             let viewControllers = navigationController.viewControllers
                             if viewControllers.count >= 2 {
                                 let targetViewController = viewControllers[viewControllers.count - 2]
                                 navigationController.popToViewController(targetViewController, animated: true)
                                             }
                                         }
                        }
                    }
                case .failure(let error):
                    print("Error uploading to Firebase Storage: \(error.localizedDescription)")
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPlanList" {
                guard let navigationController = segue.destination as? UINavigationController,
                      let destinationVC = navigationController.viewControllers.first as? AddToPlanListViewController else {
                    fatalError("Cannot access AddToPlanListViewController")
                }
            destinationVC.location = Location(name: places.name, photo: spotsPhotoUrl, address: places.address)
            }
    }
    // 如果再搜尋一次景點就再更新mapinfo
    func updateContent() {
        placeNameLabel.text = places.name
        
        GooglePlacesManager.shared.fetchMapPhoto(for: places.identifier) { result in
            switch result {
            case .success(let photo):
                print("fetching photo")
                self.placeImageView.image = photo
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
}

extension MapInfoViewController: FirebaseStorageManagerUploadPhotosDelegate {
    func manager(_ manager: FirebaseStorageManagerUploadPhotos) {
    }
}

extension MapInfoViewController: FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location) {
    }
}
