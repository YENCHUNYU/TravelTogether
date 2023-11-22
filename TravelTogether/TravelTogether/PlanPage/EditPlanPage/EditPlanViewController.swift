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
//    var plans: [TravelPlan] = [TravelPlan(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), allSpots: [])]
    var plans: [TravelPlan2] = [TravelPlan2(id: "", planName: "", destination: "", startDate: Date(), endDate: Date(), days: [])]
    var travelPlanIndex = 0
    var planSpots: [String] = []
    var travelPlanId = ""
    var spotsData: [[String: Any]] = []
    
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

        
//        fetchAllSpotsForTravelPlan(id: travelPlanId, day: 1) { spots, error in
//            if let error = error {
//                print("Error fetching spots for Day 1: \(error)")
//            } else {
//                    print("Spots for Day 1: \(spots)")
//                self.spotsData = spots
//              //  self.tableView.reloadData()
//            }
//        }
        
        // Example usage
        fetchTravelPlans() { (travelPlan, error) in
            if let error = error {
                print("Error fetching travel plan: \(error)")
            } else if let travelPlan = travelPlan {
                print("Fetched travel plan: \(travelPlan)")
                self.plans = travelPlan
            } else {
                print("Travel plan not found.")
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
//        fetchAllSpotsForTravelPlan(id: travelPlanId, day: 1) { spots, error in
//            if let error = error {
//                print("Error fetching spots for Day 1: \(error)")
//            } else {
//                    print("Spots for Day 1: \(spots)")
//                self.spotsData = spots
//                self.tableView.reloadData()
//            }
//        }
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
        spotsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPlanCell", for: indexPath) as? EditPlanCell
            else { fatalError("Could not create EditPlanCell") }
    
     //   let spotData = spotsData[indexPath.row]
        let dayData = plans[indexPath.row].days[0]
//        if let name = dayData["locations"] as? String {
//                    cell.placeNameLabel.text = name
//                }
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
    
//    func fetchTravelPlans(completion: @escaping ([TravelPlan]?, Error?) -> Void) {
//        let db = Firestore.firestore()
//
//        let travelPlansRef = db.collection("TravelPlan")
//        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
//        orderedQuery.getDocuments { (querySnapshot, error) in
//
//            if let error = error {
//                print("Error getting documents: \(error)")
//                completion(nil, error)
//            } else {
//                var travelPlans: [TravelPlan] = []
//
//                for document in querySnapshot!.documents {
//                    let data = document.data()
//
//                    // Convert Firestore Timestamp to Date
//                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
//                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()
//
//                    // Create a TravelPlan object
//                    let travelPlan = TravelPlan(
//                        id: document.documentID,
//                        planName: data["planName"] as? String ?? "",
//                        destination: data["destination"] as? String ?? "",
//                        startDate: startDate,
//                        endDate: endDate,
//                        allSpots: data["allSpots"] as? [String] ?? []
//                    )
//
//                    travelPlans.append(travelPlan)
//
//                }
//
//                completion(travelPlans, nil)
//            }
//        }
//    }
    
    func fetchTravelPlans(completion: @escaping ([TravelPlan2]?, Error?) -> Void) {
        let db = Firestore.firestore()

        let travelPlansRef = db.collection("TravelPlan")
        let orderedQuery = travelPlansRef.order(by: "startDate", descending: false)
        orderedQuery.getDocuments { (querySnapshot, error) in

            if let error = error {
                print("Error getting documents: \(error)")
                completion(nil, error)
            } else {
                var travelPlans: [TravelPlan2] = []

                for document in querySnapshot!.documents {
                    let data = document.data()

                    // Convert Firestore Timestamp to Date
                    let startDate = (data["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    // Retrieve the "days" array
                    guard let daysArray = data["days"] as? [[String: Any]] else {
                        continue // Skip this document if "days" is not an array
                    }

                    // Convert each day data to a TravelDay object
                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                        let dayDate = (dayData["date"] as? Timestamp)?.dateValue() ?? Date()
                        
                        // Retrieve the "locations" array for each day
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            continue // Skip this day if "locations" is not an array
                        }

                        // Convert each location data to a Location object
                        var locations: [Location] = []
                        for locationData in locationsArray {
                            let location = Location(
                                name: locationData["name"] as? String ?? "",
                                photo: locationData["photo"] as? String ?? "",
                                address: locationData["address"] as? String ?? ""
                            )
                            locations.append(location)
                        }

                        // Create a TravelDay object
                        let travelDay = TravelDay(date: dayDate, locations: locations)
                        travelDays.append(travelDay)
                    }

                    // Create a TravelPlan object
                    let travelPlan = TravelPlan2(
                        id: document.documentID,
                        planName: data["planName"] as? String ?? "",
                        destination: data["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
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
        var allSpotsData: [[String: Any]] = []  // Ensure it's a local variable
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
                allSpotsData.append(data)
                
            }

            completion(allSpotsData, nil)
        }
    }

//
//    func fetchTravelPlan(documentId: String, completion: @escaping (TravelPlan?, Error?) -> Void) {
//        let db = Firestore.firestore()
//        let travelPlansRef = db.collection("TravelPlan").document(documentId)
//
//        travelPlansRef.getDocument { document, error in
//            if let error = error {
//                completion(nil, error)
//                return
//            }
//
//            do {
//                if let document = document, document.exists {
//                    var travelPlan = try document.data(as: TravelPlan.self)
//
//                    // Convert Firestore Timestamps to Swift Dates
//                    travelPlan?.startDate = document["startDate"] as? Timestamp ?? Timestamp().dateValue()
//                    travelPlan?.endDate = document["endDate"] as? Timestamp ?? Timestamp().dateValue()
//
//                    completion(travelPlan, nil)
//                } else {
//                    completion(nil, nil) // Document doesn't exist
//                }
//            } catch {
//                completion(nil, error)
//            }
//        }
//    }


    

    
}
