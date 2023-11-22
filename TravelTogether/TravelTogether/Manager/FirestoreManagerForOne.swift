//
//  FirestoreManagerForOne.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForeOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan2)
}

class FirestoreManagerForOne {
    
    var delegate: FirestoreManagerForeOneDelegate?
    
    func fetchOneTravelPlan(byId planId: String, completion: @escaping (TravelPlan2?, Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanRef = db.collection("TravelPlan").document(planId)

        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, error)
            } else {
                do {
                    guard let document = document, document.exists else {
                        completion(nil, nil) // Document doesn't exist
                        return
                    }

                    let data = document.data()

                    // Convert Firestore Timestamp to Date
                    let startDate = (data?["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data?["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    // Retrieve the "days" array
                    guard let daysArray = data?["days"] as? [[String: Any]] else {
                        completion(nil, NSError(domain: "YourAppDomain", code: 1, userInfo: ["message": "Missing 'days' array"]))
                        return
                    }

                    // Convert each day data to a TravelDay object
                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                        let dayDate = (dayData["date"] as? Timestamp)?.dateValue() ?? Date()

                        // Retrieve the "locations" array for each day
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            completion(nil, NSError(domain: "YourAppDomain", code: 2, userInfo: ["message": "Missing 'locations' array"]))
                            return
                        }

                        // Convert each location data to a Location object
                        var locations: [Location] = []
                        for locationData in locationsArray {
                            let location = Location(
                                name: locationData["name"] as? String ?? "",
                                photo: locationData["photo"] as? String ?? "",
                                address: locationData["address"] as? String ?? ""
                            )
                            locations.append(location)
                        }

                        // Create a TravelDay object
                        let travelDay = TravelDay(date: dayDate, locations: locations)
                        travelDays.append(travelDay)
                    }
                    // Create a TravelPlan2 object
                    let travelPlan = TravelPlan2(
                        id: document.documentID,
                        planName: data?["planName"] as? String ?? "",
                        destination: data?["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
                    )
                    completion(travelPlan, nil)
                    self.delegate?.manager(self, didGet: travelPlan)
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
}
