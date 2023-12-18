//
//  PlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import NVActivityIndicatorView

class PlanViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView! 
    
    var planIndex = 0
    var plans: [TravelPlan] = []
    var togetherPlans: [TravelPlan] = []
    var spotsData: [[String: Any]] = []
    let activityIndicatorView = NVActivityIndicatorView(
            frame: CGRect(x: UIScreen.main.bounds.width / 2 - 25, y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
                  type: .ballBeat,
                  color: UIColor(named: "darkGreen") ?? .white,
                  padding: 0
              )
    var blurEffectView: UIVisualEffectView!
    var linkPlanId = ""
    var linkUserId = ""
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
        add.addTarget(self, action: #selector(createPlan), for: .touchUpInside)
        return add
    }()
    
    @objc func createPlan() {
        performSegue(withIdentifier: "goToCreate", sender: self)  
    }
    
    func linkToEdit() {
        performSegue(withIdentifier: "goToEdit", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userId = UserDefaults.standard.string(forKey: "userId"),
           let planId = UserDefaults.standard.string(forKey: "planId") {
            // 在這裡使用 userId 和 planId 進行相應的處理
            print("userId: \(userId), planId: \(planId)")}
//
//            // 如果需要，你可以在這裡執行導航到 EditPlanViewController 的相關邏輯
//            let editPlanViewController = EditPlanViewController()// 初始化你的 EditPlanViewController
//            editPlanViewController.userId = userId
//            editPlanViewController.travelPlanId = planId
//            navigationController?.pushViewController(editPlanViewController, animated: true)
//            
//        }
        
        
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = PlanHeaderView(reuseIdentifier: "PlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
        tableView.tableHeaderView = headerView
        view.addSubview(addButton)
        setUpButton()

        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }
    func setUpButton() {
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let userId = UserDefaults.standard.string(forKey: "userId"),
           let planId = UserDefaults.standard.string(forKey: "planId") {
            // 在這裡使用 userId 和 planId 進行相應的處理
            print("userId: \(userId), planId: \(planId)")}
//            
//            // 如果需要，你可以在這裡執行導航到 EditPlanViewController 的相關邏輯
//            let editPlanViewController = EditPlanViewController()// 初始化你的 EditPlanViewController
//            editPlanViewController.userId = userId
//            editPlanViewController.travelPlanId = planId
//            navigationController?.pushViewController(editPlanViewController, animated: true)
//            
//        }
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        
        let firestoreManager = FirestoreManager()
        firestoreManager.delegate = self
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                // Handle the retrieved travel plans
                print("Fetched travel plans: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
                if self.plans.isEmpty && self.planIndex == 0 {
                    self.activityIndicatorView.stopAnimating()
                    self.blurEffectView.removeFromSuperview()
                    self.activityIndicatorView.removeFromSuperview()
                }
                
            }
        }
        if togetherPlans.isEmpty && planIndex == 1 {
            self.activityIndicatorView.stopAnimating()
            self.blurEffectView.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
    }
}

extension PlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if planIndex == 0 {
          return  plans.count
        } else {
           return 0
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if planIndex == 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as? MyPlanCell
            else { fatalError("Could not create PlanCell") }
            cell.planImageView.image = nil
            cell.planNameLabel.text = plans[indexPath.row].planName
            let start = changeDateFormat(date: "\(plans[indexPath.row].startDate)")
            let end = changeDateFormat(date: "\(plans[indexPath.row].endDate)")
            cell.planDateLabel.text = "\(start)-\(end)"

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
                                    cell.planImageView.image = image
                                    cell.planNameLabel.text = self.plans[indexPath.row].planName
                                    
                                } else {
                                    cell.planImageView.image = UIImage(named: "Image_Placeholder")
                                }
                                
                            }
                        }
                    } else {
                        cell.planImageView.image = UIImage(named: "Image_Placeholder")
                    }
                } else {
                    cell.planImageView.image = UIImage(named: "Image_Placeholder")
                }
                self.activityIndicatorView.stopAnimating()
                self.blurEffectView.removeFromSuperview()
                self.activityIndicatorView.removeFromSuperview()
            }
            
            
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "TogetherPlanCell",
                for: indexPath) as? TogetherPlanCell
            else { fatalError("Could not create TogetherPlanCell") }
            
            if let image = UIImage(named: "日本") {
                cell.planImageView.image = image
                   }
            return cell
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
        performSegue(withIdentifier: "goToEdit", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEdit", let indexPath = sender as? IndexPath {
            guard let destinationVC = segue.destination
                    as? EditPlanViewController else { fatalError("Can not create EditPlanViewController") }
            destinationVC.travelPlanId = plans[indexPath.row].id 
            destinationVC.userId = Auth.auth().currentUser?.uid ?? ""
            print("destinationVC.userId\(destinationVC.userId)")
               }
//        if segue.identifier == "goToEdit" {
//            guard let destinationVC = segue.destination
//                    as? EditPlanViewController else { fatalError("Can not create EditPlanViewController") }
//            destinationVC.travelPlanId = linkPlanId
//            destinationVC.userId = linkUserId
//            print("destinationVC.userId\(linkUserId)")
//               }
    }
    
    func tableView(
        _ tableView: UITableView,
        editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension PlanViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if planIndex == 0 {
           return 300
        } else {
            return 300
        }
    }
    
    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.row < plans.count {
               
                let firestoreManager = FirestoreManager()
                firestoreManager.deleteTravelPlan(withID: plans[indexPath.row].id) { error in
                    if let error = error {
                        print("Failed to delete travel plan: \(error)")
                    } else {
                        print("Travel plan deleted successfully.")
                        self.plans.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
                
                   } else {
                       print("Index out of range. indexPath.row: \(indexPath.row), plans count: \(plans.count)")
                   }
        }
    }
}

extension PlanViewController: PlanHeaderViewDelegate {
    func change(to index: Int) {
        planIndex = index
        view.addSubview(blurEffectView)
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
        tableView.reloadData()
        if plans.isEmpty && planIndex == 0 {
            self.activityIndicatorView.stopAnimating()
            self.blurEffectView.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
        if togetherPlans.isEmpty && planIndex == 1 {
            self.activityIndicatorView.stopAnimating()
            self.blurEffectView.removeFromSuperview()
            self.activityIndicatorView.removeFromSuperview()
        }
    }
}

extension PlanViewController: FirestoreManagerDelegate {
    func manager(_ manager: FirestoreManager, didGet firestoreData: [TravelPlan]) {
        plans = firestoreData
    }
}

extension PlanViewController: FirebaseStorageManagerDownloadDelegate {
    func manager(_ manager: FirebaseStorageManagerDownloadPhotos) {
    }
}
