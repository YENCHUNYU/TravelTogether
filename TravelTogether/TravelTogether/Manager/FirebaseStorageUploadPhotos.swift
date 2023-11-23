//
//  FirestorageUploadPhotos.swift
//  TravelTogether
//
//  Created by User on 2023/11/23.
//

import UIKit
import FirebaseStorage

protocol FirebaseStorageManagerUploadPhotosDelegate: AnyObject {
    func manager(_ manager: FirebaseStorageManagerUploadPhotos)
}

class FirebaseStorageManagerUploadPhotos {
    
    var delegate: FirebaseStorageManagerUploadPhotosDelegate?
    
    func uploadPhotoToFirebaseStorage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        // Create a unique filename or use the Place ID as the filename
        let filename = "\(UUID().uuidString).jpg"
        
        // Reference to the Firebase Storage bucket
        let storageRef = Storage.storage().reference().child("photos").child(filename)
        
        // Convert UIImage to Data
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Upload the file to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    // Handle the error.
                    completion(.failure(error))
                } else {
                    // File uploaded successfully
                    storageRef.downloadURL { (url, error) in
                        if let error = error {
                            // Handle the error.
                            completion(.failure(error))
                        } else if let downloadURL = url {
                            // Return the download URL in the completion block
                            completion(.success(downloadURL))
                        }
                    }
                }
            }
        }
    }
}
