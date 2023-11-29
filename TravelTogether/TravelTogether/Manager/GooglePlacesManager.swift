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
        case failedToFetchMapPhotos
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
            sessionToken: nil) { (results, error) in
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
    
    func fetchMapPhoto(
        for placeId: String,
        completion: @escaping(Result<UIImage, Error>) -> Void
    ) {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.photos.rawValue)))

        client.fetchPlace(fromPlaceID: placeId,
                                 placeFields: fields,
                          sessionToken: nil, callback: { (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                return
            }
            if let place = place {
                if place.photos?.isEmpty == false {
                let photoMetadata: GMSPlacePhotoMetadata = place.photos![0]
                self.client.loadPlacePhoto(photoMetadata, callback: { (photo, error) in
                    if let error = error {
                        completion(.failure(PlacesError.failedToFetchMapPhotos))
                        print("Error loading photo metadata: \(error.localizedDescription)")
                        return
                    } else {
                        completion(.success((photo ?? UIImage(named: "Image_Placeholder")) ?? UIImage()))
                    }
                })
                } 
        }
        })
    }
} // class
