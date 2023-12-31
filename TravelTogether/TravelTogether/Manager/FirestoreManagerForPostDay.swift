//
//  FirestoreManagerForPostDay.swift
//  TravelTogether
//
//  Created by User on 2023/11/25.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol FirestoreManagerForPostDayDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerForPostDay)
}

class FirestoreManagerForPostDay {
    
    var delegate: FirestoreManagerForPostDayDelegate?
    
    func addDayToTravelPlan(planId: String, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("TravelPlan").document(planId)
        
        travelPlanRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(error)
                return
            }
            
            var updatedData: [String: Any] = [:]
            if let existingData = document?.data() {
                if var daysData = existingData["days"] as? [[String: Any]], !daysData.isEmpty {
                    
                    daysData.append(["locations": []] as? [String: [Location]] ?? ["locations": []])
                    updatedData["days"] = daysData
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
    
    func postNewDaysArray(planId: String, newDaysArray: [TravelDay], completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("TravelPlan").document(planId)
        
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

                    var updatedDays: [[String: Any]] = []

                    for day in newDaysArray {
                        var dayData = day.dictionary
                        // 將 TravelDay 中的 locations 轉換為字典形式
                        let updatedLocations: [[String: Any]] = day.locations.map { $0.dictionary }
                        dayData["locations"] = updatedLocations
                        updatedDays.append(dayData)
                    }

                    travelPlanData["days"] = updatedDays

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
