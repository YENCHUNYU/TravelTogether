//
//  FavoriteViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit

class FavoriteViewController: UIViewController {

    var favoriteIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    var memories: [TravelPlan] = []
    var memoryId = ""
    var userId = ""
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    var planId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteHeaderView.self, forHeaderFooterViewReuseIdentifier: "FavoriteHeaderView")
        let headerView = FavoriteHeaderView(reuseIdentifier: "FavoriteHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        tableView.tableHeaderView = headerView
        headerView.delegate = self
        
        let firestoreFetch = FirestoreManagerFavorite()
        firestoreFetch.fetchAllMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
        firestoreFetch.fetchAllPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let firestoreFetch = FirestoreManagerFavorite()
        firestoreFetch.fetchAllMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
        
        firestoreFetch.fetchAllPlans { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if favoriteIndex == 0 {
            return memories.count
        } else {
            return plans.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if favoriteIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FavoriteMemoryCell",
                for: indexPath) as? FavoriteMemoryCell
            else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = memories[indexPath.row].user
            cell.userImageView.kf.setImage(with: URL(string: memories[indexPath.row].userPhoto ?? ""), placeholder: UIImage(systemName: "person.circle.fill"))
            if memories.isEmpty == false {
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                    firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                cell.memoryImageView.image = image
                                cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                                let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
                                let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
                                cell.dateLabel.text = "\(start)-\(end)"
                            } else {
                                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                            }
                        }
                    }
                } else {
                    // Handle the case where the URL is empty
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                    cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                    let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
                    let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
                    cell.dateLabel.text = "\(start)-\(end)"
                }
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "FavoriteMemoryCell",
                for: indexPath) as? FavoriteMemoryCell
            else { fatalError("Could not create FavoriteMemoryCell") }
            cell.userNameLabel.text = plans[indexPath.row].user
            cell.memoryImageView.image = mockImage
            cell.memoryNameLabel.text = plans[indexPath.row].planName
            cell.userImageView.kf.setImage(with: URL(string: plans[indexPath.row].userPhoto ?? ""), placeholder: UIImage(systemName: "person.circle.fill"))
            let start = self.changeDateFormat(date: "\(self.plans[indexPath.row].startDate)")
            let end = self.changeDateFormat(date: "\(self.plans[indexPath.row].endDate)")
            cell.dateLabel.text = "\(start)-\(end)"
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
            
            return cell}
    }
    
    func changeDateFormat(date: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set the locale to handle the date format

        if let date = dateFormatter.date(from: date) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy年MM月dd日"
            let formattedString = outputFormatter.string(from: date)
            return formattedString
        } else {
            print("Failed to convert the date string.")
            return ""
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if favoriteIndex == 0 {
            memoryId = memories[indexPath.row].id
//            userId = memories[indexPath.row].userId ?? ""
            performSegue(withIdentifier: "FavoriteMemory", sender: self)
        } else {
            planId = plans[indexPath.row].id
//            userId = plans[indexPath.row].userId ?? ""
            performSegue(withIdentifier: "FavoritePlan", sender: self)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "FavoriteMemory" {
            if let destinationVC = segue.destination as? MemoryDetailViewController {
                destinationVC.memoryId = self.memoryId
//                destinationVC.userId = self.userId
                destinationVC.isFromFavorite = true
            }
        }
        if segue.identifier == "FavoritePlan" {
            if let destinationVC = segue.destination as? PlanDetailViewController {
                destinationVC.travelPlanId = self.planId
//                destinationVC.userId = self.userId
                destinationVC.isFromFavorite = true
            }
        }
    }
}
    extension FavoriteViewController: UITableViewDelegate {
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            if favoriteIndex == 0 || favoriteIndex == 1 {
                return 330
            } else {
                return 280
            }
        }
    }

extension FavoriteViewController: FavoriteHeaderViewDelegate {
    func change(to index: Int) {
        favoriteIndex = index
        tableView.reloadData()
    }
}
