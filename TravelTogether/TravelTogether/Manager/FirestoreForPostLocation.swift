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
    
    func addLocationToTravelPlan(planId: String, location: Location, day: Int, completion: @escaping (Error?) -> Void) {
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
                        self.delegate?.manager(self, didPost: location)
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
        let travelPlanRef = database.collection("TravelPlan").document(travelPlanId)

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

                    guard var locationsArray = daysArray[dayIndex]["locations"] as? [[String: Any]] else {
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
    
    func clearLocationsUser(
        travelPlanId: String,
        completion: @escaping (Error?) -> Void
    ) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("TravelPlan").document(travelPlanId)

        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for updating locations order: \(error)")
                completion(error)
            } else {
                do {
                    guard var travelPlanData = document?.data() else {
                        print("No document data found.")
                        completion(nil)
                        return
                    }

                    guard var daysArray = travelPlanData["days"] as? [[String: Any]] else {
                        print("No 'days' array found.")
                        completion(nil)
                        return
                    }

                    var updatedDays: [[String: Any]] = []
                    for var day in daysArray {
                        var updatedLocations: [[String: Any]] = [] // Move inside the day loop
                        if var locationsArray = day["locations"] as? [[String: Any]] {
                            for var location in locationsArray {
                                // Clear the user data in each location
                                location["user"] = "" // or set it to an appropriate value
                                updatedLocations.append(location)
                            }
                            // Update the locations array in the day
                            day["locations"] = updatedLocations
                        }
                        updatedDays.append(day)
                    }

                    // Update the document in Firestore
                    travelPlanData["days"] = updatedDays
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
