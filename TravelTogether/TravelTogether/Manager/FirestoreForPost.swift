//
//  FirestoreForPost.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForPostDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerForPost, didPost firestoreData: TravelPlan)
}

class FirestoreManagerForPost {
    var delegate: FirestoreManagerForPostDelegate?
    
    func postTravelPlan(travelPlan: TravelPlan, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        
       var ref: DocumentReference?
               
               var travelPlanData = travelPlan.dictionary
        travelPlanData["days"] = [["locations": []]]
        print("travelPlanData\(travelPlanData)")
        
        ref = database.collection("TravelPlan").addDocument(data: travelPlanData) { error in
            if let error = error {
                print("Error adding document: \(error)")
                completion(error)
            } else {
                print("Document added with ID: \(ref!.documentID)")
                self.delegate?.manager(self, didPost: travelPlan)
                completion(nil)
            }
        }
    }
}
