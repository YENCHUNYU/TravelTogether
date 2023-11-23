//
//  FirestoreForPostLocation.swift
//  TravelTogether
//
//  Created by User on 2023/11/23.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForPostLocationDelegate {
    func manager(_ manager: FirestoreManagerForPostLocation, didPost firestoreData: Location)
}

class FirestoreManagerForPostLocation {
    
    var delegate: FirestoreManagerForPostLocationDelegate?
    
    func addLocationToTravelPlan(planId: String, location: Location, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        // Reference to the "TravelPlan" document
        let travelPlanRef = db.collection("TravelPlan").document(planId)

        // Fetch the existing data
        travelPlanRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(error)
                return
            }

            // Update the existing data with the new location
            var updatedData: [String: Any] = [:]
            if let existingData = document?.data() {
                if var daysData = existingData["days"] as? [[String: Any]], !daysData.isEmpty {
                    if var locations = daysData[0]["locations"] as? [[String: Any]] {
                        // Add the new location
                        locations.append([
                            "name": location.name,
                            "photo": location.photo,
                            "address": location.address
                        ])
                        // Update the nested dictionaries
                        daysData[0]["locations"] = locations
                        updatedData["days"] = daysData
                    }
                } else {
                    // If the document doesn't exist or has no days, create a new one with the location
                    updatedData = [
                        "days": [
                            [
                               // "date": Date(), // You might want to set an appropriate date here
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

                // Set the updated data back to Firestore
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
