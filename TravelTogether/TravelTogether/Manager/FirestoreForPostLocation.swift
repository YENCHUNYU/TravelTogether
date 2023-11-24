//
//  FirestoreForPostLocation.swift
//  TravelTogether
//
//  Created by User on 2023/11/23.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForPostLocationDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location)
}

class FirestoreManagerForPostLocation {
    
    var delegate: FirestoreManagerForPostLocationDelegate?
    
    func addLocationToTravelPlan(planId: String, location: Location, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("TravelPlan").document(planId)

        travelPlanRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(error)
                return
            }

            var updatedData: [String: Any] = [:]
            if let existingData = document?.data() {
                if var daysData = existingData["days"] as? [[String: Any]], !daysData.isEmpty {
                    if var locations = daysData[0]["locations"] as? [[String: Any]] {
                        locations.append([
                            "name": location.name,
                            "photo": location.photo,
                            "address": location.address
                        ])
                        daysData[0]["locations"] = locations
                        updatedData["days"] = daysData
                    }
                } else {
                    updatedData = [
                        "days": [
                            [
                                "locations": [
                                    [
                                        "name": location.name,
                                        "photo": location.photo,
                                        "address": location.address
                                    ]
                                ]
                            ]
                        ]
                    ]
                }
                travelPlanRef.setData(updatedData, merge: true) { error in
                    if let error = error {
                        print("Error setting document: \(error)")
                        completion(error)
                    } else {
                        self.delegate?.manager(self, didPost: location)
                        completion(nil)
                    }
                }
            }
        }
    }
}
