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
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoryRef = userRef.collection("FavoriteMemory")
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
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoriesRef = userRef.collection("FavoriteMemory")
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
                        continue   }
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
                        travelDays.append(travelDay) }
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
                    memories.append(travelPlan)  }
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
        let userCo = database.collection("UserInfo")
        let userRef = userCo.document(Auth.auth().currentUser?.uid ?? "")
        let memoriesRef = userRef.collection("FavoritePlan")
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
    
    func deleteFavorite(dbcollection: String, withID memoryID: String, completion: @escaping (Error?) -> Void) {
           let database = Firestore.firestore()
           let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
           let favoriteRef = userRef.collection(dbcollection).document(memoryID)

        favoriteRef.delete { error in
               if let error = error {
                   print("Error deleting favorite document: \(error)")
                   completion(error)
               } else {
                   print("Favorite document deleted successfully.")
                   completion(nil)
               }
           }
       }
}
