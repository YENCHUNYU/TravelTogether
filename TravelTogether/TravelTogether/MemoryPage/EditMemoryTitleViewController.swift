//
//  EditMemoryTitlePage.swift
//  TravelTogether
//
//  Created by User on 2023/12/2.
//

import UIKit
import FirebaseFirestore

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
    
    var oneMemory: Memory = Memory(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])
    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    
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
    }
    
    @objc func rightButtonTapped() {
        let firestoreManagerForPost = FirestoreManagerMemoryPost()
        firestoreManagerForPost.delegate = self
//        firestoreManagerForPost.postTravelPlan(travelPlan: onePlan) { error in
//            if let error = error {
//                print("Failed to post TravelPlan")
//            } else {
//                print("Posted TravelPlan successfully!")
                firestoreManagerForPost.postMemory(memory: self.oneMemory) { error in
                        if error != nil {
                            print("Failed to post TravelPlan")
                        } else {
                            print("Posted TravelPlan successfully!")}
                }
                
                if let navigationController = self.navigationController {
                 let viewControllers = navigationController.viewControllers
                 if viewControllers.count >= 4 {
                     let targetViewController = viewControllers[viewControllers.count - 4]
                     navigationController.popToViewController(targetViewController, animated: true)
                                 }
                             }
            }
//        }
//       }
    
    @objc func imageViewTapped() {
            // 顯示 UIImagePickerController
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
               // 在這裡處理選擇的圖片
               memoryImageView.image = selectedImage
           }

           picker.dismiss(animated: true, completion: nil)
       }

       // UIImagePickerControllerDelegate 方法 - 取消選擇
       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
   }
extension EditMemoryTitleViewController: FirestoreManagerMemoryPostDelegate {
    func manager(_ manager: FirestoreManagerMemoryPost, didPost firestoreData: Memory) {
    }
    
    func manager(_ manager: FirestoreManagerMemoryPost, didPost firestoreData: TravelPlan) {
    }
}
