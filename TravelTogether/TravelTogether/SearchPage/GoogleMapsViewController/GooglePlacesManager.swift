//
//  GooglePlacesManager.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GooglePlaces

class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    enum PlacesError: Error {
        case failedToFind
    }
    
//    public func setUp() {
//        GMSPlacesClient.provideAPIKey("AIzaSyB_yT1p20Y-EsVCmomSsdCVgXF1v2yKxZI")
//    }
    
    public func findPlaces(
        query: String,
        completion: @escaping(Result<[Place], Error>) -> Void
    ){
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: nil) {
                (results, error) in
                guard let results = results, error == nil else {
                    completion(.failure(PlacesError.failedToFind))
                    return
                }
                
                let places: [Place] = results.compactMap({Place(
                    name: $0.attributedFullText.string,
                    identifier: $0.placeID)
                })
                completion(.success(places))
            }
    }
}

struct Place {
    let name: String
    let identifier: String
}
