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
    func manager(_ manager: FirestoreManagerMemoryPost, didPost firestoreData: TravelPlan)
}

class FirestoreManagerMemoryPost {
    var delegate: FirestoreManagerMemoryPostDelegate?
    
    func postTravelPlan(travelPlan: TravelPlan, completion: @escaping (Error?) -> Void) {
//        let database = Firestore.firestore()
//        
//       var ref: DocumentReference?
//               
//        var travelPlanData = travelPlan.dictionary
//        travelPlanData["days"] = [["locations": []]]
//        print("travelPlanData\(travelPlanData)")
//        
//        ref = database.collection("TravelPlan").addDocument(data: travelPlanData) { error in
//            if let error = error {
//                print("Error adding document: \(error)")
//                completion(error)
//            } else {
//                print("Document added with ID: \(ref!.documentID)")
//                self.delegate?.manager(self, didPost: travelPlan)
//                completion(nil)
//            }
//        }
        
//        let database = Firestore.firestore()
//        let memoryRef = database.collection("Memory")
//        let memoryDay = travelPlan.days
//        var dayDictionary: [[String: Any]] = []
//        var locationDic: [[String: Any]] = []
//        for day in memoryDay {
//            var updatedDay = day.dictionary
//            for location in day.locations {
//                let updatedLocation = location.dictionary
//                locationDic.append(updatedLocation)
//            }
//            
//            updatedDay["locations"] = locationDic
//            dayDictionary.append(updatedDay)
//        }
//        var memoryData = travelPlan.dictionary
//        memoryData["days"] = dayDictionary
//        print("memoryData\(memoryData)")
//        memoryRef.addDocument(data: memoryData) { error in
//                        if let error = error {
//                            print("Error adding document: \(error)")
//                            completion(error)
//                        } else {
//                            print("memoryData\(memoryData)")
////                            self.delegate?.manager(self, didPost: travelPlan)
//                            completion(nil)
//                        }
//                    }
    }
}

extension FirestoreManagerMemoryPost {
    
    func postMemory(memory: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let memoryRef = database.collection("Memory")
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
}
