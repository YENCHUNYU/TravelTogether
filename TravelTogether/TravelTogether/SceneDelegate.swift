//
//  SceneDelegate.swift
//  TravelTogether
//
//  Created by User on 2023/11/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
//
//    func scene(_ scene: UIScene,
//               willConnectTo session: UISceneSession,
//               options connectionOptions: UIScene.ConnectionOptions) {
//        // Use this method to optionally configure and attach the UIWindow `window`
//        // to the provided UIWindowScene `scene`.
//        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
//        // This delegate does not imply the connecting scene
//        // or session are new (see `application:configurationForConnectingSceneSession` instead).
//        guard let _ = (scene as? UIWindowScene) else { return }
//    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
            guard let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity else {
                return
            }

            if let incomingURL = userActivity.webpageURL {
                // Handle Dynamic Link URL
                handleDynamicLink(url: incomingURL)
            }
            
            // Your existing code for setting up the scene...
        }

//        func handleDynamicLink(url: URL) {
//            // Parse the Dynamic Link URL and extract necessary information
//            // For example, you might extract a parameter that indicates the target tab index
//
//            // Assuming you have a parameter named "tabIndex" in the Dynamic Link
////            if let tabIndexString = url.valueOf("tabIndex"), let tabIndex = Int(tabIndexString) {
//                // Assuming your root view controller is a TabBarController
//                if let tabBarController = window?.rootViewController as? UITabBarController {
//                    // Assuming index 2 corresponds to the desired tab
//                    tabBarController.selectedIndex = 2
//                   
//                   
//                    }
//                    
//                }
//            }
//    
    func handleDynamicLink(url: URL) {
        var userIdLink = ""
        var planIdLink = ""
        // Parse the Dynamic Link URL and extract necessary information
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            
            for queryItem in queryItems {
                let name = queryItem.name
                     let value = queryItem.value
                    print("Parameter: \(name), Value: \(value)")
                    
                    // 在這裡你可以使用獲取到的參數進行相應的處理
                    if name == "userId" {
                        let userId = value
                        userIdLink = value ?? ""
                        // 保存userId到合適的地方，以便稍後在目標ViewController中使用
                        UserDefaults.standard.set(userId, forKey: "userId")
                    } else if name == "planId" {
                        let planId = value
                        planIdLink = value ?? ""
                        // 保存planId到合適的地方，以便稍後在目標ViewController中使用
                        UserDefaults.standard.set(planId, forKey: "planId")
                    }
                    
                    // 繼續處理其他參數...
                }
//            }
        }
        
        // Assuming your root view controller is a TabBarController
        if let tabBarController = window?.rootViewController as? UITabBarController {
            // Assuming index 2 corresponds to the desired tab
            tabBarController.selectedIndex = 2
            
            // Check if the index is within bounds
            if tabBarController.selectedIndex < tabBarController.viewControllers?.count ?? 0 {
                // Access the view controller at the specified index
                if let selectedViewController = tabBarController.viewControllers?[tabBarController.selectedIndex] as? UINavigationController {
                    // Set properties or perform actions on the selected view controller
                    
//                    let vc = ViewController()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let editVC = storyboard.instantiateViewController(withIdentifier: "EditPlanViewController") as? EditPlanViewController {
                        // Set properties
                        editVC.userId = userIdLink
                        editVC.travelPlanId = planIdLink

                        // Push the view controller onto the navigation stack
                        selectedViewController.pushViewController(editVC, animated: true)
                    }

//                    let editVC = EditPlanViewController()
//
////                    editVC.userId = userIdLink
////                    editVC.travelPlanId = planIdLink
//                    selectedViewController.pushViewController(editVC, animated: true)
////                    planVC.linkToEdit()
                }
            }
        }

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded
        // (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        view.backgroundColor = .black
    }
}
