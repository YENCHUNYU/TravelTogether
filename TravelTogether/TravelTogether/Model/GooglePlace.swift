//
//  Model.swift
//  TravelTogether
//
//  Created by User on 2023/11/16.
//

import UIKit
import CoreLocation

struct GooglePlace: Codable {
  let name: String
  let address: String
  let types: [String]
  
  private let geometry: Gemoetry
  var coordinate: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: geometry.location.lat, longitude: geometry.location.lng)
  }

  enum CodingKeys: String, CodingKey {
    case name
    case address = "vicinity"
    case types
    case geometry
  }
}

extension GooglePlace {
  struct Response: Codable {
    let results: [GooglePlace]
    let errorMessage: String?
  }
  
  private struct Gemoetry: Codable {
    let location: Coordinate
  }
  
  private struct Coordinate: Codable {
    let lat: CLLocationDegrees
    let lng: CLLocationDegrees
  }
}

struct Place {
    let name: String
    let identifier: String
    let address: String
}
