//
//  FirestorePostLike.swift
//  TravelTogether
//
//  Created by User on 2023/12/10.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManagerFavorite {
    
    func postMemoryToFavorite(memory: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let memoryRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("FavoriteMemory")
        let memoryDay = memory.days
        var dayDictionary: [[String: Any]] = []
        
        for day in memoryDay {
            var updatedDay = day.dictionary
            var locationDic: [[String: Any]] = []
            for location in day.locations {
                let updatedLocation = location.dictionary
                locationDic.append(updatedLocation)
            }
            
            updatedDay["locations"] = locationDic
            dayDictionary.append(updatedDay)
        }
        var memoryData = memory.dictionary
        memoryData["days"] = dayDictionary
        print("memoryData\(memoryData)")
        memoryRef.addDocument(data: memoryData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("memoryData\(memoryData)")
                completion(nil)
            }
        }
    }
    
    func fetchAllMemories(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        
        let memoriesRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("FavoriteMemory")
//        let orderedQuery = memoriesRef.order(by: "startDate", descending: false)
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
                
                completion(memories, nil)
            }
        }
    }
    
    func postPlanToFavorite(memory: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let memoryRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("FavoritePlan")
        let memoryDay = memory.days
        var dayDictionary: [[String: Any]] = []
        
        for day in memoryDay {
            var updatedDay = day.dictionary
            var locationDic: [[String: Any]] = []
            for location in day.locations {
                let updatedLocation = location.dictionary
                locationDic.append(updatedLocation)
            }
            
            updatedDay["locations"] = locationDic
            dayDictionary.append(updatedDay)
        }
        var memoryData = memory.dictionary
        memoryData["days"] = dayDictionary
        print("memoryData\(memoryData)")
        memoryRef.addDocument(data: memoryData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("memoryData\(memoryData)")
                completion(nil)
            }
        }
    }
    
    func fetchAllPlans(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        
        let memoriesRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "").collection("FavoritePlan")
//        let orderedQuery = memoriesRef.order(by: "startDate", descending: false)
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
                
                completion(memories, nil)
            }
        }
    }
}
