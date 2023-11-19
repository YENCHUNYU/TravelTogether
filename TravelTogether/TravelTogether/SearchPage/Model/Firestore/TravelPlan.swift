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
    // Add other properties as needed

    // Additional properties for Firestore
    var dictionary: [String: Any] {
        return [
            "planName": planName,
            "destination": destination,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            // Add other properties as needed
        ]
    }
}
