
//  FirestoreManagerTogether.swift
//  TravelTogether
//
//  Created by User on 2023/12/18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

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
    
    func postFullPlan(planRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")

        userRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for updating locations order: \(error)")
                completion(error)
            } else {
                if let data = document?.data() {
                    var userInfo = UserInfo(
                        email: data["email"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        id: data["id"] as? String ?? "",
                        photo: data["photo"] as? String ?? "",
                        ref: data["ref"] as? [DocumentReference] ?? []
                    )

                    userInfo.ref?.append(planRef)
                    completion(nil)

                    userRef.setData(userInfo.toDictionary(), merge: true)
                } else {
                    print("Document does not exist for user with ID")
                    completion(error)
                }
            }
        }
    }

        
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
