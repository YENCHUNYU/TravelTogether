//
//  SettingViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/11.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    
    @IBOutlet weak var manageAccountLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton! {
        didSet {
            signOutButton.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var deleteAccountButton: UIButton! {
        didSet {
            deleteAccountButton.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet weak var contactDeveloperButton: UIButton! {
        didSet {
            contactDeveloperButton.layer.cornerRadius = 8
        }
    }
    
    
    @IBAction func signOutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            LoginViewController.loginStatus = false
            self.showAlert(title: "Success", message: "已登出帳戶")
        } catch let signOutError as NSError {
          print("Error signing out", signOutError)
        }
    }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
    }

    @IBAction func contactButtonTapped(_ sender: Any) {
        self.showAlert(title: "開發者聯絡資訊", message: "請以此電子信箱聯繫開發者：jenny98417rib@gmail.com")
    }
       
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 500,
                            width: UIScreen.main.bounds.width, height: 500 )
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
           
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
}
