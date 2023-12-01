//
//  Memory.swift
//  TravelTogether
//
//  Created by User on 2023/12/1.
//

import UIKit
import FirebaseFirestore

struct Memory {
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

struct MemoryLocation {
    var name: String
    var photo: String
    var address: String
    var user: String?
    var memoryPhotos: [String]?
    var article: String?
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "photo": photo,
            "address": address,
            "user": user ?? "",
            "memoryPhotos": memoryPhotos ?? "",
            "article": article ?? ""
        ]
    }
}

