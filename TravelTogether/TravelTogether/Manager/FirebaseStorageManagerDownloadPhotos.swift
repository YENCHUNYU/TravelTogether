//
//  FirebaseStorageManagerDownloadPhotos.swift
//  TravelTogether
//
//  Created by User on 2023/11/23.
//

import UIKit
import FirebaseStorage

protocol FirebaseStorageManagerDownloadPhotosDelegate: AnyObject {
    func manager(_ manager: FirebaseStorageManagerDownloadPhotos)
}

class FirebaseStorageManagerDownloadPhotos {
    
    var delegate: FirebaseStorageManagerDownloadPhotosDelegate?
    
    func downloadPhotoFromFirebaseStorage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: url.absoluteString)
        
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
        storageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading photo from Firebase Storage: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                //  self.tableView.reloadData()
                completion(image)
                
            } else {
                print("Failed to create UIImage from data.")
                completion(nil)
            }
        }
    }
}
