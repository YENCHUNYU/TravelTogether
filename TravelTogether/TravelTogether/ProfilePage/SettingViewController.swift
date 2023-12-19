//
//  SettingViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/11.
//

import UIKit
import FirebaseAuth
import AuthenticationServices
import CryptoKit

class SettingViewController: UIViewController, ASAuthorizationControllerDelegate {
//    fileprivate var currentNonce: String?
    var signOutButtonTap: (() -> Void)?
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setTitle("", for: .normal)
        }
    }
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
               self.showAlert(title: "登出帳戶", message: "確定要登出帳戶？", completion: {
                   LoginViewController.loginStatus = false
                   self.showAlert(title: "Success", message: "已登出帳戶", completion: {
                       try? firebaseAuth.signOut()
                       self.dismiss(animated: true)
                       self.signOutButtonTap?()
                   })
               })
           } catch let signOutError as NSError {
               print("Error signing out", signOutError)
           }
       }
    
    @IBAction func deleteAccountButtonTapped(_ sender: Any) {
        let user = Auth.auth().currentUser
        self.showAlert(title: "刪除帳戶", message: "確定要刪除帳戶？", completion: {
            LoginViewController.loginStatus = false
            self.showAlert(title: "Success", message: "已刪除帳戶", completion: {
                
                user?.delete { error in
                    if let error = error {
                        print("error.")
                    } else {
                        print("Account deleted.")
                        LoginViewController.loginStatus = false
//                        try? Auth.auth().signOut()
                    }
                }
                self.dismiss(animated: true)
                self.signOutButtonTap?()
            })
        })
        
    }
    
    @IBAction func contactButtonTapped(_ sender: Any) {
        self.showAlert(title: "開發者聯絡資訊", message: "請寄送郵件至此開發者電子信箱：jenny98417rib@gmail.com，謝謝！")
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let okAction = UIAlertAction(title: "確定", style: .default) { [weak self] action in
            completion?()
        }
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
}
