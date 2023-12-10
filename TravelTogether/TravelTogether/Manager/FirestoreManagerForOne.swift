//
//  FirestoreManagerForOne.swift
//  TravelTogether
//
//  Created by User on 2023/11/22.
//

import UIKit
import FirebaseFirestore

protocol FirestoreManagerForOneDelegate: AnyObject {
    func manager(_ manager: FirestoreManagerForOne, didGet firestoreData: TravelPlan)
}

class FirestoreManagerForOne {
    
    var delegate: FirestoreManagerForOneDelegate?
    
    func fetchOneTravelPlan(userId: String, byId planId: String, completion: @escaping (TravelPlan?, Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(userId).collection("TravelPlan").document(planId)

        travelPlanRef.addSnapshotListener { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, error)
            } else {
                do {
                    guard let document = document, document.exists else {
                        completion(nil, nil)
                        return
                    }

                    let data = document.data()
                    let startDate = (data?["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data?["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    guard let daysArray = data?["days"] as? [[String: Any]] else {
                        return
                    }

                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                    
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            return
                        }

                        var locations: [Location] = []
                        for locationData in locationsArray {
                            let location = Location(
                                name: locationData["name"] as? String ?? "",
                                photo: locationData["photo"] as? String ?? "",
                                address: locationData["address"] as? String ?? "",
                                user: locationData["user"] as? String ?? ""
                            )
                            locations.append(location)
                        }

                        let travelDay = TravelDay(locations: locations)
                        travelDays.append(travelDay)
                    }
                    
                    let travelPlan = TravelPlan(
                        id: document.documentID,
                        planName: data?["planName"] as? String ?? "",
                        destination: data?["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
                    )
                    completion(travelPlan, nil)
                    self.delegate?.manager(self, didGet: travelPlan)
                }
            }
        }
    }
    
    func fetchOneTravelPlanFromFavorite(userId: String, byId planId: String, completion: @escaping (TravelPlan?, Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(userId).collection("FavoritePlan").document(planId)

        travelPlanRef.addSnapshotListener { document, error in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil, error)
            } else {
                do {
                    guard let document = document, document.exists else {
                        completion(nil, nil)
                        return
                    }

                    let data = document.data()
                    let startDate = (data?["startDate"] as? Timestamp)?.dateValue() ?? Date()
                    let endDate = (data?["endDate"] as? Timestamp)?.dateValue() ?? Date()

                    guard let daysArray = data?["days"] as? [[String: Any]] else {
                        return
                    }

                    var travelDays: [TravelDay] = []
                    for dayData in daysArray {
                    
                        guard let locationsArray = dayData["locations"] as? [[String: Any]] else {
                            return
                        }

                        var locations: [Location] = []
                        for locationData in locationsArray {
                            let location = Location(
                                name: locationData["name"] as? String ?? "",
                                photo: locationData["photo"] as? String ?? "",
                                address: locationData["address"] as? String ?? "",
                                user: locationData["user"] as? String ?? ""
                            )
                            locations.append(location)
                        }

                        let travelDay = TravelDay(locations: locations)
                        travelDays.append(travelDay)
                    }
                    
                    let travelPlan = TravelPlan(
                        id: document.documentID,
                        planName: data?["planName"] as? String ?? "",
                        destination: data?["destination"] as? String ?? "",
                        startDate: startDate,
                        endDate: endDate,
                        days: travelDays
                    )
                    completion(travelPlan, nil)
                    self.delegate?.manager(self, didGet: travelPlan)
                }
            }
        }
    }
}

extension FirestoreManagerForOne {

    func deleteLocationFromTravelPlan(
        travelPlanId: String, dayIndex: Int, location: Location,
        userId: String, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(userId).collection("TravelPlan").document(travelPlanId)

        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for deletion: \(error)")
                completion(error)
            } else {
                do {
                    guard var travelPlanData = document?.data() else {
                        completion(nil)
                        return
                    }
                    
                    guard var daysArray = travelPlanData["days"] as? [[String: Any]] else {
                        completion(nil)
                        return
                    }
                    
                    guard var locationsArray = daysArray[dayIndex]["locations"] as? [[String: Any]] else {
                        completion(nil)
                        return
                    }
                    
                    // Find and remove the location from the locations array
                    locationsArray.removeAll { (locationData) -> Bool in
                        let name = locationData["name"] as? String ?? ""
                        return name == location.name
                    }
                    
                    // Update the locations array in the days array
                    daysArray[dayIndex]["locations"] = locationsArray
                    travelPlanData["days"] = daysArray
                 
                        // Update the document in Firestore
                        travelPlanRef.setData(travelPlanData, merge: true) { error in
//                            DispatchQueue.main.async {
                                if let error = error {
                                    print("Error updating document after deletion: \(error)")
                                    completion(error)
                                } else {
                                    print("Document updated successfully after deletion.")
                                    completion(nil)
//                                }
                            }}
                    }
            }
        }
    }
}

extension FirestoreManagerForOne {
    func deleteDayFromTravelPlan(userId: String, travelPlanId: String, dayIndex: Int, completion: @escaping (Error?) -> Void) {
        let database = Firestore.firestore()
        let travelPlanRef = database.collection("UserInfo").document(userId).collection("TravelPlan").document(travelPlanId)

        travelPlanRef.getDocument { document, error in
            if let error = error {
                print("Error getting document for deletion: \(error)")
                completion(error)
            } else {
                do {
                    guard var travelPlanData = document?.data() else {
                        completion(nil)
                        return
                    }

                    guard var daysArray = travelPlanData["days"] as? [[String: Any]] else {
                        completion(nil)
                        return
                    }

                    daysArray.remove(at: dayIndex)
                    travelPlanData["days"] = daysArray

                    travelPlanRef.setData(travelPlanData, merge: true) { error in
//                        DispatchQueue.main.async {
                            if let error = error {
                                print("Error updating document after deletion: \(error)")
                                completion(error)
                            } else {
                                print("Document updated successfully after deletion.")
                                completion(nil)
//                            }
                        }}
                }
            }
        }
    }
}
