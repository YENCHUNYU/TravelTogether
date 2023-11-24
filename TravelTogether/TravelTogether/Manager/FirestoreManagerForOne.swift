//
//  FirestoreManagerForOne.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForeOneDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan)
}

class FirestoreManagerForOne {
    
    var delegate: FirestoreManagerForeOneDelegate?
    
    func fetchOneTravelPlan(byId planId: String, completion: @escaping (TravelPlan?, Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("TravelPlan").document(planId)

        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, error)
            } else {
                do {
                    guard let document = document, document.exists else {
                        completion(nil, nil)
                        return
                    }

                    let data = document.data()
                    let startDate = (data?["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data?["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    guard let daysArray = data?["days"] as? [[String: Any]] else {
                        return
                    }

                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                    
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            return
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
                        planName: data?["planName"] as? String ?? "",
                        destination: data?["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
                    )
                    completion(travelPlan, nil)
                    self.delegate?.manager(self, didGet: travelPlan)
                }
            }
        }
    }
}
