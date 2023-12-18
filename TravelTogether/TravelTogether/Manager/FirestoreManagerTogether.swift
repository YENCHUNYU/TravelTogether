
//  FirestoreManagerTogether.swift
//  TravelTogether
//
//  Created by User on 2023/12/18.
//

import UIKit
import FirebaseFirestore

class FirestoreTogether {
    func fetchThroughRef(ref: DocumentReference, completion: @escaping (TravelPlan?, Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = ref

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
                                address: locationData["address"] as? String ?? "",
                                user: locationData["user"] as? String ?? ""
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
                        days: travelDays,
                        user: data?["user"] as? String ?? "",
                        userPhoto: data?["userPhoto"] as? String ?? "",
                        userId: data?["userId"] as? String ?? ""
                    )
                    completion(travelPlan, nil)
                }
            }
        }
    }
    
   //沒用到
    func postFullPlan(plan: TravelPlan, completion: @escaping (String?, Error?) -> Void) {
        let database = Firestore.firestore()
        let planRef = database.collection("TogetherPlan")
        let planDay = plan.days
        var dayDictionary: [[String: Any]] = []
        
        for day in planDay {
            var updatedDay = day.dictionary
            var locationDic: [[String: Any]] = []
            for location in day.locations {
                let updatedLocation = location.dictionary
                locationDic.append(updatedLocation)
            }
            
            updatedDay["locations"] = locationDic
            dayDictionary.append(updatedDay)
        }
        var planData = plan.dictionary
        planData["days"] = dayDictionary
        print("planData\(planData)")
//        planRef.addDocument(data: planData) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//                completion(error)
//            } else {
//                print("planData\(planData)")
////                completion(nil)
                let documentID = planRef.addDocument(data: planData).documentID
//                print("docID\(documentID)")
                completion(documentID, nil)
//            }
//        }
    }
 //沒用到
    func fetchAllTogetherPlans(userId: String, completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        
        let travelPlansRef = database.collection("TogetherPlan").whereField("userIdArray", arrayContains: userId)
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
                        userPhoto: data["userPhoto"] as? String ?? "",
                        userId: data["userId"] as? String ?? ""
                    )
                    
                    travelPlans.append(travelPlan)
                    
                }
                
                completion(travelPlans, nil)
            }
        }
    }
  // 沒用到
    func fetchOneTravelPlan(byId planId: String, completion: @escaping (TravelPlan?, Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("TogetherPlan").document(planId)

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
                                address: locationData["address"] as? String ?? "",
                                user: locationData["user"] as? String ?? ""
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
                        days: travelDays,
                        user: data?["user"] as? String ?? "",
                        userPhoto: data?["userPhoto"] as? String ?? "",
                        userId: data?["userId"] as? String ?? ""
                    )
                    completion(travelPlan, nil)
                }
            }
        }
    }
}
