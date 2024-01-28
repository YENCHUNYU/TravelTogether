//
//  FirestoreForPost.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManagerForPostPlan {
// 空的plan
    func postTravelPlan(travelPlan: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()  
       let ref = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        var travelPlanData = travelPlan.dictionary
        travelPlanData["days"] = [["locations": []]]
        print("travelPlanData\(travelPlanData)")
        
        ref.collection("TravelPlan").addDocument(data: travelPlanData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("Document added with ID")
                completion(nil)
            }
        }
    }
 // 滿的plan
    func postFullPlan(plan: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        let planRef = userRef.collection("TravelPlan")
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
        planRef.addDocument(data: planData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("planData\(planData)")
                completion(nil)
            }
        }
    }
}
