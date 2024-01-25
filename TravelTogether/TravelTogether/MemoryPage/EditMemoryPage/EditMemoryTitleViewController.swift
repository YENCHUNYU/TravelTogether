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
        configureRightButton()
        enableImageViewTap()
        titleTextField.delegate = self
        titleTextField.text = onePlan.planName
    }
    
    func configureRightButton() {
        let rightButton = UIBarButtonItem(
            title: "發佈", style: .plain,
            target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor(named: "yellowGreen")
    }
    
    func enableImageViewTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        memoryImageView.addGestureRecognizer(tapGesture)
        memoryImageView.isUserInteractionEnabled = true
    }
    
    func postMemoryToDB(completion: @escaping () -> Void) {
        let firestoreManagerForPost = FirestoreManagerMemoryPost()
        firestoreManagerForPost.postMemory(memory: self.onePlan) { error in
            if error != nil {
                print("Failed to post Memory")
            } else {
                print("Posted Memory successfully!")
                completion()
            }
        }
    }
    
    func fetchUserInfo(completion: @escaping () -> Void) {
        let firestore = FirestoreManagerFetchUser()
        firestore.fetchUserInfo { userData, error  in
            if error != nil {
                print("Error fetching one plan: \(String(describing: error))")
            } else {
                self.onePlan.user = userData?.name
                self.onePlan.userPhoto = userData?.photo
                self.onePlan.userId = userData?.id
                completion()
            }
        }
    }
    
    @objc func rightButtonTapped() {
        fetchUserInfo {
            self.postMemoryToDB {
                if self.isFromDraft == true {
                    // draft edit and complete
                    self.deleteDraftFromDB()
                    self.popToTargetVC(count: 3)
                } else {
                    // add a new memory and complete
                    self.popToTargetVC(count: 4)
                }
            }
        }
    }
    
    func deleteDraftFromDB() {
        let firestoreManager = FirestoreManagerFetchMemory()
        firestoreManager.deleteMemory(dbcollection: "MemoryDraft", withID: onePlan.id) { error in
            if let error = error {
                print("Failed to delete Draft: \(error)")
            } else {
                print("Draft deleted successfully.")
            }
        }
    }
    
    func popToTargetVC(count: Int) {
        if let navigationController = self.navigationController {
            let viewControllers = navigationController.viewControllers
            if viewControllers.count == count {
                let targetViewController = viewControllers[viewControllers.count - count]
                navigationController.popToViewController(targetViewController, animated: true)
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
               memoryImageView.image = selectedImage
               uploadPhotoToDB(with: selectedImage)
           }
           picker.dismiss(animated: true, completion: nil)
       }
    
    func uploadPhotoToDB(with selectedImage: UIImage) {
        let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
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

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
       picker.dismiss(animated: true, completion: nil)
    }
}

extension EditMemoryTitleViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField, shouldChangeCharactersIn range: NSRange,
        replacementString string: String) -> Bool {
            if let currentText = textField.text,
               let range = Range(range, in: currentText) {
                let updatedText = currentText.replacingCharacters(in: range, with: string)
                onePlan.planName = updatedText
            }
            return true
        }
}
