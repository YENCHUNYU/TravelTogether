//
//  FirestorageUploadPhotos.swift
//  TravelTogether
//
//  Created by User on 2023/11/23.
//

import UIKit
import FirebaseStorage

class FirebaseStorageManagerUploadPhotos {
  
    func uploadPhotoToFirebaseStorage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        let filename = "\(UUID().uuidString).jpg"
        let storageRef = Storage.storage().reference().child("photos").child(filename)
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            storageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    completion(.failure(error))
                } else {
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            completion(.failure(error))
                        } else if let downloadURL = url {
                            completion(.success(downloadURL))
                        }
                    }
                }
            }
        }
    }
}
