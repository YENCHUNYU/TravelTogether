//
//  SelectedMemoryEditVC.swift
//  TravelTogether
//
//  Created by User on 2023/12/6.
//

import UIKit
import FirebaseFirestore
import Photos
import FirebaseAuth
import NVActivityIndicatorView

class SelectedMemoryEditViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = ""
    var dayCounts = 1
    var days: [String] = ["第1天"]
    let headerView = EditMemoryHeaderView(reuseIdentifier: "EditMemoryHeaderView")
    var memoryPhotos: [String] = []
    var currentIndexPath: IndexPath?
    var memoryId = ""
    var dbCollection = ""

    private var itemsPerRow: CGFloat = 2
    private var sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(
                x: UIScreen.main.bounds.width / 2 - 25,
                y: UIScreen.main.bounds.height / 2 - 25,
                width: 50, height: 50),
            type: .ballBeat,
            color: UIColor(named: "darkGreen") ?? .white, padding: 0
              )
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self

        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.delegate = self
        headerView.travelPlanId = travelPlanId
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
      
        
        let firestoreManagerForOne = FirestoreManagerFetchMemory()
        firestoreManagerForOne.fetchOneMemory(dbcollection: dbCollection, byId: memoryId) { (memory, error) in
                        if let error = error {
                            print("Error fetching one memory: \(error)")
                        } else if let memory = memory {
                            print("Fetched one memory: \(memory)")
                            self.onePlan = memory
                            self.tableView.reloadData()
                        } else {
                            print("One memory not found.")
                        }
                    }

        let rightButton = UIBarButtonItem(title: "完成", style: .plain,
                                          target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor(named: "yellowGreen")
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
       NotificationCenter.default.addObserver(
        self, selector: #selector(keyboardWillHide(_:)),
        name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
            guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] 
                                      as? NSValue)?.cgRectValue.size else {
                return
            }

            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
        }

    @objc func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditTitle" || segue.identifier == "draftPost" {
            if let destinationVC = segue.destination as? EditMemoryTitleViewController {
                destinationVC.onePlan = self.onePlan
            }
        }
        if segue.identifier == "draftPost" {
            if let destinationVC = segue.destination as? EditMemoryTitleViewController {
                destinationVC.isFromDraft = true
            }
        }
    }
   
    @objc func rightButtonTapped() {
        if dbCollection == "Memory" {
            let firestoreManagerForPost = FirestoreManagerMemoryPost()
            let firestore = FirestoreManagerFetchUser()
            firestore.fetchUserInfo { userData, error  in
                if error != nil {
                    print("Error fetching one plan: \(String(describing: error))")
                } else {
                    self.onePlan.user = userData?.name
                    self.onePlan.userPhoto = userData?.photo
                    self.onePlan.userId = userData?.id
                }
            }
            firestoreManagerForPost.updateMemory(dbcollection: dbCollection, memory: self.onePlan, memoryId: memoryId) { error in
                if error != nil {
                    print("Failed to post Memory")
                } else {
                    print("Posted Memory successfully!")}
            }
            navigationController?.popViewController(animated: true)
        } else {
            // 草稿頁的話要先問用戶要更新草稿還是發布成回憶
            if let updateorPostVC = storyboard?.instantiateViewController(withIdentifier: "UpdateDraftorPostViewController") 
                as? UpdateDraftorPostViewController {
                updateorPostVC.postButtonTapped = {
                    self.performSegue(withIdentifier: "draftPost", sender: self)
                    updateorPostVC.dismiss(animated: true)
                }
                updateorPostVC.updateButtonTapped = {
                    let firestoreManagerForPost = FirestoreManagerMemoryPost()
                    let firestore = FirestoreManagerFetchUser()
                    firestore.fetchUserInfo { userData, error  in
                        if error != nil {
                            print("Error fetching one plan: \(String(describing: error))")
                        } else {
                            self.onePlan.user = userData?.name
                            self.onePlan.userPhoto = userData?.photo
                            self.onePlan.userId = userData?.id
                        }
                    }
                    firestoreManagerForPost.updateMemory(
                        dbcollection: self.dbCollection,
                        memory: self.onePlan, memoryId: self.memoryId) { error in
                        if error != nil {
                            print("Failed to post Memory")
                        } else {
                            print("Posted Memory successfully!")}
                    }
                    updateorPostVC.dismiss(animated: true)
                    self.navigationController?.popViewController(animated: true)
                }
                
                present(updateorPostVC, animated: true, completion: nil)
            }
        }
       }
    
    func addLoadingView() {
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func removeLoadingView() {
        self.activityIndicatorView.stopAnimating()
        self.blurEffectView.removeFromSuperview()
        self.activityIndicatorView.removeFromSuperview()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadingView()
        let allLocationsHaveNoMemeoryPhotos = onePlan.days.allSatisfy { $0.locations.allSatisfy { $0.memoryPhotos?.isEmpty == true } }

            if allLocationsHaveNoMemeoryPhotos {
                removeLoadingView()
            }
        
        let firestoreManagerForOne = FirestoreManagerFetchMemory()
        firestoreManagerForOne.fetchOneMemory(dbcollection: dbCollection, byId: memoryId) { (memory, error) in
                        if let error = error {
                            print("Error fetching one memory: \(error)")
                        } else if let memory = memory {
                            print("Fetched one memory: \(memory)")
                            self.onePlan = memory
                            self.tableView.reloadData()
                        } else {
                            print("One memory not found.")
                        }
                    }
    }
}

