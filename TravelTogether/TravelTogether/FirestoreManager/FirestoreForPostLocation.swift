//
//  FirestoreForPostLocation.swift
//  TravelTogether
//
//  Created by User on 2023/11/23.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManagerForPostLocation {
  
    func addLocationToTravelPlan(userId: String, planId: String,
                                 location: Location, day: Int, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(userId).collection("TravelPlan").document(planId)

        travelPlanRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(error)
                return
            }

            var updatedData: [String: Any] = [:]
            if let existingData = document?.data() {
                if var daysData = existingData["days"] as? [[String: Any]], !daysData.isEmpty {
                    if var locations = daysData[day]["locations"] as? [[String: Any]] {
                        locations.append([
                            "name": location.name,
                            "photo": location.photo,
                            "address": location.address
                        ])
                        daysData[day]["locations"] = locations
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
                        completion(nil)
                    }
                }
            }
        }
    }
}

extension FirestoreManagerForPostLocation {
    func updateLocationsOrder(travelPlanId: String, 
                              dayIndex: Int,
                              newLocationsOrder: [Location],
                              completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let travelPlanRef = userRef.collection("TravelPlan").document(travelPlanId)

        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for updating locations order: \(error)")
                completion(error)
            } else {
                do {
                    guard var travelPlanData = document?.data() else {
                        completion(nil)
                        return
                    }

                    guard var daysArray = travelPlanData["days"] as? [[String: Any]] else {
                        completion(nil)
                        return
                    }

                    guard daysArray[dayIndex]["locations"] is [[String: Any]] else {
                        completion(nil)
                        return
                    }

                    // Update the order of locations based on newLocationsOrder
                    var updatedLocations: [[String: Any]] = []
                    for location in newLocationsOrder {
                        let locationData = location.dictionary
                        updatedLocations.append(locationData)
                    }

                    // Update the locations array in the days array
                    daysArray[dayIndex]["locations"] = updatedLocations
                    travelPlanData["days"] = daysArray

                    // Update the document in Firestore
                    travelPlanRef.setData(travelPlanData, merge: true) { error in
                        if let error = error {
                            print("Error updating document after changing locations order: \(error)")
                            completion(error)
                        } else {
                            print("Document updated successfully after changing locations order.")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
