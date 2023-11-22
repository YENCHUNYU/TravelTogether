//
//  TravelPlan.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore

struct TravelPlan {
    let id: String?
    let planName: String
    let destination: String
    let startDate: Date
    let endDate: Date
    var allSpots: [String]?
    var spotsPerDay: [[String]]?
    // Add other properties as needed

    // Additional properties for Firestore
    var dictionary: [String: Any] {
        return [
            "planName": planName,
            "destination": destination,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "allSpots": allSpots ?? []
        ]
    }
}

struct TravelPlan2 {
    var id: String
    var planName: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var days: [TravelDay]
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "planName": planName,
            "destination": destination,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "days": days
        ]
    }
}

struct TravelDay {
    var date: Date
    var locations: [Location]
    
    var dictionary: [String: Any] {
        return [
            "date": date,
            "locations": locations
        ]
    }
}

struct Location {
    var name: String
    var photo: String
    var address: String
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "photo": photo,
            "address": address
        ]
    }
}
