//
//  SearchViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import FirebaseStorage

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var button: UIButton!
    
    var searchIndex = 0
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    var spotsData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchHeaderView.self, forHeaderFooterViewReuseIdentifier: "SearchHeaderView")
        let headerView = SearchHeaderView(reuseIdentifier: "SearchHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
            }
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToMapFromSearch", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromSearch" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = true
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
            }
        }
    }
    
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchIndex == 0 {
            return 1
        } else if searchIndex == 1 {
            return plans.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if searchIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchMemoriesCell",
                for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = "Jenny"
            if let image = UIImage(named: "台北景點") {
                cell.memoryImageView.image = image
                   }
            cell.memoryNameLabel.text = "台北一日遊"
            return cell
        } else if searchIndex == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "SearchMemoriesCell",
                for: indexPath) as? SearchMemoriesCell
            else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = "Jenny"
            cell.memoryImageView.image = mockImage
            cell.memoryNameLabel.text = plans[indexPath.row].planName
            
            let daysData = plans[indexPath.row].days
            if daysData.isEmpty == false {
                let locationData = daysData[0]
                let theLocation = locationData.locations
                if theLocation.isEmpty == false {
                    let urlString = theLocation[0].photo
                    if let url = URL(string: urlString) {
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
                    }}
            }
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SpotCell", for: indexPath) as? SpotCell
            else { fatalError("Could not create SpotCell") }
            if let image = UIImage(named: "雲林古坑") {
                cell.spotImageView.image = image
                   }
            cell.spotNameLabel.text = "雲林古坑"
            return cell
        }   
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchIndex == 0 {
            performSegue(withIdentifier: "MemoryDetail", sender: self)
        }
        
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if searchIndex == 0 || searchIndex == 1 {
           return 350
        } else {
            return 300
        }
    }
}

extension SearchViewController: SearchHeaderViewDelegate {
    func change(to index: Int) {
        searchIndex = index
        tableView.reloadData()
    }
}

extension SearchViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan]) {
        plans = firestoreData
    }
}

extension SearchViewController {
   
    func downloadPhotoFromFirebaseStorage(url: URL, completion: @escaping (UIImage?) -> Void) {
        let storageReference = Storage.storage().reference(forURL: url.absoluteString)

        storageReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error downloading photo from Firebase Storage: \(error.localizedDescription)")
                completion(nil)
            } else if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                print("Failed to create UIImage from data.")
                completion(nil)
            }
        }
    }
}
