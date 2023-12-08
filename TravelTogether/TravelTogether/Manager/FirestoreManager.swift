//
//  FirestoreManager.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

protocol FirestoreManagerDelegate: AnyObject {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan])
}

class FirestoreManager {
    
    var delegate: FirestoreManagerDelegate?

    func fetchTravelPlans(userId: String, completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        
        let travelPlansRef = database.collection("UserInfo").document(userId).collection("TravelPlan")
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
                        days: travelDays
                    )
                    
                    travelPlans.append(travelPlan)
                    self.delegate?.manager(self, didGet: travelPlans)
                    
                }
                
                completion(travelPlans, nil)
            }
        }
    }
    // 新
    func fetchAllTravelPlans(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        
        let travelPlansRef = database.collectionGroup("TravelPlan")
//        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        travelPlansRef.getDocuments { (querySnapshot, error) in
            
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
                        user: data["user"] as? String ?? "",
                        userPhoto: data["userPhoto"] as? String ?? ""
                    )
                    
                    travelPlans.append(travelPlan)
                    self.delegate?.manager(self, didGet: travelPlans)
                    
                }
                
                completion(travelPlans, nil)
            }
        }
    }
}

extension FirestoreManager {

    func deleteTravelPlan(withID planID: String, completion: @escaping (Error?) -> Void) {
           let database = Firestore.firestore()
           let travelPlanRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("TravelPlan").document(planID)

           travelPlanRef.delete { error in
               if let error = error {
                   print("Error deleting travel plan document: \(error)")
                   completion(error)
               } else {
                   print("Travel plan document deleted successfully.")
                   completion(nil)
               }
           }
       }
}
