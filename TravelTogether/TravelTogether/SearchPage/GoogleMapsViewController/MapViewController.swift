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
}

// MARK: - Lifecycle
extension MapViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
        locationManager.delegate = self

        if CLLocationManager.locationServicesEnabled() {
          locationManager.requestLocation()
          mapView.isMyLocationEnabled = true
          mapView.settings.myLocationButton = true
        } else {
          locationManager.requestWhenInUseAuthorization()
        }
      searchVC.searchResultsUpdater = self
      navigationItem.searchController = searchVC
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

    mapView.camera = GMSCameraPosition(
      target: location.coordinate,
      zoom: 15,
      bearing: 0,
      viewingAngle: 0)
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
        //  remove keyboard
        searchVC.searchBar.resignFirstResponder()
        // remove
        mapView.clear()
        //add

        let marker = GMSMarker()
               marker.position = coordinates
//               marker.title = "Your Marker Title"
//               marker.snippet = "Your Marker Snippet"
               marker.map = mapView

               let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 15.0)
               mapView.animate(to: camera)
    }
}
