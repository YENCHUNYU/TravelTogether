//
//  AppDelegate.swift
//  TravelTogether
//
//  Created by User on 2023/11/12.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseDynamicLinks

let googleApiKey = "AIzaSyCiR-wZWz3f4L4OtxMGLcCTlt4mpc7oz6I"

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey(googleApiKey)
        GMSPlacesClient.provideAPIKey(googleApiKey)
        FirebaseApp.configure()
//        if let url = launchOptions?[.url] as? URL {
//            handleDynamicLink(url)
//        }
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: URL(string: "https://traveltogether.page.link/test1")!) {
                    handleDynamicLink(dynamicLink)
                }
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // 处理 Google Sign-In 的 URL
        let handledGoogleSignInURL = GIDSignIn.sharedInstance.handle(url)
        if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
                    handleDynamicLink(dynamicLink)
                    return true
                }
        // 返回 Google Sign-In 处理结果
        return handledGoogleSignInURL
    }
    
    var window: UIWindow?
    
    func handleDynamicLink(_ dynamicLink: DynamicLink) {
            if let url = dynamicLink.url {
                // Parse the URL and extract any parameters if needed
                // For example, you can use URLComponents to get query items
                let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
                // Extract and handle parameters here

                // Navigate to the specific ViewController
                if let viewController = getSpecificViewController() {
                    window?.rootViewController = viewController
                }
            }
        }

        func getSpecificViewController() -> UIViewController? {
            // Implement logic to return the specific ViewController you want to navigate to
            // For example, if using storyboards, you can instantiate it by its identifier
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let specificViewController = storyboard.instantiateViewController(withIdentifier: "EditPlanViewController")
            return specificViewController
        }
    
}
