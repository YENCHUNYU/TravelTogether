//  FirestoreManagerTogether.swift
//  TravelTogether
//
//  Created by User on 2023/12/18.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreTogether {
    
    func postFullPlan(planRef: DocumentReference, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")

        userRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for updating locations order: \(error)")
                completion(error)
            } else {
                if let data = document?.data() {
                    var userInfo = UserInfo(
                        email: data["email"] as? String ?? "",
                        name: data["name"] as? String ?? "",
                        id: data["id"] as? String ?? "",
                        photo: data["photo"] as? String ?? "",
                        ref: data["ref"] as? [DocumentReference] ?? []
                    )

                    userInfo.ref?.append(planRef)
                    completion(nil)

                    userRef.setData(userInfo.toDictionary(), merge: true)
                } else {
                    print("Document does not exist for user with ID")
                    completion(error)
                }
            }
        }
    }
}
