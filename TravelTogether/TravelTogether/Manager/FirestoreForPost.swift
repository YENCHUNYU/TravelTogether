//
//  FirestoreForPost.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForPostDelegate {
    func manager(_ manager: FirestoreManagerForPost, didPost firestoreData: TravelPlan2)
}

class FirestoreManagerForPost {
    var delegate: FirestoreManagerForPostDelegate?
    
    func postTravelPlan(travelPlan: TravelPlan2, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        var ref: DocumentReference? = nil
        let travelPlanData = travelPlan.dictionary
        
        ref = db.collection("TravelPlan").addDocument(data: travelPlanData) { error in
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
