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
        configureTableView()
        configureHeaderView()
        fetchAMemory()
        configureRightButton()
        configureBlurEffectView()
        configureNotification()
    }
    
    func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
    }
    
    func configureHeaderView() {
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.travelPlanId = travelPlanId
        tableView.tableHeaderView = headerView
    }
    
    func fetchAMemory() {
        let firestoreManagerForOne = FirestoreManagerFetchMemory()
        firestoreManagerForOne.fetchOneMemory(
            dbcollection: dbCollection, 
            userId: Auth.auth().currentUser?.uid ?? "",
            byId: memoryId) { (memory, error) in
            if let error = error {
                print("Error fetching one memory: \(error)")
            } else if let memory = memory {
                print("Fetched one memory: \(memory)")
                self.onePlan = memory
                self.tableView.reloadData()
                self.configureDays()
                let allLocationsHaveNoMemeoryPhotos = self.onePlan.days.allSatisfy { 
                    $0.locations.allSatisfy {
                        $0.memoryPhotos?.isEmpty == true } }
                    if allLocationsHaveNoMemeoryPhotos {
                        self.removeLoadingView()
                    }
            } else {
                print("One memory not found.")
            }
        }
    }
    
    func configureNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
        self,
        selector: #selector(keyboardWillHide(_:)),
        name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureRightButton() {
        let rightButton = UIBarButtonItem(title: "完成", style: .plain,
                                          target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor(named: "yellowGreen")
    }
    
    func configureDays() {
        let counts = self.onePlan.days.count
        let originalCount = self.days.count
            if counts > originalCount {
                for _ in originalCount...counts - 1 {
                    let number = self.days.count
                    self.days.insert("第\(number + 1)天", at: number)
                }
            }
        self.headerView.days = self.days
        self.headerView.onePlan = self.onePlan
        self.headerView.collectionView.reloadData()
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
            if let destinationVC = segue.destination 
                as? EditMemoryTitleViewController {
                destinationVC.isFromDraft = true
            }
        }
    }
    
    func updateAMemory() {
        let firestoreManagerForPost = FirestoreManagerMemoryPost()
        firestoreManagerForPost.updateMemory(dbcollection: dbCollection, 
                                             memory: self.onePlan, memoryId: memoryId) { error in
            if error != nil {
                print("Failed to post Memory")
            } else {
                print("Posted Memory successfully!")}
        }
    }
    
    func updateUserInfo() {
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
    }
   
    @objc func rightButtonTapped() {
        if dbCollection == "Memory" {
            updateAMemory()
            navigationController?.popViewController(animated: true)
        } else {
            // 草稿頁的話要先問用戶要更新草稿還是發布成回憶
            if let updateorPostVC = storyboard?.instantiateViewController(
                withIdentifier: "UpdateDraftorPostViewController")
                as? UpdateDraftorPostViewController {
                updateorPostVC.postButtonTapped = {
                    self.performSegue(withIdentifier: "draftPost", sender: self)
                    updateorPostVC.dismiss(animated: true)
                }
                updateorPostVC.updateButtonTapped = {
                    self.updateUserInfo()
                    self.updateAMemory()
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
        fetchAMemory()
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
        cell.articleTextView.tag = indexPath.section * 1000 + indexPath.row
        cell.articleTextView.delegate = self
        configureImageCollectionView(for: cell, in: indexPath)
        return cell
    }
    
    func configureImageCollectionView(for cell: EditMemoryCell, in indexPath: IndexPath) {
        cell.imageCollectionView.dataSource = self
        cell.imageCollectionView.delegate = self
        cell.imageCollectionData = onePlan.days[indexPath.section].locations[indexPath.row].memoryPhotos ?? []
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        
        cell.imageCollectionView.collectionViewLayout = layout
        cell.imageCollectionView.showsHorizontalScrollIndicator = false
        cell.imageCollectionView.tag = indexPath.section * 1000 + indexPath.row
        cell.imageCollectionView.reloadData()
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
           guard let section = currentIndexPath?.section,
               let row = currentIndexPath?.row,
               section < onePlan.days.count,
               row < onePlan.days[section].locations.count,
            let memoryPhotos = onePlan.days[section].locations[row].memoryPhotos else {
               return cell
           }
           let imageIndex = indexPath.item - 1
           let imageURLString = memoryPhotos[imageIndex]
           cell.memoryImageView.image = nil
           if let url = URL(string: imageURLString) {
               loadImageFromStorage(in: indexPath, for: cell, imageURLString: imageURLString)
           }
           return cell
       }
   }
    
    func loadImageFromStorage(in indexPath: IndexPath, for cell: ImageCollectionViewCell, imageURLString: String) {
        if let url = URL(string: imageURLString) {
            cell.memoryImageView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Image_Placeholder"),
                options: [
                    .transition(.fade(0.2)),
                    .cacheOriginalImage
                ],
                completionHandler: { _ in
                    self.removeLoadingView()
                }
            )
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
            guard let indexPath = currentIndexPath else {
                picker.dismiss(animated: true, completion: nil)
                return
            }
            uploadImageToDB(in: indexPath, with: selectedImage)
        }

        picker.dismiss(animated: true, completion: nil)
        addLoadingView()
    }
    
    func uploadImageToDB(in indexPath: IndexPath, with selectedImage: UIImage) {
        var location = onePlan.days[indexPath.section].locations[indexPath.row]
        let firebaseStorageManager = FirebaseStorageManagerUploadPhotos()
        firebaseStorageManager.uploadPhotoToFirebaseStorage(image: selectedImage) { uploadResult in
            switch uploadResult {
            case .success(let downloadURL):
                print("Upload to Firebase Storage successful. Download URL: \(downloadURL)")
                DispatchQueue.main.async {
                    if location.memoryPhotos == nil {
                        location.memoryPhotos = []
                    }
                    location.memoryPhotos?.append(downloadURL.absoluteString)
                    self.onePlan.days[indexPath.section].locations[indexPath.row] = location
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            case .failure(let error):
                print("Error uploading to Firebase Storage: \(error.localizedDescription)")
            }
        }
    }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
    
}
