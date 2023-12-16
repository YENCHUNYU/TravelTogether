//
//  EditMemoryTitlePage.swift
//  TravelTogether
//
//  Created by User on 2023/12/2.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class EditMemoryTitleViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var memoryImageView: UIImageView! {
        didSet {
            memoryImageView.layer.cornerRadius = 15
            memoryImageView.contentMode = .scaleAspectFill
            
        }
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.layer.cornerRadius = 15
        }
    }
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            editButton.layer.cornerRadius = 15
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        titleTextField.becomeFirstResponder()
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        titleTextField.resignFirstResponder()
    }
    
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [], coverPhoto: "")
    var isFromDraft = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightButton = UIBarButtonItem(
            title: "發佈", style: .plain,
            target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor(named: "yellowGreen")
       
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        memoryImageView.addGestureRecognizer(tapGesture)
        memoryImageView.isUserInteractionEnabled = true
        titleTextField.delegate = self
        titleTextField.text = onePlan.planName
    }
    
    @objc func rightButtonTapped() {
        let firestoreManagerForPost = FirestoreManagerMemoryPost()
//        firestoreManagerForPost.delegate = self
        let firestore = FirestoreManagerFetchUser()
        firestore.fetchUserInfo{ userData, error  in
            if error != nil {
                print("Error fetching one plan: \(String(describing: error))")
            } else {
                self.onePlan.user = userData?.name
                self.onePlan.userPhoto = userData?.photo
                self.onePlan.userId = userData?.id
            }
        }
//        onePlan.user = Auth.auth().currentUser?.displayName
//        onePlan.userPhoto = Auth.auth().currentUser?.photoURL?.absoluteString
//        onePlan.userId = Auth.auth().currentUser?.uid
                firestoreManagerForPost.postMemory(memory: self.onePlan) { error in
                        if error != nil {
                            print("Failed to post TravelPlan")
                        } else {
                            print("Posted TravelPlan successfully!")}
                }
           
                if let navigationController = self.navigationController {
                 let viewControllers = navigationController.viewControllers
                 if viewControllers.count == 4 {
                     let targetViewController = viewControllers[viewControllers.count - 4]
                     navigationController.popToViewController(targetViewController, animated: true)
                                 }
                             }
        
        if isFromDraft == true {
            // draft edit and complete
            if let navigationController = self.navigationController {
             let viewControllers = navigationController.viewControllers
             if viewControllers.count == 3 {
                 if let targetViewController = viewControllers[viewControllers.count - 3] as? MemoryViewController {
                    
//                     targetViewController.viewWillAppear(true)
                     navigationController.popToViewController(targetViewController, animated: true)
                     
                 }
                             }
                         }
            let firestoreManager = FirestoreManagerFetchMemory()
            firestoreManager.deleteMemory(dbcollection: "MemoryDraft", withID: onePlan.id) { error in
                if let error = error {
                    print("Failed to delete Draft: \(error)")
                } else {
                    print("Draft deleted successfully.")
                }
            }
        }      
            }
    
    @objc func imageViewTapped() {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
           if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
               // 在這裡處理選擇的圖片
               memoryImageView.image = selectedImage
               let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
               firebaseStorageManager.delegate = self

               firebaseStorageManager.uploadPhotoToFirebaseStorage(image: selectedImage) { uploadResult in
                   switch uploadResult {
                   case .success(let downloadURL):
                       print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")
                       self.onePlan.coverPhoto = downloadURL.absoluteString
                   case .failure(let error):
                       print("Error uploading to Firebase Storage: \(error.localizedDescription)")
                   }
               }
           }
           picker.dismiss(animated: true, completion: nil)
       }

       // UIImagePickerControllerDelegate 方法 - 取消選擇
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
   }

extension EditMemoryTitleViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            // This method is called whenever the user types or deletes characters in the text field
            // Update the planName property based on the changes in the text field
            if let currentText = textField.text,
                let range = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                onePlan.planName = updatedText
            }

            return true
        }
}

extension EditMemoryTitleViewController: FirebaseStorageManagerUploadDelegate {
    func manager(_ manager: FirebaseStorageManagerUploadPhotos) {
    }
}
