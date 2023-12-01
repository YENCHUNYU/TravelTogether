//
//  FirestoreForPostMemory.swift
//  TravelTogether
//
//  Created by User on 2023/12/1.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerMemoryPostDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerMemoryPost, didPost firestoreData: Memory)
}

class FirestoreManagerMemoryPost {
    
    var delegate: FirestoreManagerMemoryPostDelegate?
    
    func postMemory(memory: Memory, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let memoryRef = database.collection("Memory")
        var memoryDay = memory.days
        var dayDictionary: [[String: Any]] = []
        var locationDic: [[String: Any]] = []
        for day in memoryDay {
            var updatedDay = day.dictionary
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
        memoryRef.addDocument(data: memoryData)
    }
}