extension SelectedMemoryEditViewController: UITableViewDataSource, UITextViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        onePlan.days.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "第\(section + 1)天"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !onePlan.days.isEmpty, section < onePlan.days.count else {
               return 0
           }
           return onePlan.days[section].locations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "EditMemoryCell",
            for: indexPath) as? EditMemoryCell
        else { fatalError("Could not create EditMemoryCell") }
        currentIndexPath = indexPath
        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.addressLabel.text = location.address
        cell.articleTextView.text = location.article
        
        cell.imageCollectionView.dataSource = self
        cell.imageCollectionView.delegate = self
        cell.imageCollectionData = onePlan.days[indexPath.section].locations[indexPath.row].memoryPhotos ?? []
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Set scroll direction to horizontal
        layout.minimumLineSpacing = 10
        
        cell.imageCollectionView.collectionViewLayout = layout
        cell.imageCollectionView.showsHorizontalScrollIndicator = false
        cell.imageCollectionView.tag = indexPath.section * 1000 + indexPath.row
        cell.imageCollectionView.reloadData()
        cell.articleTextView.tag = indexPath.section * 1000 + indexPath.row
        cell.articleTextView.delegate = self
        
        return cell
    }
    
    func textViewDidChange(_ textView: UITextView) {
            let dayIndex = textView.tag / 1000
            let locationIndex = textView.tag % 1000
            onePlan.days[dayIndex].locations[locationIndex].article = textView.text
        }
}

extension SelectedMemoryEditViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            330
    }
}

extension SelectedMemoryEditViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension SelectedMemoryEditViewController: EditMemoryHeaderViewDelegate {
    
    func passDays(daysData: [String]) {
        self.days = daysData
    }
    
    func reloadData() {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(
            dbCollection: "TravelPlan", userId: Auth.auth().currentUser?.uid ?? "",
            byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                self.onePlan = travelPlan
                self.tableView.reloadData()
                self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
}

extension SelectedMemoryEditViewController: UICollectionViewDataSource,
                                        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dayIndex = collectionView.tag / 1000
        let locationIndex = collectionView.tag % 1000
        if onePlan.days.isEmpty == false && onePlan.days[dayIndex].locations.isEmpty == false {
               let memoryLocation = onePlan.days[dayIndex].locations[locationIndex]
               return (memoryLocation.memoryPhotos?.count ?? 0) + 1
           } else {
               return 1
           }
       }

   func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
       if indexPath.item == 0 {
           guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AddPhotoCell",
            for: indexPath) as? AddPhotoCell else {
               fatalError("Failed to dequeue AddPhotoCell")
           }
           cell.addNewPhotoButton.addTarget(self, action: #selector(imageButtonTapped(_:)), for: .touchUpInside)
           return cell
       } else {
           guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ImageCollectionViewCell",
            for: indexPath) as? ImageCollectionViewCell else {
               fatalError("Failed to dequeue ImageCollectionViewCell")
           }
           
           let firestorageDownload = FirebaseStorageManagerDownloadPhotos()
           firestorageDownload.delegate = self
           guard let section = currentIndexPath?.section,
               let row = currentIndexPath?.row,
               section < onePlan.days.count,
               row < onePlan.days[section].locations.count,
            let memoryPhotos = onePlan.days[section].locations[row].memoryPhotos else {
               return cell
           }
           let imageIndex = indexPath.item - 1 // Subtract 1 because the first item is the "AddPhotoCell"
            let imageURLString = memoryPhotos[imageIndex]
           cell.memoryImageView.image = nil
               if let url = URL(string: imageURLString) {
                   let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                   firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                       DispatchQueue.main.async {
                           if let image = image {
                               cell.memoryImageView.image = image
                           } else {
                               cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                           }
                           self.removeLoadingView()
                       }
           }}
           return cell
       }
   }
    
    @objc func imageButtonTapped(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            showImagePicker(forIndexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout, 
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthperItem: CGFloat = 0
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        widthperItem = availableWidth / 3
        return CGSize(width: widthperItem, height: 88)
    }
    func collectionView(_ collectionView: UICollectionView, 
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension SelectedMemoryEditViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   @objc func showImagePicker(forIndexPath indexPath: IndexPath) {
       currentIndexPath = indexPath

           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .photoLibrary
           present(imagePicker, animated: true, completion: nil)
       }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // Get the current indexPath based on your logic
            guard let indexPath = currentIndexPath else {
                picker.dismiss(animated: true, completion: nil)
                return
            }

            // Update the corresponding location's image array
            var location = onePlan.days[indexPath.section].locations[indexPath.row]
            let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
            firebaseStorageManager.delegate = self

            firebaseStorageManager.uploadPhotoToFirebaseStorage(image: selectedImage) { uploadResult in
                switch uploadResult {
                case .success(let downloadURL):
                    print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")

                    // Update UI on the main thread
                    DispatchQueue.main.async {
                        // Check if memoryPhotos is nil and initialize it
                        if location.memoryPhotos == nil {
                            location.memoryPhotos = []
                        }

                        // Append the download URL to the memoryPhotos array
                        location.memoryPhotos?.append(downloadURL.absoluteString)

                        // Update the corresponding location in onePlan
                        self.onePlan.days[indexPath.section].locations[indexPath.row] = location

                        // Reload the specific cell to reflect the changes
                        self.tableView.reloadRows(at: [indexPath], with: .automatic)
                    }
                case .failure(let error):
                    print("Error uploading to Firebase Storage: \(error.localizedDescription)")
                }
            }
        }

        picker.dismiss(animated: true, completion: nil)
    }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
    
}

extension SelectedMemoryEditViewController: FirebaseStorageManagerUploadDelegate {
    func manager(_ manager: FirebaseStorageManagerUploadPhotos) {
    }
}

extension SelectedMemoryEditViewController: FirebaseStorageManagerDownloadDelegate {
    func manager(_ manager: FirebaseStorageManagerDownloadPhotos) {
    }
}
