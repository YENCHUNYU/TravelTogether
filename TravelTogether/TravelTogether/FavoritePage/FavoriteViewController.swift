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
        padding: 0)
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        configureLoadingView()
        fetchMemories()
    }
    
    func configureLoadingView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
    }
    
    func fetchMemories() {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLoading()
        fetchMemories()
    }
    
    func startLoading() {
         view.addSubview(blurEffectView)
         view.addSubview(activityIndicatorView)
         activityIndicatorView.startAnimating()
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
        return configureCell(indexPath: indexPath, cell: cell, memories: memories)
    }
    
    func configureCell(indexPath: IndexPath, cell: FavoriteMemoryCell, memories: [TravelPlan]) -> UITableViewCell {
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        cell.userNameLabel.text = memories[indexPath.row].user
        cell.userImageView.kf.setImage(
            with: URL(string: memories[indexPath.row].userPhoto ?? ""),
            placeholder: UIImage(systemName: "person.circle.fill"))
        cell.memoryNameLabel.text = self.memories[indexPath.row].planName
        let start = DateUtils.changeDateFormat("\(self.memories[indexPath.row].startDate)")
        let end = DateUtils.changeDateFormat("\(self.memories[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
        downloadImages(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func downloadImages(cell: FavoriteMemoryCell, indexPath: IndexPath) {
        cell.memoryImageView.image = nil
        guard !memories.isEmpty else {
            stopLoading()
            return
        }
        let urlString = memories[indexPath.row].coverPhoto ?? ""
        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            stopLoading()
            return
        }

        cell.memoryImageView.kf.setImage(
            with: url,
            placeholder: UIImage(named: "Image_Placeholder"),
            options: [
                .transition(.fade(0.2)), // Add a fade transition
                .cacheOriginalImage
            ],
            completionHandler: { _ in
                self.stopLoading()
            }
        )
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
                deleteFavoriteMemory(indexPath: indexPath)
            }
        }
    
    func deleteFavoriteMemory(indexPath: IndexPath) {
        let firestoreManager = FirestoreManagerFavorite()
        firestoreManager.deleteFavorite(
            dbcollection: dbCollection,
            withID: memories[indexPath.row].id) { error in
            if let error = error {
                print("Failed to delete favorite: \(error)")
            } else {
                print("favorite deleted successfully.")
                self.memories.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
}
