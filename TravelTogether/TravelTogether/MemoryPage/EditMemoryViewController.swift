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
    var oneMemory: Memory = Memory(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])

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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "goToEditTitle" {
//            if let destinationVC = segue.destination as? EditMemoryTitleViewController {
//
//                for day in 0..<onePlan.days.count {
//                    oneMemory.days.append(onePlan.days[day])
//                    for location in 0..<onePlan.days[day].locations.count {
//                        oneMemory.days[day].locations.append(onePlan.days[day].locations[location])
//                        let indexPath = IndexPath(row: location, section: day)
//                        if let cell = tableView.cellForRow(at: indexPath) as? EditMemoryCell {
//                            oneMemory.days[day].locations[location].article = cell.articleTextView.text
//                        }
//                    }
//                }
//                
//                destinationVC.oneMemory = self.oneMemory
//                print("self.oneMemory\(self.oneMemory)")
//                destinationVC.onePlan = self.onePlan
//            }
//        }
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEditTitle" {
            if let destinationVC = segue.destination as? EditMemoryTitleViewController {
                
                for day in 0..<onePlan.days.count {
                    var memoryDay = TravelDay(locations: [])
                    
                    for location in 0..<onePlan.days[day].locations.count {
                                         
                        let indexPath = IndexPath(row: location, section: day)
                        if let cell = tableView.cellForRow(at: indexPath) as? EditMemoryCell {
                            var memoryLocation = Location(
                                name: "", photo: "", address: "", user: "", memoryPhotos: [], article: "")
                            
                            memoryLocation.article = cell.articleTextView.text
                             
                            // You might need to populate other properties of memoryLocation as well
                            memoryLocation.name = cell.placeNameLabel.text ?? ""
                            memoryLocation.address = cell.addressLabel.text ?? ""
                            // memoryLocation.photo = ...
                            // memoryLocation.user = ...
                            // memoryLocation.memoryPhotos = ...
                            memoryDay.locations.append(memoryLocation)
                        }
                        
                    }
                    
                    oneMemory.days.append(memoryDay)
                }
                
                destinationVC.oneMemory = self.oneMemory
                print("self.oneMemory\(self.oneMemory)")
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

extension EditMemoryViewController: UITableViewDataSource {
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
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal // Set scroll direction to horizontal
        layout.minimumLineSpacing = 10
        
        cell.imageCollectionView.collectionViewLayout = layout
        cell.imageCollectionView.showsHorizontalScrollIndicator = false
        cell.imageCollectionView.tag = indexPath.row
        cell.imageCollectionView.reloadData()
//        oneMemory.days = MemoryDay(locations: <#T##[MemoryLocation]#>)
        
//        var memoryLocation = MemoryLocation(name: location.name, photo: [], address: location.address)
        // photo上傳到firestore再載下來 photo是url string array
        // 先post整個plan再update memory
//        var memoryDay = MemoryDay(locations: [memoryLocation])
//        oneMemory.days = [memoryDay]
//        oneMemory = Memory(id: onePlan.id, planName: onePlan.planName, destination: "", startDate: onePlan.startDate, endDate: onePlan.endDate, days: [memoryDay])
//        oneMemory.days[indextPath.section].locations[indexPath.row] = MemoryLocation(name: location.name, photo: "", address: location.address)
        return cell
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
        return imageCollections.data[0].count + 1
       }

   func collectionView(_ collectionView: UICollectionView,
                       cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      
       if indexPath.item == 0 {
           guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "AddPhotoCell",
            for: indexPath) as? AddPhotoCell else {
               fatalError("Failed to dequeue AddPhotoCell")
           }
           cell.addNewPhotoButton.addTarget(self, action: #selector(showImagePicker), for: .touchUpInside)
           return cell
       } else {
           guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ImageCollectionViewCell",
            for: indexPath) as? ImageCollectionViewCell else {
               fatalError("Failed to dequeue ImageCollectionViewCell")
           }
           cell.imageView.image = imageCollections.data[0][indexPath.item - 1]
           return cell
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
   @objc func showImagePicker() {
           let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.sourceType = .photoLibrary
           present(imagePicker, animated: true, completion: nil)
       }
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
           if let selectedImage = info[.originalImage] as? UIImage {
               imageCollections.data[0].append(selectedImage)
               self.tableView.reloadData()
           }
           picker.dismiss(animated: true, completion: nil)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
    
}
