//
//  FirestoreUserInfo.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//


import UIKit
import FirebaseFirestore

protocol FirestoreManagerFetchUserDelegate: AnyObject {
    func manager(_ manager: FirestoreManager, didGet firestoreData: UserInfo)
}

class FirestoreManagerFetchUser {

    weak var delegate: FirestoreManagerFetchUserDelegate?

    func fetchUserInfo(id: String, completion: @escaping (UserInfo?, Error?) -> Void) {
        let database = Firestore.firestore()

        let userRef = database.collection("UserInfo").document(id)

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
                   let name = data["name"] as? String {
                    let userInfo = UserInfo(email: email, name: name)
                    completion(userInfo, nil)
                } else {
                    print("Error parsing user document data")
                    completion(nil, nil)
                }
            }
        }
    }
}



