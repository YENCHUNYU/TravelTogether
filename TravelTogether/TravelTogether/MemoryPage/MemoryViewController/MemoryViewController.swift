//
//  MemoryViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import NVActivityIndicatorView
import Kingfisher

class MemoryViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, 
                          y: UIScreen.main.bounds.height / 2 - 25,
                          width: 50, height: 50),
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
        configureBlurEffectView()
        configureTableView()
        configureHeaderView()
        view.addSubview(addButton)
        setUpButton()
        fetchMemories()
        fetchMemoryDrafts()
    }
    
    func configureBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
    }

    func configureTableView() {
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func configureHeaderView() {
        let headerView = MemoryHeaderView(reuseIdentifier: "MemoryHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
        tableView.tableHeaderView = headerView
    }
    
    func fetchMemories() {
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchMemories { (memories, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(memories ?? [])")
                self.memories = memories ?? []
                self.tableView.reloadData()
                if self.memories.isEmpty && self.memoryIndex == 0 {
                    self.removeLoadingView()
                }
            }
        }
    }
    
    func fetchMemoryDrafts() {
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchMemoryDrafts { (memories, error) in
            if let error = error {
                print("Error fetching memoryDrafts: \(error)")
            } else {
                print("Fetched memoryDrafts: \(memories ?? [])")
                self.memoryDrafts = memories ?? []
                self.tableView.reloadData()
                if self.memoryDrafts.isEmpty && self.memoryIndex == 1 {
                    self.removeLoadingView()
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadingView()
        fetchMemories()
        fetchMemoryDrafts()
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
            configureCell(for: cell, with: self.memories[indexPath.row])
            return cell
        } else {
            configureCell(for: cell, with: self.memoryDrafts[indexPath.row])
            return cell
        }
    }
     
    func configureCell(for cell: MemoryCell, with memory: TravelPlan) {
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        cell.memoryNameLabel.text = memory.planName
        let start = DateUtils.changeDateFormat("\(memory.startDate)")
        let end = DateUtils.changeDateFormat("\(memory.endDate)")
        cell.memoryDateLabel.text = "\(start)-\(end)"
        cell.memoryImageView.image = nil

        if memoryIndex == 0 {
            configureCellForCoverPhoto(memory: memory, cell: cell)
        } else {
            configureCellForDraftPhoto(memory: memory, cell: cell)
        }
    }

    func configureCellForCoverPhoto(memory: TravelPlan, cell: MemoryCell) {
        if let urlString = memory.coverPhoto, !urlString.isEmpty, let url = URL(string: urlString) {
            downloadImageFromFirestorage(url: url, cell: cell)
        } else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
        }
    }

    func configureCellForDraftPhoto(memory: TravelPlan, cell: MemoryCell) {
        guard let daysData = memory.days.first, !daysData.locations.isEmpty else {
            cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
            removeLoadingView()
            return
        }

        let urlString = daysData.locations[0].photo
        if let url = URL(string: urlString) {
            downloadImageFromFirestorage(url: url, cell: cell)
        }
    }

    func downloadImageFromFirestorage(url: URL, cell: MemoryCell) {
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
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editMemory" {
            if let destinationVC = segue.destination as? SelectedMemoryEditViewController {
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
        300
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if memoryIndex == 0 {
                deleteMemoryFromDB(memoryId: memories[indexPath.row].id, indexPath: indexPath) {
                    self.memories.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            } else {
                deleteMemoryFromDB(memoryId: memoryDrafts[indexPath.row].id, indexPath: indexPath) {
                    self.memoryDrafts.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                }
            }
        }
    }
    func deleteMemoryFromDB(memoryId: String, indexPath: IndexPath, completion: @escaping() -> Void) {
        let firestoreManager = FirestoreManagerFetchMemory()
        firestoreManager.deleteMemory(dbcollection: dbCollection, withID: memoryId) { error in
            if let error = error {
                print("Failed to delete memory/draft: \(error)")
            } else {
                print("memory/draft deleted successfully.")
                completion()
            }
        }
    }
}

extension MemoryViewController: MemoryHeaderViewDelegate {
    func change(to index: Int) {
        addLoadingView()
        memoryIndex = index
        if memoryIndex == 0 {
            dbCollection = "Memory"
            fetchMemories()
        } else {
            dbCollection = "MemoryDraft"
            fetchMemoryDrafts()
        }
    }
}
