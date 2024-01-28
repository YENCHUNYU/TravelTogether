//
//  FirestoreManagerForOne.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

class FirestoreManagerForOne {
    
    func fetchOneTravelPlan(
        dbCollection: String,
        userId: String,
        byId planId: String,
        completion: @escaping (TravelPlan?, Error?) -> Void
    ) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(userId).collection(dbCollection).document(planId)
        
        travelPlanRef.addSnapshotListener { document, error in
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
                    let updatedData = DateUtils.convertTimestampToDate(original: data ?? [:])

                    guard let data = try? JSONSerialization.data(withJSONObject: updatedData) else {
                        completion(nil, nil)
                        return
                    }

                    var travelPlan = try JSONDecoder().decode(TravelPlan.self, from: data)
                    travelPlan.id = document.documentID
                    completion(travelPlan, nil)
                } catch {
                    print("Error decoding JSON: \(error)")
                    completion(nil, error)
                }
            }
        }
    }
}

extension FirestoreManagerForOne {

    func deleteLocationFromTravelPlan(
        travelPlanId: String, dayIndex: Int, location: Location,
        userId: String, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(userId)
        let travelPlanRef = userRef.collection("TravelPlan").document(travelPlanId)
        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for deletion: \(error)")
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
                    locationsArray.removeAll { (locationData) -> Bool in
                        let name = locationData["name"] as? String ?? ""
                        return name == location.name
                    }
                    daysArray[dayIndex]["locations"] = locationsArray
                    travelPlanData["days"] = daysArray
                    travelPlanRef.setData(travelPlanData, merge: true) { error in
                        if let error = error {
                            print("Error updating document after deletion: \(error)")
                            completion(error)
                        } else {
                            print("Document updated successfully after deletion.")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}

extension FirestoreManagerForOne {
    func deleteDayFromTravelPlan(userId: String, travelPlanId: String, 
                                 dayIndex: Int, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(userId)
        let travelPlanRef = userRef.collection("TravelPlan").document(travelPlanId)
        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for deletion: \(error)")
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
                    daysArray.remove(at: dayIndex)
                    travelPlanData["days"] = daysArray
                    travelPlanRef.setData(travelPlanData, merge: true) { error in
                        if let error = error {
                            print("Error updating document after deletion: \(error)")
                            completion(error)
                        } else {
                            print("Document updated successfully after deletion.")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
