//
//  TravelPlan.swift
//  TravelTogether
//
//  Created by User on 2023/11/17.
//

import UIKit
import FirebaseFirestore

struct TravelPlan: Codable {
    var id: String
    var planName: String
    var destination: String
    var startDate: Date
    var endDate: Date
    var days: [TravelDay]
    var coverPhoto: String?
    var user: String?
    var userPhoto: String?
    var userId: String?
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "planName": planName,
            "destination": destination,
            "startDate": Timestamp(date: startDate),
            "endDate": Timestamp(date: endDate),
            "days": days,
            "coverPhoto": coverPhoto ?? "",
            "user": user ?? "",
            "userPhoto": userPhoto ?? "",
            "userId": userId ?? ""
        ]
    }
}

struct TravelDay: Codable {
    var locations: [Location]
    
    var dictionary: [String: Any] {
        return [
            "locations": locations
        ]
    }
}

struct Location: Codable {
    var name: String
    var photo: String
    var address: String
    var memoryPhotos: [String]?
    var article: String?
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "photo": photo,
            "address": address,
            "memoryPhotos": memoryPhotos ?? [],
            "article": article ?? ""
        ]
    }
}
