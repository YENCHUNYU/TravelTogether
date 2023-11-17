//
//  GooglePlacesManager.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    
    private let client = GMSPlacesClient.shared()
    
    private init() {}
    
    enum PlacesError: Error {
        case failedToFind
        case failedToGetCoordinates
    }

    public func findPlaces(
        query: String,
        completion: @escaping(Result<[Place], Error>) -> Void
    ) {
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
                    name: $0.attributedPrimaryText.string,
                    identifier: $0.placeID,
                    address: $0.attributedFullText.string)
                })
                completion(.success(places))
            }
    }
    
    public func resolveLocation(
        for place: Place,
        completion: @escaping(Result<CLLocationCoordinate2D, Error>) -> Void
    ) {
        client.fetchPlace(
            fromPlaceID: place.identifier,
            placeFields: .coordinate,
            sessionToken: nil
        ) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                completion(.failure(PlacesError.failedToGetCoordinates))
                return
            }
            let coordinate = CLLocationCoordinate2D(
                latitude: googlePlace.coordinate.latitude,
                longitude: googlePlace.coordinate.longitude)
            completion(.success(coordinate))
        }
    }

    
} // class

struct Place {
    let name: String
    let identifier: String
    let address: String
    var photoReference: String?
}

struct ListResponse: Codable {
    var results: [ItemResults]
    var status: String
}

struct ItemResults: Codable {
    var name: String        //地標名稱
    var placeId: String    //id （for 抓詳細資料使用）
    var vicinity: String    //地址

   enum CodingKeys: String, CodingKey {
        case name
        case placeId = "place_id"
        case vicinity
    }
}
