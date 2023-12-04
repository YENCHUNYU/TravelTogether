//
//  EditMemoryViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/30.
//

import UIKit
import FirebaseFirestore

class EditMemoryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    var onePlan: TravelPlan = TravelPlan(
        id: "", planName: "",
        destination: "",
        startDate: Date(), endDate: Date(), days: [])
    var travelPlanId = "1sXW0pQVIAKEdFuLNeHK"
    var dayCounts = 1
    var days: [String] = ["第1天"]
    let headerView = EditMemoryHeaderView(reuseIdentifier: "EditMemoryHeaderView")
    var imageCollections: ImageCollection = ImageCollection(data: [
        [
        UIImage(named: "台北景點") ?? UIImage(),
        UIImage(named: "台北景點") ?? UIImage(),
        UIImage(named: "台北景點") ?? UIImage(),
        UIImage(named: "台北景點") ?? UIImage()],
        [UIImage(named: "雲林古坑") ?? UIImage()]
    ])
    var memoryPhotos: [String] = []
    var oneMemory: Memory = Memory(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])
    var currentIndexPath: IndexPath?

    private var itemsPerRow: CGFloat = 2
    private var sectionInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 50)
        headerView.delegate = self
        headerView.travelPlanId = travelPlanId
        
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
        
        tableView.dragInteractionEnabled = true
        
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched one travel plan: \(travelPlan)")
                self.onePlan = travelPlan
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
            } else {
                print("One travel plan not found.")
            }
        }
        
        let rightButton = UIBarButtonItem(title: "下一步", style: .plain, 
                                          target: self, action: #selector(rightButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.tintColor = UIColor(named: "yellowGreen")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditTitle" {
            if let destinationVC = segue.destination as? EditMemoryTitleViewController {
                destinationVC.oneMemory = self.oneMemory
                print("self.onePlan\(self.onePlan)")
                destinationVC.onePlan = self.onePlan
            }
        }
    }
   
    @objc func rightButtonTapped() {
       
         performSegue(withIdentifier: "goToEditTitle", sender: self)
       }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
            if let error = error {
                print("Error fetching one travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                self.onePlan = travelPlan
                self.tableView.reloadData()
//               self.headerView.collectionView.reloadData()
            } else {
                print("One travel plan not found.")
            }
        }
    }
}

extension EditMemoryViewController: UITableViewDataSource, EditMemoryCellDelegate {
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

        let location = onePlan.days[indexPath.section].locations[indexPath.row]

        cell.placeNameLabel.text = location.name
        cell.addressLabel.text = location.address
        
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
        
//        cell.articleTextView.delegate = cell
        cell.delegate = self
        return cell
    }
    
    func textViewDidChange(_ textView: UITextView) {
            let dayIndex = textView.tag / 1000
            let locationIndex = textView.tag % 1000
            onePlan.days[dayIndex].locations[locationIndex].article = textView.text
        }
}

extension EditMemoryViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        heightForRowAt indexPath: IndexPath) -> CGFloat {
            330
    }
}

extension EditMemoryViewController: FirestoreManagerForOneDelegate {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan) {
        onePlan = firestoreData
    }
}

extension EditMemoryViewController: EditMemoryHeaderViewDelegate {
    
    func passDays(daysData: [String]) {
        self.days = daysData
    }
    
    func reloadData() {
        let firestoreManagerForOne = FirestoreManagerForOne()
        firestoreManagerForOne.delegate = self
        firestoreManagerForOne.fetchOneTravelPlan(byId: travelPlanId) { (travelPlan, error) in
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

extension EditMemoryViewController: UICollectionViewDataSource, 
                                        UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        var indexPath = IndexPath(row: collectionView.tag, section: 0)
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
//           if onePlan.days[indexPath.section].locations[indexPath.row].memoryPhotos?.isEmpty == false {
               
           guard let memoryPhotos = onePlan.days[currentIndexPath?.section ?? 0].locations[currentIndexPath?.row ?? 0].memoryPhotos else {
               return cell
           }
           for image in memoryPhotos {
               if let url = URL(string: image) {
                   let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                   firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                       DispatchQueue.main.async {
                           if let image = image {
                               cell.memoryImageView.image = image
                           } else {
                               cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                           }
                       }
                   }
//               }
           }}
//           imageCollections.data[0][indexPath.item - 1]
           return cell
       }
   }
    
    @objc func imageButtonTapped(_ sender: UIButton) {
        // Get the indexPath from the button's position
        let point = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: point) {
            showImagePicker(forIndexPath: indexPath)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var widthperItem: CGFloat = 0
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        widthperItem = availableWidth / 3
        return CGSize(width: widthperItem, height: 88)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
}

extension EditMemoryViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension EditMemoryViewController: FirebaseStorageManagerDelegate {
    func manager(_ manager: FirebaseStorageManagerUploadPhotos) {
    }
}

extension EditMemoryViewController: FirebaseStorageManagerDownloadDelegate {
    func manager(_ manager: FirebaseStorageManagerDownloadPhotos) {
    }
}
