//
//  MemoryViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import NVActivityIndicatorView

class MemoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
                  type: .ballBeat,
                  color: UIColor(named: "darkGreen") ?? .white,
                  padding: 0
              )
    var blurEffectView: UIVisualEffectView!
    
    lazy var addButton: UIButton = {
        let add = UIButton()
        add.translatesAutoresizingMaskIntoConstraints = false
        add.backgroundColor = UIColor(named: "darkGreen")
        add.layer.cornerRadius = 25
        add.setTitle("＋", for: .normal)
        add.setTitleColor(.white, for: .normal)
        add.titleLabel?.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        add.heightAnchor.constraint(equalToConstant: 50).isActive = true
        add.widthAnchor.constraint(equalToConstant: 50).isActive = true
        add.addTarget(self, action: #selector(createArticle), for: .touchUpInside)
        return add
    }()
    var memoryIndex = 0
    var memoryId = ""
    var memories: [TravelPlan] = []
    var memoryDrafts: [TravelPlan] = []
    var dbCollection = "Memory"
    @objc func createArticle() {
        performSegue(withIdentifier: "goToSelectPlan", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = MemoryHeaderView(reuseIdentifier: "MemoryHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
        tableView.tableHeaderView = headerView
        view.addSubview(addButton)
        setUpButton()
        
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
//        firestoreFetchMemory.delegate = self
        firestoreFetchMemory.fetchMemories { (memories, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(memories ?? [])")
                self.memories = memories ?? []
                self.tableView.reloadData()
            }
        }
        
        firestoreFetchMemory.fetchMemoryDrafts { (memories, error) in
            if let error = error {
                print("Error fetching memoryDrafts: \(error)")
            } else {
                print("Fetched memoryDrafts: \(memories ?? [])")
                self.memoryDrafts = memories ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
//        if memoryIndex == 0 {
            let firestoreFetchMemory = FirestoreManagerFetchMemory()
            firestoreFetchMemory.fetchMemories { (memories, error) in
                if let error = error {
                    print("Error fetching memories: \(error)")
                } else {
                    print("Fetched memories: \(memories ?? [])")
                    self.memories = memories ?? []
                    self.tableView.reloadData()
                    if self.memories.isEmpty && self.memoryIndex == 0 {
                        self.activityIndicatorView.stopAnimating()
                        self.blurEffectView.removeFromSuperview()
                        self.activityIndicatorView.removeFromSuperview()
                    }
                }
            }
//        } else if memoryIndex == 1 {
//            let firestoreFetchMemory = FirestoreManagerFetchMemory()
            firestoreFetchMemory.fetchMemoryDrafts { (memories, error) in
                if let error = error {
                    print("Error fetching memoryDrafts: \(error)")
                } else {
                    print("Fetched memoryDrafts: \(memories ?? [])")
                    self.memoryDrafts = memories ?? []
                    self.tableView.reloadData()
                    if self.memoryDrafts.isEmpty && self.memoryIndex == 1 {
                        self.activityIndicatorView.stopAnimating()
                        self.blurEffectView.removeFromSuperview()
                        self.activityIndicatorView.removeFromSuperview()
                    }
                }
            }
//        }
    }
    func setUpButton() {
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
}

extension MemoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if memoryIndex == 0 {
            memories.count
        } else {
            memoryDrafts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "MemoryCell",
            for: indexPath) as? MemoryCell
        else { fatalError("Could not create MemoryCell") }
        if memoryIndex == 0 {
            
            cell.memoryNameLabel.text = self.memories[indexPath.row].planName
            let start = self.changeDateFormat(date: "\(self.memories[indexPath.row].startDate)")
            let end = self.changeDateFormat(date: "\(self.memories[indexPath.row].endDate)")
            cell.memoryDateLabel.text = "\(start)-\(end)"
            cell.memoryImageView.image = nil
//            if memories.isEmpty == false {
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if !urlString.isEmpty, let url = URL(string: urlString) {
                    downloadImageFromFirestorage(url: url, cell: cell, indexPath: indexPath)
                } else {
                    let taskIdentifier = UUID().uuidString
                    cell.taskIdentifier = taskIdentifier
                    cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                    self.activityIndicatorView.stopAnimating()
                    self.blurEffectView.removeFromSuperview()
                    self.activityIndicatorView.removeFromSuperview()
                }
//            }
            return cell
        } else {
//            cell.memoryImageView.image = mockImage
            cell.memoryNameLabel.text = memoryDrafts[indexPath.row].planName
            let start = self.changeDateFormat(date: "\(self.memoryDrafts[indexPath.row].startDate)")
            let end = self.changeDateFormat(date: "\(self.memoryDrafts[indexPath.row].endDate)")
            cell.memoryDateLabel.text = "\(start)-\(end)"
            let daysData = memoryDrafts[indexPath.row].days
            if daysData.isEmpty == false {
                let locationData = daysData[0]
                let theLocation = locationData.locations
                if theLocation.isEmpty == false {
                    let urlString = theLocation[0].photo
                    if let url = URL(string: urlString) {
                        downloadImageFromFirestorage(url: url, cell: cell, indexPath: indexPath)
                    }} }
            
            return cell}
    }
    
    func downloadImageFromFirestorage(url: URL, cell: MemoryCell, indexPath: IndexPath) {
        cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
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
                self.activityIndicatorView.stopAnimating()
                self.blurEffectView.removeFromSuperview()
                self.activityIndicatorView.removeFromSuperview()
            }}}
    
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMemory" {
            if let destinationVC = segue.destination as? SelectedMemoryEditViewController {
                print("memoryId\(memoryId)")
                destinationVC.memoryId = memoryId
                if memoryIndex == 0 {
                    destinationVC.dbCollection = "Memory"
                } else {
                    destinationVC.dbCollection = "MemoryDraft"
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if memoryIndex == 0 {
            memoryId = memories[indexPath.row].id
            performSegue(withIdentifier: "editMemory", sender: indexPath)
        } else {
            memoryId = memoryDrafts[indexPath.row].id
            performSegue(withIdentifier: "editMemory", sender: indexPath)
        }
        
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension MemoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if memoryIndex == 0 {
           return 280
        } else {
            return 280
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if memoryIndex == 0 {
                if indexPath.row < memories.count {
                    
                    let firestoreManager = FirestoreManagerFetchMemory()
                    firestoreManager.deleteMemory(dbcollection: dbCollection, withID: memories[indexPath.row].id) { error in
                        if let error = error {
                            print("Failed to delete travel plan: \(error)")
                        } else {
                            print("Travel plan deleted successfully.")
                            self.memories.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                    
                } else {
                    print("Index out of range. indexPath.row: \(indexPath.row), memories count: \(memories.count)")
                }
            } else {
                if indexPath.row < memoryDrafts.count {
                    
                    let firestoreManager = FirestoreManagerFetchMemory()
                    firestoreManager.deleteMemory(dbcollection: dbCollection, withID: memoryDrafts[indexPath.row].id) { error in
                        if let error = error {
                            print("Failed to delete travel plan: \(error)")
                        } else {
                            print("Travel plan deleted successfully.")
                            self.memoryDrafts.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    }
                    
                } else {
                    print("Index out of range. indexPath.row: \(indexPath.row), memories count: \(memoryDrafts.count)")
                }
            }
            
        }
    }
}

extension MemoryViewController: MemoryHeaderViewDelegate {
    func change(to index: Int) {
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        memoryIndex = index
        if memoryIndex == 0 {
            dbCollection = "Memory"
        } else {
            dbCollection = "MemoryDraft"
        }
        tableView.reloadData()
        if memoryDrafts.isEmpty && memoryIndex == 1 {
            self.activityIndicatorView.stopAnimating()
            self.blurEffectView.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
        if memories.isEmpty && memoryIndex == 0 {
            self.activityIndicatorView.stopAnimating()
            self.blurEffectView.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
    }
}
