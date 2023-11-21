//
//  EditPlanViewController.swift
//  TravelTogether
//
//  Created by User on 2023/11/18.
//

import UIKit
import FirebaseFirestore

class EditPlanViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var planIndex = 0
    var plans: [TravelPlan] = [TravelPlan(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), allSpots: [])]
    var travelPlanIndex = 0
    var planSpots: [String] = []
    var travelPlanId = ""
    var allSpotsData: [[String: Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EditPlanFooterView.self, forHeaderFooterViewReuseIdentifier: "EditPlanFooterView")
        let headerView = EditPlanHeaderView(reuseIdentifier: "EditPlanHeaderView")
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: 100)
        headerView.delegate = self
        tableView.tableHeaderView = headerView
        tableView.separatorStyle = .none
//ok
//        fetchTravelPlans { (travelPlans, error) in
//            if let error = error {
//                print("Error fetching travel plans: \(error)")
//            } else {
//                // Handle the retrieved travel plans
//                print("Fetched travel plans: \(travelPlans ?? [])")
//                self.plans = travelPlans ?? []
//              //  self.spots = self.plans[self.travelPlanIndex].allSpots ?? []
//                self.tableView.reloadData()
//            }
//        }
//   ok2
//        fetchSpotsForDay(id: travelPlanId, day: 1) { spots, error in
//            if let error = error {
//                print("Error fetching spots for Day 1: \(error)")
//            } else {
//                if let spots = spots {
//                    // 在這裡處理成功獲取到的 spots 數據
//                    print("Spots for Day 1: \(spots)")
//                    self.planSpots = spots
//                } else {
//                    print("No spots data for Day 1")
//                }
//            }
//        }
//

        
        fetchAllSpotsForTravelPlan(id: travelPlanId, day: 1) { spots, error in
            if let error = error {
                print("Error fetching spots for Day 1: \(error)")
            } else {
                    print("Spots for Day 1: \(spots)")
              //  self.tableView.reloadData()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
//        fetchTravelPlans { (travelPlans, error) in
//            if let error = error {
//                print("Error fetching travel plans: \(error)")
//            } else {
//                // Handle the retrieved travel plans
//                print("Fetched travel plans: \(travelPlans ?? [])")
//                self.plans = travelPlans ?? []
//             //   self.spots = self.plans[self.travelPlanIndex].allSpots ?? []
//                self.tableView.reloadData()
//            }
//        }
        fetchAllSpotsForTravelPlan(id: travelPlanId, day: 1) { spots, error in
            if let error = error {
                print("Error fetching spots for Day 1: \(error)")
            } else {
                    print("Spots for Day 1: \(spots)")
                self.tableView.reloadData()
            }
        }
    }
    
}

extension EditPlanViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       return "第\(section + 1)天"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        allSpotsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlanCell", for: indexPath) as? EditPlanCell
            else { fatalError("Could not create EditPlanCell") }
       // cell.placeNameLabel.text = plans[travelPlanIndex].allSpots?[indexPath.row]
        let spotData = allSpotsData[indexPath.row]
print("qqq\(allSpotsData)")
                if let name = spotData["name"] as? String {
                    cell.placeNameLabel.text = name
                }
            return cell
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
// FOOTER
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EditPlanFooterView") as? EditPlanFooterView
        else { fatalError("Could not create EditPlanFooterView") }
        view.createNewPlanButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return view
    }
    
    @objc func createButtonTapped() {
    performSegue(withIdentifier: "goToMapFromEditPlan", sender: self)
       
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMapFromEditPlan" {
  
            if let destinationVC = segue.destination as? MapViewController {
                destinationVC.isFromSearch = false
                destinationVC.travelPlanIndex = travelPlanIndex
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        40
    }
}

extension EditPlanViewController: UITableViewDelegate {
func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    80
}
}

extension EditPlanViewController: EditPlanHeaderViewDelegate {
    func change(to index: Int) {
        planIndex = index
        tableView.reloadData()
    }
}

extension EditPlanViewController {
    // Firebase
    
    func fetchTravelPlans(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
        let db = Firestore.firestore()

        let travelPlansRef = db.collection("TravelPlan")
        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in
            
            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var travelPlans: [TravelPlan] = []

                for document in querySnapshot!.documents {
                    let data = document.data()

                    // Convert Firestore Timestamp to Date
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    // Create a TravelPlan object
                    let travelPlan = TravelPlan(
                        id: document.documentID,
                        planName: data["planName"] as? String ?? "",
                        destination: data["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        allSpots: data["allSpots"] as? [String] ?? []
                    )

                    travelPlans.append(travelPlan)
                    
                }

                completion(travelPlans, nil)
            }
        }
    }
    
    func fetchSpotsForDay(id: String, day: Int, completion: @escaping ([String]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanReference = db.collection("TravelPlan").document(id)

        // 取得特定天數的子集合參考
        let spotsCollectionReference = travelPlanReference.collection("SpotsPerDay").document("Day\(day)")

        // 從子集合中取得文件的快照
        spotsCollectionReference.getDocument { (document, error) in
            if let error = error {
                print("Error fetching spots: \(error)")
                completion(nil, error)
            } else {
                // 檢查文件是否存在
                if let document = document, document.exists {
                    // 讀取景點數據
                    let spotsData = document.data()?["spots"] as? [String] ?? []
                    completion(spotsData, nil)
                } else {
                    // 文件不存在
                    print("Spots document does not exist for Day\(day)")
                    completion(nil, nil) // 或者你可以使用一個錯誤來指示文件不存在
                }
            }
        }
    }
    
    func fetchAllSpotsForTravelPlan(id: String, completion: @escaping ([[String]]?, Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanReference = db.collection("TravelPlan").document(id)

        // 取得 spotsPerDay 子集合的參考
        let spotsPerDayCollectionReference = travelPlanReference.collection("SpotsPerDay")

        // 創建一個空陣列來保存所有天數的景點
        var allSpotsArray: [[String]] = []

        // 獲取所有文件的快照
        spotsPerDayCollectionReference.getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching spotsPerDay collection: \(error)")
                completion(nil, error)
            } else {
                // 檢查是否有文件
                guard let documents = querySnapshot?.documents else {
                    print("No documents in spotsPerDay collection")
                    completion(nil, nil)
                    return
                }

                // 遍歷每一個文件的快照，提取每一天的景點
                for document in documents {
                    let spotsData = document.data()["spots"] as? [String] ?? []
                    allSpotsArray.append(spotsData)
                    
                }
print("allspotsarray\(allSpotsArray)")
                // 返回包含所有天數景點的陣列
                completion(allSpotsArray, nil)
            }
        }
    }

    func fetchAllSpotsForTravelPlan(id: String, day: Int, completion: @escaping ([[String: Any]], Error?) -> Void) {
        let db = Firestore.firestore()
        let travelPlanReference = db.collection("TravelPlan").document(id)
        let spotsCollectionReference = travelPlanReference.collection("SpotsPerDay").document("Day\(day)").collection("SpotsForADay")

        // 查询所有文档
        spotsCollectionReference.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching spots: \(error)")
                completion([], error)
                return
            }

            // 遍历文档并提取数据
            for document in snapshot?.documents ?? [] {
                let data = document.data()
                self.allSpotsData.append(data)
                
            }

            completion(self.allSpotsData, nil)
        }
    }

}
