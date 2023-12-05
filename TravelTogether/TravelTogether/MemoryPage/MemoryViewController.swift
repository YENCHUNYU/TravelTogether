//
//  MemoryViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit

class MemoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
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
    var memories: [TravelPlan] = []
    @objc func createArticle() {
        performSegue(withIdentifier: "goToSelectPlan", sender: self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = MemoryHeaderView(reuseIdentifier: "MemoryHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        view.addSubview(addButton)
        setUpButton()
        
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.delegate = self
        firestoreFetchMemory.fetchMemories { (travelPlans, error) in
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
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.delegate = self
        firestoreFetchMemory.fetchMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
    
    func setUpButton() {
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
}

extension MemoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if memoryIndex == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath) as? MemoryCell
            else { fatalError("Could not create MemoryCell") }

            if memories.isEmpty == false {
                let urlString = memories[indexPath.row].coverPhoto ?? ""
                if let url = URL(string: urlString) {
                    let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
                    firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
                        DispatchQueue.main.async {
                            if let image = image {
                                cell.memoryImageView.image = image
                                cell.memoryNameLabel.text = self.memories[indexPath.row].planName
                            } else {
                                cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
                            }    }
                    }
                }}
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoryCell", for: indexPath) as? MemoryCell
            else { fatalError("Could not create MemoryCell") }
            return cell
        }
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
}

extension MemoryViewController: MemoryHeaderViewDelegate {
    func change(to index: Int) {
        memoryIndex = index
        tableView.reloadData()
    }
}

extension MemoryViewController: FirestoreManagerFetchMemoryDelegate {
    func manager(_ manager: FirestoreManagerFetchMemory, didGet firestoreData: [TravelPlan]) {
    }
}
