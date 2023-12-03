//
//  MapViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces

class MapViewController: UIViewController {
 
    @IBOutlet weak var mapView: GMSMapView!
    let locationManager = CLLocationManager()
    let searchVC = UISearchController(searchResultsController: MapsListViewController())
    var placesData: [Place] = []
    var mapInfoViewController: MapInfoViewController?
    var isFromSearch = true
    var travelPlanId = ""
    var selectedSection = 0
    var spotsPhotoUrl = ""
       
    var mapInfoView: UIView = {
        let mapInfo = UIView()
        mapInfo.translatesAutoresizingMaskIntoConstraints = false
        mapInfo.backgroundColor = .white
        mapInfo.layer.cornerRadius = 20
        return mapInfo
    }()
    
    var placeNameLabel: UILabel = {
        let name = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    var placeImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var addressLabel: UILabel = {
        let address = UILabel()
        address.translatesAutoresizingMaskIntoConstraints = false
        address.numberOfLines = 0
        address.font = UIFont.systemFont(ofSize: 16, weight: .light)
        return address
    }()
    
    lazy var addToPlanButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("加入行程", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(addToPlanButtonTapped), for: .touchUpInside)
        return button
    }()
    
}

// MARK: - Lifecycle
extension MapViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()

      searchVC.searchResultsUpdater = self
      navigationItem.searchController = searchVC
      
      mapView.addSubview(mapInfoView)
      mapInfoView.addSubview(placeImageView)
      mapInfoView.addSubview(addToPlanButton)
      mapInfoView.addSubview(placeNameLabel)
      mapInfoView.addSubview(addressLabel)
      setUpUI()
      mapInfoView.isHidden = true
    
  }
    
    func setUpUI() {
        mapInfoView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10).isActive = true
        mapInfoView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10).isActive = true
        mapInfoView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive = true
        mapInfoView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
        placeImageView.leadingAnchor.constraint(equalTo: mapInfoView.leadingAnchor, constant: 10).isActive = true
        placeImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        placeImageView.heightAnchor.constraint(equalTo: placeImageView.widthAnchor, multiplier: 3/4).isActive = true
        placeImageView.topAnchor.constraint(equalTo: mapInfoView.topAnchor, constant: 10).isActive = true
        
        addToPlanButton.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 15).isActive = true
        addToPlanButton.trailingAnchor.constraint(
            lessThanOrEqualTo: mapInfoView.trailingAnchor, constant: -15).isActive = true
        addToPlanButton.topAnchor.constraint(equalTo: mapInfoView.topAnchor, constant: 15).isActive = true
        
        placeNameLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 15).isActive = true
        placeNameLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: mapInfoView.trailingAnchor, constant: -15).isActive = true
        placeNameLabel.topAnchor.constraint(equalTo: addToPlanButton.bottomAnchor, constant: 10).isActive = true
        
        addressLabel.leadingAnchor.constraint(equalTo: placeImageView.trailingAnchor, constant: 15).isActive = true
        addressLabel.trailingAnchor.constraint(
            lessThanOrEqualTo: mapInfoView.trailingAnchor, constant: -15).isActive = true
        addressLabel.topAnchor.constraint(equalTo: placeNameLabel.bottomAnchor, constant: 10).isActive = true
        
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {

    guard status == .authorizedWhenInUse else {
      return
    }

    locationManager.requestLocation()
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }

//    mapView.camera = GMSCameraPosition(
//      target: location.coordinate,
//      zoom: 15,
//      bearing: 0,
//      viewingAngle: 0)
//    mapView.isUserInteractionEnabled = true

  }

  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    print(error)
  }
}

extension MapViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? MapsListViewController else {
            return
        }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                print(places)
                self.placesData = places
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
}

extension MapViewController: MapListViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D, indexPath: IndexPath) {
        mapInfoView.isHidden = false
        searchVC.searchBar.resignFirstResponder()
        mapView.clear()
        
        let marker = GMSMarker()
        marker.position = coordinates
        marker.map = mapView
        
        let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 15.0)
        mapView.animate(to: camera)
     
        placeNameLabel.text = placesData[indexPath.row].name
        addressLabel.text = placesData[indexPath.row].address
        GooglePlacesManager.shared.fetchMapPhoto(for: placesData[indexPath.row].identifier) { result in
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
    
//extension MapViewController: UIViewControllerTransitioningDelegate {
//    func presentationController(
//        forPresented presented: UIViewController,
//        presenting: UIViewController?,
//        source: UIViewController) -> UIPresentationController? {
//        return MapInfoPresentationController(presentedViewController: presented, presenting: presenting)
//    }
//}

//class MapInfoPresentationController: UIPresentationController {
//    override var frameOfPresentedViewInContainerView: CGRect {
//        guard let containerView = containerView else { return CGRect.zero }
//
//        let height: CGFloat = containerView.bounds.height / 2.0
//        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
//    }
//}

extension MapViewController {
    @objc func addToPlanButtonTapped(sender: UIButton) {
        if isFromSearch {
            let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
            firebaseStorageManager.delegate = self
            firebaseStorageManager.uploadPhotoToFirebaseStorage(
                image: self.placeImageView.image ?? UIImage()) { uploadResult in
                        switch uploadResult {
                        case .success(let downloadURL):
                            print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")
                            self.spotsPhotoUrl = downloadURL.absoluteString
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
            firebaseStorageManager.uploadPhotoToFirebaseStorage(
                image: self.placeImageView.image ?? UIImage()) { uploadResult in
                switch uploadResult {
                case .success(let downloadURL):
                    print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")
                    self.spotsPhotoUrl = downloadURL.absoluteString
                    let theLocation = Location(
                        name: "\(String(describing: self.placeNameLabel.text ?? "") )", photo: self.spotsPhotoUrl,
                        address: "\(String(describing: self.addressLabel.text ?? ""))")
                    firestoreManagerPostLocation.addLocationToTravelPlan(
                        planId: self.travelPlanId, location: theLocation, day: self.selectedSection) { error in
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
                      let destinationVC = navigationController.viewControllers.first
                        as? AddToPlanListViewController else {
                    fatalError("Cannot access AddToPlanListViewController")
                }
            destinationVC.location = Location(
                name: "\(String(describing: self.placeNameLabel.text ?? "") )", photo: self.spotsPhotoUrl,
                address: "\(String(describing: self.addressLabel.text ?? ""))")
            }
    }
}

extension MapViewController: FirebaseStorageManagerDelegate {
    func manager(_ manager: FirebaseStorageManagerUploadPhotos) {
    }
}

extension MapViewController: FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location) {
    }
}
