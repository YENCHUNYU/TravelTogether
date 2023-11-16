//
//  MapViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GoogleMaps
import CoreLocation

class MapViewController: UIViewController {
 
    @IBOutlet weak var mapView: GMSMapView!
    
    let locationManager = CLLocationManager()
    
    let searchVC = UISearchController(searchResultsController: MapsListViewController())
    

}

// MARK: - Lifecycle
extension MapViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

        locationManager.delegate = self

        // 2
        if CLLocationManager.locationServicesEnabled() {
          // 3
          locationManager.requestLocation()

          // 4
          mapView.isMyLocationEnabled = true
          mapView.settings.myLocationButton = true
        } else {
          // 5
          locationManager.requestWhenInUseAuthorization()
        }
      
      searchVC.searchResultsUpdater = self
      navigationItem.searchController = searchVC
      
  }
    
//    func setUpSearchBar() {
//        let searchBar = UISearchBar(frame: CGRect(x: 20, y: 20, width: UIScreen.main.bounds.width - 40, height: 40))
//            searchBar.placeholder = "搜尋地點"
//            mapView.addSubview(searchBar)
//        searchBar.searchTextField.addTarget(self, action: #selector(searchPlace), for: .touchUpInside)
//    }
//
//    @objc func searchPlace() {
//        performSegue(withIdentifier: "goToMapsList", sender: self)
//    }
    
}

// MARK: - CLLocationManagerDelegate
//1
extension MapViewController: CLLocationManagerDelegate {
  // 2
  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    // 3
    guard status == .authorizedWhenInUse else {
      return
    }
    // 4
    locationManager.requestLocation()

    //5
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }

  // 6
  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else {
      return
    }

    // 7
    mapView.camera = GMSCameraPosition(
      target: location.coordinate,
      zoom: 15,
      bearing: 0,
      viewingAngle: 0)
  }

  // 8
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
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        
    }
    
    
}
