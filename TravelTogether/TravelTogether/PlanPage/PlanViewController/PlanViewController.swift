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
            frame: CGRect(
                x: UIScreen.main.bounds.width / 2 - 25,
                y: UIScreen.main.bounds.height / 2 - 25, width: 50, height: 50),
            type: .ballBeat,
            color: UIColor(named: "darkGreen") ?? .white,
            padding: 0
              )
    var blurEffectView: UIVisualEffectView!
    var planId = ""
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
    let headerView = PlanHeaderView(reuseIdentifier: "PlanHeaderView")
    @objc func createPlan() {
        performSegue(withIdentifier: "goToCreate", sender: self)  
    }
    
    func linkToEdit() {
        performSegue(withIdentifier: "goToEdit", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        setUpHeaderView()
        tableView.tableHeaderView = headerView
        view.addSubview(addButton)
        setUpButton()
        fetchMyPlan()
    }
    
    func setUpHeaderView() {
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 60)
        headerView.delegate = self
        headerView.backgroundColor = UIColor(named: "yellowGreen")
    }
    
    func fetchMyPlans() async {
            let firestoreManager = FirestoreManager()
            await firestoreManager.fetchMyTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
                if let error = error {
                    print("Error fetching travel plans: \(error)")
                } else {
                    print("Fetched travel plan: \(travelPlans ?? [])")
                    self.plans = travelPlans ?? []
                    self.tableView.reloadData()
                }
            }
        }
    
    func fetchMyPlan() {
        let firestoreManager = FirestoreManager()
        firestoreManager.fetchTravelPlans(userId: Auth.auth().currentUser?.uid ?? "") { (travelPlans, error) in
            if let error = error {
                print("Error fetching travel plans: \(error)")
            } else {
                print("Fetched travel plan: \(travelPlans ?? [])")
                self.plans = travelPlans ?? []
                self.tableView.reloadData()
            }
        }
    }

    func setUpButton() {
        addButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -100).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
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
        addLoadingView()
        fetchMyPlan()
        if self.plans.isEmpty && self.planIndex == 0 {
            removeLoadingView()
        }
        if togetherPlans.isEmpty && planIndex == 1 {
            removeLoadingView()
        }
    }
}

extension PlanViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if planIndex == 0 {
          return plans.count
        } else {
            return togetherPlans.count
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          if planIndex == 0 {
              guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as? MyPlanCell
              else { fatalError("Could not create PlanCell") }
              return setUpCell(indexPath: indexPath, cell: cell, plans: plans)
          } else {
              guard let cell = tableView.dequeueReusableCell(
                  withIdentifier: "TogetherPlanCell",
                  for: indexPath) as? TogetherPlanCell
              else { fatalError("Could not create TogetherPlanCell") }
              return cell
          }
      }
      
      func setUpCell(indexPath: IndexPath, cell: MyPlanCell, plans: [TravelPlan]) -> UITableViewCell {
          cell.planImageView.image = nil
          cell.planNameLabel.text = plans[indexPath.row].planName
          let start = changeDateFormat(date: "\(plans[indexPath.row].startDate)")
          let end = changeDateFormat(date: "\(plans[indexPath.row].endDate)")
          cell.planDateLabel.text = "\(start)-\(end)"
          let daysData = plans[indexPath.row].days
          guard daysData.isEmpty == false else {
              removeLoadingView()
              return cell
          }
          let locationData = daysData[0]
          let theLocation = locationData.locations
          guard theLocation.isEmpty == false else {
              cell.planImageView.image = UIImage(named: "Image_Placeholder")
              removeLoadingView()
              return cell
          }
          let urlString = theLocation[0].photo
          guard let url = URL(string: urlString) else {
              cell.planImageView.image = UIImage(named: "Image_Placeholder")
              removeLoadingView()
              return cell
          }
          downloadPhoto(url: url, cell: cell, indexPath: indexPath)
          return cell
      }
      
      func downloadPhoto(url: URL, cell: MyPlanCell, indexPath: IndexPath) {
          let firebaseStorageManager = FirebaseStorageManagerDownloadPhotos()
          firebaseStorageManager.downloadPhotoFromFirebaseStorage(url: url) { image in
              DispatchQueue.main.async {
                  guard let image = image else {
                      cell.planImageView.image = UIImage(named: "Image_Placeholder")
                      self.removeLoadingView()
                      return
                  }
                      cell.planImageView.image = image
                      cell.planNameLabel.text = self.plans[indexPath.row].planName
                  self.removeLoadingView()
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
        if planIndex == 0 {
          planId = plans[indexPath.row].id
        }
        performSegue(withIdentifier: "goToEdit", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToEdit" {
            guard let destinationVC = segue.destination
                    as? EditPlanViewController else { fatalError("Can not create EditPlanViewController") }
            destinationVC.travelPlanId = planId
            destinationVC.userId = Auth.auth().currentUser?.uid ?? ""
            print("destinationVC.travelPlanId\(destinationVC.travelPlanId)")
               }
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
        }
    }
}

extension PlanViewController: PlanHeaderViewDelegate {
    func change(to index: Int) {
        planIndex = index
        addLoadingView()
        tableView.reloadData()
        if plans.isEmpty && planIndex == 0 {
            removeLoadingView()
        }
        if togetherPlans.isEmpty && planIndex == 1 {
            removeLoadingView()
        }
    }
}
