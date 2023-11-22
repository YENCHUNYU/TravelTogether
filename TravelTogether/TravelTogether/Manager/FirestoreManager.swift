//
//  FirestoreManager.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan2])
}

class FirestoreManager {
    
    var delegate: FirestoreManagerDelegate?
    //抓取所有行程
    func fetchTravelPlans(completion: @escaping ([TravelPlan2]?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        let travelPlansRef = db.collection("TravelPlan")
        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var travelPlans: [TravelPlan2] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // Convert Firestore Timestamp to Date
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    // Retrieve the "days" array
                    guard let daysArray = data["days"] as? [[String: Any]] else {
                        continue // Skip this document if "days" is not an array
                    }
                    
                    // Convert each day data to a TravelDay object
                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                        let dayDate = (dayData["date"] as? Timestamp)?.dateValue() ?? Date()
                        
                        // Retrieve the "locations" array for each day
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            continue // Skip this day if "locations" is not an array
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
                    
                    // Create a TravelPlan object
                    let travelPlan = TravelPlan2(
                        id: document.documentID,
                        planName: data["planName"] as? String ?? "",
                        destination: data["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
                    )
                    
                    travelPlans.append(travelPlan)
                    self.delegate?.manager(self, didGet: travelPlans)
                    
                }
                
                completion(travelPlans, nil)
            }
        }
    }
}
