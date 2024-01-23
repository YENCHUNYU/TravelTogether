//
//  FavoriteViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/13.
//

import UIKit
import NVActivityIndicatorView

class FavoriteViewController: UIViewController {
 
    @IBOutlet weak var tableView: UITableView!
    var memories: [TravelPlan] = []
    var memoryId = ""
    var userId = ""
    var mockImage = UIImage(named: "Image_Placeholder")
    var dbCollection = "FavoriteMemory"
    
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
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
                if self.memories.isEmpty {
                    self.stopLoading()
                }
            }
        }
    }
    
    func stopLoading() {
        self.activityIndicatorView.stopAnimating()
        self.blurEffectView.removeFromSuperview()
        self.activityIndicatorView.removeFromSuperview()
    }
}

extension FavoriteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "FavoriteMemoryCell",
            for: indexPath) as? FavoriteMemoryCell
        else { fatalError("Could not create SearchMemoriesCell") }
            cell.userNameLabel.text = memories[indexPath.row].user
            cell.userImageView.kf.setImage(
                with: URL(string: memories[indexPath.row].userPhoto ?? ""),
                placeholder: UIImage(systemName: "person.circle.fill"))
            cell.memoryNameLabel.text = self.memories[indexPath.row].planName
            let start = DateUtils.changeDateFormat("\(self.memories[indexPath.row].startDate)")
            let end = DateUtils.changeDateFormat("\(self.memories[indexPath.row].endDate)")
            cell.dateLabel.text = "\(start)-\(end)"
            if memories.isEmpty == false {
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    downloadImages(cell: cell, indexPath: indexPath, url: url )
                } else {
                    // Handle the case where the URL is empty
                    let taskIdentifier = UUID().uuidString
                    cell.taskIdentifier = taskIdentifier
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                    cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                    let start = DateUtils.changeDateFormat("\(self.memories[indexPath.row].startDate)")
                    let end = DateUtils.changeDateFormat("\(self.memories[indexPath.row].endDate)")
                    cell.dateLabel.text = "\(start)-\(end)"
                    
                }
            }
            return cell
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
                } else {
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                }
                self.stopLoading()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            memoryId = memories[indexPath.row].id
            performSegue(withIdentifier: "FavoriteMemory", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
        if segue.identifier == "FavoriteMemory" {
            if let destinationVC = segue.destination as? MemoryDetailViewController {
                destinationVC.memoryId = self.memoryId
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
                    if indexPath.row < memories.count {
                        let firestoreManager = FirestoreManagerFavorite()
                        firestoreManager.deleteFavorite(
                            dbcollection: dbCollection,
                            withID: memories[indexPath.row].id) { error in
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
