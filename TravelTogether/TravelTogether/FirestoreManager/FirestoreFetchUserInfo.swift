//
//  FirestoreUserInfo.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class FirestoreManagerFetchUser {
    
    func fetchUserInfo(completion: @escaping (UserInfo?, Error?) -> Void) {
        let database = Firestore.firestore()

        let userRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")

        userRef.getDocument { (document, error) in
            if let error = error {
                print("Error getting User document: \(error)")
                completion(nil, error)
            } else {
                guard let document = document, document.exists else {
                    print("User Document does not exist")
                    completion(nil, nil)
                    return
                }
                if let data = document.data(),
                   let email = data["email"] as? String,
                   let name = data["name"] as? String,
                let id = data["id"] as? String,
                let photo = data["photo"] as? String {
                    let userInfo = UserInfo(email: email, name: name, id: id, photo: photo)
                    completion(userInfo, nil)
                } else {
                    print("Error parsing user document data")
                    completion(nil, nil)
                }
            }
        }
    }
}
