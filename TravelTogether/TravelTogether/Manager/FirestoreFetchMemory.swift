//
//  FirestoreFetchMemory.swift
//  TravelTogether
//
//  Created by User on 2023/12/4.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerFetchMemoryDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerFetchMemory, didGet firestoreData: [TravelPlan])
}

class FirestoreManagerFetchMemory {
    
    var delegate: FirestoreManagerFetchMemoryDelegate?

    func fetchMemories(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        
        let travelPlansRef = database.collection("Memory")
        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var travelPlans: [TravelPlan] = []
                
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
                    
                    guard let daysArray = data["days"] as? [[String: Any]] else {
                        continue
                    }
                   
                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            continue
                        }
                
                        var locations: [Location] = []
                        for locationData in locationsArray {
                            let location = Location(
                                name: locationData["name"] as? String ?? "",
                                photo: locationData["photo"] as? String ?? "",
                                address: locationData["address"] as? String ?? ""
                            )
                            locations.append(location)
                        }
                        
                        let travelDay = TravelDay(locations: locations)
                        travelDays.append(travelDay)
                    }
                    
                    let travelPlan = TravelPlan(
                        id: document.documentID,
                        planName: data["planName"] as? String ?? "",
                        destination: data["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays,
                        coverPhoto: data["coverPhoto"] as? String ?? ""
                    )
                    travelPlans.append(travelPlan)
                }
                
                completion(travelPlans, nil)
            }
        }
    }
}
