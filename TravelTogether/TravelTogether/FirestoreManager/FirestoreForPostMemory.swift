//
//  FirestoreForPostMemory.swift
//  TravelTogether
//
//  Created by User on 2023/12/1.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManagerMemoryPost {
    
    func postMemory(memory: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoryRef = userRef.collection("Memory")
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
    
    func postMemoryDraft(memory: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoryRef = userRef.collection("MemoryDraft")
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
    
    func updateMemory(dbcollection: String, memory: TravelPlan,
                      memoryId: String, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let memoryRef = userRef.collection(dbcollection).document(memoryId)
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
        memoryRef.setData(memoryData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("memoryData\(memoryData)")
                completion(nil)
            }
        }
    }
}
