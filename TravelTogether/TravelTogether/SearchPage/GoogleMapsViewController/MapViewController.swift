//
//  MapViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GoogleMaps

class MapViewController: UIViewController {
 
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var pinImageView: UIImageView!
    
    let locationManager = CLLocationManager()
    
    var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
}

// MARK: - Lifecycle
extension MapViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

        // 1
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
  }
  
//  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//    guard
//      let navigationController = segue.destination as? UINavigationController,
//      let controller = navigationController.topViewController as? TypesTableViewController
//      else {
//        return
//    }
//    controller.selectedTypes = searchedTypes
//    controller.delegate = self
//  }
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

