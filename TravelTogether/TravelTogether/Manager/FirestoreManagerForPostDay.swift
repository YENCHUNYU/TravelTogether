//
//  FirestoreManagerForPostDay.swift
//  TravelTogether
//
//  Created by User on 2023/11/25.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForPostDayDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerForPostDay)
}

class FirestoreManagerForPostDay {
    
    var delegate: FirestoreManagerForPostDayDelegate?
    
    func addDayToTravelPlan(planId: String, day: Int, completion: @escaping (Error?) -> Void) {
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
                    
                    daysData.append(["locations": []] as? [String: [Location]] ?? ["locations" : []])
                    if var locations = daysData.last?["locations"] as? [[String: Any]] {
                        locations.append([:])
                        daysData[daysData.count - 1]["locations"] = locations
                        updatedData["days"] = daysData
                    }
                } else {
                    updatedData = [
                        "days": [
                            [
                                "locations": [
                                    [
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
                        self.delegate?.manager(self)
                        completion(nil)
                    }
                }
            }
        }
    }
}
