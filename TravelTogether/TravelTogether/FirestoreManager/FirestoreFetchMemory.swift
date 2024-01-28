//
//  FirestoreFetchMemory.swift
//  TravelTogether
//
//  Created by User on 2023/12/4.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManagerFetchMemory {
  // 用戶個人
    func fetchMemories(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        let userDoc = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoriesRef = userDoc.collection("Memory")
        let orderedQuery = memoriesRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var memories: [TravelPlan] = []
                
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
                                address: locationData["address"] as? String ?? "",
                                memoryPhotos: locationData["article"] as? [String] ?? [],
                                article: locationData["article"] as? String ?? ""
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
                    memories.append(travelPlan)
                }
                
                completion(memories, nil)
            }
        }
    }
    // 用戶個人
    func fetchMemoryDrafts(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        let userInfoRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoriesRef = userInfoRef.collection("MemoryDraft")
        let orderedQuery = memoriesRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var memories: [TravelPlan] = []
                
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
                                address: locationData["address"] as? String ?? "",
                                memoryPhotos: locationData["article"] as? [String] ?? [],
                                article: locationData["article"] as? String ?? ""
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
                    memories.append(travelPlan)
                }
                
                completion(memories, nil)
            }
        }
    }
    
// 搜尋頁
    func fetchAllMemories(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()    
        let memoriesRef = database.collectionGroup("Memory")
        memoriesRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var memories: [TravelPlan] = []
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
                                address: locationData["address"] as? String ?? "",
                                memoryPhotos: locationData["article"] as? [String] ?? [],
                                article: locationData["article"] as? String ?? ""
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
                        coverPhoto: data["coverPhoto"] as? String ?? "",
                        user: data["user"] as? String ?? "",
                        userPhoto: data["userPhoto"] as? String ?? "",
                        userId: data["userId"] as? String ?? ""
                    )
                    memories.append(travelPlan)
                }
                completion(memories, nil)  } }
    }
    
    func deleteMemory(dbcollection: String, withID memoryID: String, completion: @escaping (Error?) -> Void) {
           let database = Firestore.firestore()
           let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
           let memoryRef = userRef.collection(dbcollection).document(memoryID)

        memoryRef.delete { error in
               if let error = error {
                   print("Error deleting memory document: \(error)")
                   completion(error)
               } else {
                   print("Memory document deleted successfully.")
                   completion(nil)
               }
           }
       }
   // 用戶個人
    func fetchOneMemory(dbcollection: String,
                        userId: String,
                        byId memoryId: String,
                        completion: @escaping (TravelPlan?, Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(userId)
        let memoryRef = userRef.collection(dbcollection).document(memoryId)

        memoryRef.addSnapshotListener { document, error in
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
                                memoryPhotos: locationData["memoryPhotos"] as? [String] ?? [], 
                                article: locationData["article"] as? String ?? ""
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
                        coverPhoto: data?["coverPhoto"] as? String ?? "",
                        user: data?["user"] as? String ?? "",
                        userPhoto: data?["userPhoto"] as? String ?? "",
                        userId: data?["userId"] as? String ?? ""
                    )
                    completion(travelPlan, nil)
                } } }
    }
}
