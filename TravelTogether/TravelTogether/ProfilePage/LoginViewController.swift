//
//  LoginViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/7.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    static var loginStatus = false
    var database = Firestore.firestore()
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var emailLabel: UILabel! {
        didSet {
            emailLabel.layer.cornerRadius = 8
            emailLabel.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var passwordLabel: UILabel! {
        didSet {
            passwordLabel.layer.cornerRadius = 8
            passwordLabel.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
            nameLabel.layer.cornerRadius = 8
            nameLabel.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.layer.cornerRadius = 8
        }
    }
    @IBOutlet weak var closeButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // 將使用者進入畫面預設成select log-in
        segmentedControl.selectedSegmentIndex = 0
        nameLabel.isEnabled = false
        nameTextField.isEnabled = false
        nameLabel.textColor = UIColor.lightGray
        nameTextField.backgroundColor = UIColor(named: "lightGreen")


        // 設置選項的字體大小
        let font = UIFont.systemFont(ofSize: 16) // 調整這裡的大小
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 500,
                            width: UIScreen.main.bounds.width, height: 500 )
    }
    
    @IBAction func changeMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // select log-in: 無法輸入、灰字、灰框
            nameLabel.isEnabled = false
            nameTextField.isEnabled = false
            nameLabel.textColor = UIColor.lightGray
            nameTextField.backgroundColor = UIColor(named: "lightGreen")
        } else {
            // select sign-up: 可輸入
            nameLabel.isEnabled = true
            nameTextField.isEnabled = true
            nameLabel.textColor = UIColor.black
            nameTextField.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        
        let emailText = emailTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        let nameText = nameTextField.text ?? ""
        
        // select log-in
        if segmentedControl.selectedSegmentIndex == 0 {
            Auth.auth().signIn(withEmail: emailText, password: passwordText) { result, error in
                guard error == nil else {
                    self.showAlert(title: "Error", message: "登入失敗")
                      return
                   }
                self.showAlert(title: "Success", message: "登入成功!")
                LoginViewController.loginStatus = true
        }
            
            // select sign-up
        } else {
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
                if error != nil {
                    print("Failed to resgister")
                    self.showAlert(title: "Error", message: "Email格式錯誤 或 密碼不足6位")
                } else {
                    // select sign-up: email未輸入
                    if emailText.isEmpty {
                        self.showAlert(title: "Error", message: "Email不可為空")
                        
                        // select sign-up: password未輸入
                    } else if passwordText.isEmpty {
                        self.showAlert(title: "Error", message: "密碼不可為空")
                        
                        // select sign-up: name未輸入
                    } else if nameText.isEmpty {
                        self.showAlert(title: "Error", message: "請輸入暱稱")
                        
                    } else {
                        self.showAlert(title: "Success", message: "註冊成功！請輸入帳號資訊以登入。")
                        self.addData()
                    }
                }}}
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            if title == "Success" {
                self?.dismiss(animated: true)
            }
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
    func addData() {
        
        guard let emailText = emailTextField.text, !emailText.isEmpty else {
                print("Title is empty")
                return
            }
        guard let nameText = nameTextField.text else {
            print("Name is empty")
            return
        }
        
        let usersRef = database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
        
        let users = UserInfo(email: emailText, name: nameText, id: Auth.auth().currentUser?.uid ?? "")
       
        let usersData = users.toDictionary()
        
        usersRef.setData(usersData)
       }
    
}
