//
//  PlanViewModel.swift
//  TravelTogether
//
//  Created by User on 2023/12/25.
//

import UIKit
import FirebaseAuth

class PlanViewModel {
    var plans: [TravelPlan] = []
    var togetherPlans: [TravelPlan] = []

//    func fetchMyPlans(userId: String, completion: @escaping (Error?) -> Void) {
//        Task {
//            do {
//                let firestoreManager = FirestoreManager()
//                plans = try await firestoreManager.fetchMyTravelPlans(userId: userId)
//                // 在 UI 线程上调用 completion
//                DispatchQueue.main.async {
//                    completion(nil)
//                }
//            } catch {
//                print("Error fetching travel plans: \(error)")
//                // 在 UI 线程上调用 completion
//                DispatchQueue.main.async {
//                    completion(error)
//                }
//            }
//        }
//    }
}
