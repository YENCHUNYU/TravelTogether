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
import FirebaseAuth
import Kingfisher
import AuthenticationServices
import NVActivityIndicatorView

class SearchViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var plans: [TravelPlan] = []
    var mockImage = UIImage(named: "Image_Placeholder")
    var spotsData: [[String: Any]] = []
    var memories: [TravelPlan] = []
    var memoryId = ""
    var userId = ""
    var completedImageFetches: Int = 0
    
    lazy var searchButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "darkGreen")
        button.layer.cornerRadius = 25
        button.setImage(UIImage(named: "search"), for: .normal)
        button.currentImage?.withTintColor(.blue)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.widthAnchor.constraint(equalToConstant: 50).isActive = true
        button.addTarget(self, action: #selector(searchLocation), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    
    @objc func searchLocation() {
        performSegue(withIdentifier: "goToMapFromSearch", sender: self)
    }
    
    let activityIndicatorView = NVActivityIndicatorView(
        frame: CGRect(
            x: UIScreen.main.bounds.width / 2 - 25,
            y: UIScreen.main.bounds.height / 2 - 25,
            width: 50, height: 50),
              type: .ballBeat,
              color: UIColor(named: "darkGreen") ?? .white,
              padding: 0
          )
    var blurEffectView: UIVisualEffectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBlurEffectView()
        configureTableView()
        view.addSubview(searchButton)
        configureButton()
        self.tabBarController?.delegate = self
        fetchMemories()
        LoginViewController.loginStatus = setUpLoginStatus()
    }
    
    func setUpLoginStatus() -> Bool {
        if Auth.auth().currentUser != nil {
            return true
        } else {
            return false
        }
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
    
    func fetchMemories() {
        let firestoreFetchMemory = FirestoreManagerFetchMemory()
        firestoreFetchMemory.fetchAllMemories { (travelPlans, error) in
            if let error = error {
                print("Error fetching memories: \(error)")
            } else {
                print("Fetched memories: \(travelPlans ?? [])")
                self.memories = travelPlans ?? []
                self.tableView.reloadData()
                if self.memories.isEmpty {
                    self.removeLoadingView()
                }
            }
        }
    }
 
    func configureButton() {
        searchButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            return
        }

        switch identifier {
        case "goToMapFromSearch":
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = true
            }
        case "MemoryDetail":
            if let destinationVC = segue.destination as? MemoryDetailViewController {
                destinationVC.memoryId = self.memoryId
                print("self.memoryId\(self.memoryId)")
                destinationVC.userId = self.userId
                print("userid@\(destinationVC.userId)")
            }
        default:
            break
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addLoadingView()
        fetchMemories()
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        memories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "SearchMemoriesCell",
            for: indexPath) as? SearchMemoriesCell
        else { fatalError("Could not create SearchMemoriesCell") }
            return setUpCellForMemories(
                indexPath: indexPath, cell: cell, plans: memories)
    }
    
    func setUpCellForMemories(indexPath: IndexPath, cell: SearchMemoriesCell, plans: [TravelPlan]) -> UITableViewCell {
        let taskIdentifier = UUID().uuidString
        cell.taskIdentifier = taskIdentifier
        cell.userNameLabel.text = memories[indexPath.row].user
        cell.userImageView.kf.setImage(
            with: URL(string: memories[indexPath.row].userPhoto ?? ""),
            placeholder: UIImage(systemName: "person.circle.fill"))
        cell.memoryNameLabel.text = memories[indexPath.row].planName
        cell.memoryImageView.image = UIImage(named: "Image_Placeholder")
        let start = DateUtils.changeDateFormat("\(self.memories[indexPath.row].startDate)")
        let end = DateUtils.changeDateFormat("\(self.memories[indexPath.row].endDate)")
        cell.dateLabel.text = "\(start)-\(end)"
        loadMemoryImage(indexPath: indexPath, cell: cell)
        return cell
    }

    func loadMemoryImage(indexPath: IndexPath, cell: SearchMemoriesCell) {
        guard !memories.isEmpty else {
            removeLoadingView()
            return
        }

        let urlString = memories[indexPath.row].coverPhoto ?? ""

        guard !urlString.isEmpty, let url = URL(string: urlString) else {
            removeLoadingView()
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
                self.removeLoadingView()
            }
        )
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            memoryId = memories[indexPath.row].id
            userId = memories[indexPath.row].userId ?? ""
            performSegue(withIdentifier: "MemoryDetail", sender: self)
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          330
    }
}

extension SearchViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard !LoginViewController.loginStatus else { // 登入中 return true
            return true
        }
        guard viewController.tabBarItem.tag > 0 else { // 未登入 且點擊tag>0
            return false
        }
        guard let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") 
                as? LoginViewController else {
            return false
        }
        let loginNavController = UINavigationController(rootViewController: loginVC)
        present(loginNavController, animated: true, completion: nil)
        return false
    }
}
