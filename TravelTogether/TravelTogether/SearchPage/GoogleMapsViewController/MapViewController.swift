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
}

// MARK: - Lifecycle
extension MapViewController {
    
  override func viewDidLoad() {
    super.viewDidLoad()
        locationManager.delegate = self

//        if CLLocationManager.locationServicesEnabled() {
//          locationManager.requestLocation()
//          mapView.isMyLocationEnabled = true
//          mapView.settings.myLocationButton = true
//        } else {
          locationManager.requestWhenInUseAuthorization()
//        }
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
        //  remove keyboard
        searchVC.searchBar.resignFirstResponder()
        // remove
        mapView.clear()
        // add

        let marker = GMSMarker()
               marker.position = coordinates
//               marker.title = "Your Marker Title"
//               marker.snippet = "Your Marker Snippet"
               marker.map = mapView

               let camera = GMSCameraPosition.camera(withTarget: coordinates, zoom: 15.0)
               mapView.animate(to: camera)
//        if let mapInfoViewController = storyboard?.instantiateViewController(withIdentifier: "MapInfoViewController") as? MapInfoViewController {
//
//                    present(mapInfoViewController, animated: true, completion: nil)
//                }
        if let mapInfoViewController = storyboard?.instantiateViewController(withIdentifier: "MapInfoViewController") as? MapInfoViewController {
                    // Customize mapInfoViewController as needed
            mapInfoViewController.modalPresentationStyle = .custom
                    mapInfoViewController.transitioningDelegate = self
            mapInfoViewController.places = placesData[indexPath.row]
            
                    // Present the MapInfoViewController
                    present(mapInfoViewController, animated: true, completion: nil)
                }
    }
}

extension MapViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return MapInfoPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

class MapInfoPresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return CGRect.zero }

        // Set the height to half of the screen
        let height: CGFloat = containerView.bounds.height / 2.0
        return CGRect(x: 0, y: containerView.bounds.height - height, width: containerView.bounds.width, height: height)
    }
}
