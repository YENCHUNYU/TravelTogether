//
//  FavoriteViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit
import NVActivityIndicatorView

class FavoriteViewController: UIViewController {

    var favoriteIndex = 0
    
    @IBOutlet weak var tableView: UITableView!
    var memories: [TravelPlan] = []
    var memoryId = ""
    var userId = ""
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    var planId = ""
    var dbCollection = "FavoriteMemory"
    
    let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
                  type: .ballBeat,
                  color: UIColor(named: "darkGreen") ?? .white,
                  padding: 0
              )
        var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .light)
               blurEffectView = UIVisualEffectView(effect: blurEffect)
               blurEffectView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FavoriteHeaderView.self, forHeaderFooterViewReuseIdentifier: "FavoriteHeaderView")
        let headerView = FavoriteHeaderView(reuseIdentifier: "FavoriteHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        tableView.tableHeaderView = headerView
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
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
        view.addSubview(blurEffectView)
         view.addSubview(activityIndicatorView)
         activityIndicatorView.startAnimating()
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
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteMemoryCell",
            for: indexPath) as? FavoriteMemoryCell
        else { fatalError("Could not create SearchMemoriesCell") }
        if favoriteIndex == 0 {
           
            cell.userNameLabel.text = memories[indexPath.row].user
            cell.userImageView.kf.setImage(with: URL(string: memories[indexPath.row].userPhoto ?? ""), placeholder: UIImage(systemName: "person.circle.fill"))
            if memories.isEmpty == false {
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    downloadImages(cell: cell, indexPath: indexPath, url: url )
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
            cell.userNameLabel.text = plans[indexPath.row].user
//            cell.memoryImageView.image = mockImage
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
                        downloadImages(cell: cell, indexPath: indexPath, url: url )
                    }}
            }
            return cell}
    }
    
    func downloadImages(cell: FavoriteMemoryCell, indexPath: IndexPath, url: URL ) {
        cell.memoryImageView.image = nil
        let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
            DispatchQueue.main.async {
                guard cell.taskIdentifier == taskIdentifier else {
                               return
                           }
                if let image = image {
                    cell.memoryImageView.image = image
                    cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                    let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
                    let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
                    cell.dateLabel.text = "\(start)-\(end)"
                    self.activityIndicatorView.stopAnimating()
                    self.blurEffectView.removeFromSuperview()
                    self.activityIndicatorView.removeFromSuperview()
                } else {
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                }
            }
        }
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
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
extension FavoriteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
       330
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if favoriteIndex == 1 {
                    if indexPath.row < plans.count {
                        
                        let firestoreManager = FirestoreManagerFavorite()
                        firestoreManager.deleteFavorite(dbcollection: dbCollection, withID: plans[indexPath.row].id) { error in
                            if let error = error {
                                print("Failed to delete favorite: \(error)")
                            } else {
                                print("favorite deleted successfully.")
                                self.plans.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    } else {
                        print("Index out of range. indexPath.row: \(indexPath.row), plans count: \(plans.count)")
                    }
                } else {
                    if indexPath.row < memories.count {
                        
                        let firestoreManager = FirestoreManagerFavorite()
                        firestoreManager.deleteFavorite(dbcollection: dbCollection, withID: memories[indexPath.row].id) { error in
                            if let error = error {
                                print("Failed to delete favorite: \(error)")
                            } else {
                                print("favorite deleted successfully.")
                                self.memories.remove(at: indexPath.row)
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    } else {
                        print("Index out of range. indexPath.row: \(indexPath.row), plans count: \(memories.count)")
                    }
                }
            }
        }
}

extension FavoriteViewController: FavoriteHeaderViewDelegate {
    func change(to index: Int) {
        view.addSubview(blurEffectView)
       view.addSubview(activityIndicatorView)
       activityIndicatorView.startAnimating()
        favoriteIndex = index
        if favoriteIndex == 0 {
            dbCollection = "FavoriteMemory"
        } else {
            dbCollection = "FavoritePlan"
        }
        tableView.reloadData()
    }
}
