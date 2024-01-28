//
//  FirestoreManager.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager {

    func fetchTravelPlans(userId: String?, completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let database = Firestore.firestore()
        var travelPlansRef: Query
        
        if let userId = userId {
            travelPlansRef = database.collection("UserInfo").document(userId).collection("TravelPlan")
        } else {
            travelPlansRef = database.collectionGroup("TravelPlan")
        }
        
        travelPlansRef.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                completion(nil, nil)
                return
            }
            
            let travelPlans: [TravelPlan] = documents.compactMap { document in
                let data = document.data()
                do {
                    let updatedData = DateUtils.convertTimestampToDate(original: data)
                    let jsonData = try JSONSerialization.data(withJSONObject: updatedData)
                    var travelPlan = try JSONDecoder().decode(TravelPlan.self, from: jsonData)
                    
                    travelPlan.id = document.documentID
                    return travelPlan
                } catch {
                    print("Error decoding document: \(error)")
                    return nil
                }
            }
            completion(travelPlans, nil)
        }
    }
}

extension FirestoreManager {

    func deleteTravelPlan(withID planID: String, completion: @escaping (Error?) -> Void) {
           let database = Firestore.firestore()
           let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
           let travelPlanRef = userRef.collection("TravelPlan").document(planID)

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
