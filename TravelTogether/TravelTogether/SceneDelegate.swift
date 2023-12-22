//
//  SceneDelegate.swift
//  TravelTogether
//
//  Created by User on 2023/11/12.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let url = connectionOptions.urlContexts.first?.url else {
               return
           }

        handleTravelTogetherLink(url: url)
        }
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else {
            return
        }

        handleTravelTogetherLink(url: url)
    }
 
    func handleTravelTogetherLink(url: URL) {
        guard let scheme = url.scheme else {
            // Invalid URL
            return
        }
        
        if scheme == "traveltogether" {
            // Extract user ID and plan ID from the URL path host: userId
            let pathComponents = url.pathComponents
            guard pathComponents.count == 4, pathComponents[2] == "planId" else {
                // Invalid path structure
                print("pathComponents.count00\(url.absoluteString)")
                print("pathComponents.count\(pathComponents.count)")
                return
            }
            
            let userId = pathComponents[1]
            let planId = pathComponents[3]

            print("User ID: \(userId), Plan ID: \(planId)")
            if let tabBarController = window?.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 2
                if tabBarController.selectedIndex < tabBarController.viewControllers?.count ?? 0 {
                    if let selectedViewController = tabBarController.viewControllers?[tabBarController.selectedIndex] as? UINavigationController {
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        if let editVC = storyboard.instantiateViewController(withIdentifier: "EditPlanViewController") as? EditPlanViewController {
                            editVC.userId = userId
                            editVC.travelPlanId = planId
                            editVC.url = url.absoluteString
                            selectedViewController.pushViewController(editVC, animated: true)
                        }
                    }
                }
            }}
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
