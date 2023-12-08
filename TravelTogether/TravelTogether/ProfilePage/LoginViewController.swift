//
//  LoginViewController.swift
//  TravelTogether
//
//  Created by User on 2023/12/7.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import FirebaseCore
import FirebaseStorage

class LoginViewController: UIViewController {
    static var loginStatus = false
    var database = Firestore.firestore()
    let user = Auth.auth().currentUser
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
    
    @IBOutlet weak var googleSigninButton: GIDSignInButton! {
        didSet {
            googleSigninButton.layer.cornerRadius = 8

            let googleIconImageView = UIImageView(image: UIImage(named: "google"))
            googleIconImageView.contentMode = .scaleAspectFill
            googleSigninButton.addSubview(googleIconImageView)

            googleIconImageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                googleIconImageView.centerYAnchor.constraint(equalTo: googleSigninButton.centerYAnchor),
                googleIconImageView.leadingAnchor.constraint(equalTo: googleSigninButton.leadingAnchor, constant: 35),
                googleIconImageView.widthAnchor.constraint(equalToConstant: 28),
                googleIconImageView.heightAnchor.constraint(equalToConstant: 28) 
            ])
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 將使用者進入畫面預設成select log-in
        segmentedControl.selectedSegmentIndex = 0
        nameLabel.isEnabled = false
        nameTextField.isEnabled = false
        nameLabel.textColor = UIColor.lightGray
        nameTextField.backgroundColor = UIColor(named: "lightGreen")

        let font = UIFont.systemFont(ofSize: 16)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        
       guard let clientID = FirebaseApp.app()?.options.clientID else { return }
       let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 25
        view.layer.masksToBounds = true
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 600,
                            width: UIScreen.main.bounds.width, height: 600 )
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
    
    @IBAction func googleSigninButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
        guard error == nil else {
            self.showAlert(title: "Error", message: "登入失敗。")
            return
        }

        guard let user = result?.user,
            let idToken = user.idToken?.tokenString
        else {
            self.showAlert(title: "Error", message: "登入失敗，請改由其他方式登入。")
            return
        }

        let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: user.accessToken.tokenString)

        // Use the Google Sign-In credential for Firebase authentication
        self.signInWithFirebase(credential)
                }
    }
    
    func signInWithFirebase(_ credential: AuthCredential) {

        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                self.showAlert(title: "Error", message: "登入失敗，請改由其他方式登入。")
                print("Firebase sign-in error: \(error.localizedDescription)")
                return
            }
            
            self.showAlert(title: "Success", message: "登入成功！")
            print("User signed in with Firebase")
            LoginViewController.loginStatus = true
            
            //              let usersRef = self.database.collection("UserInfo").document(Auth.auth().currentUser?.uid ?? "")
            //              if let user = self.user {
            //                  let userInfo = UserInfo(email: user.email ?? "", name: user.displayName ?? "", id: user.uid, photo: user.photoURL?.absoluteString)
            //                  let usersData = userInfo.toDictionary()
            //                  usersRef.setData(usersData)
            //              }
            
            
            
            if let user = authResult?.user {
                let usersRef = self.database.collection("UserInfo").document(user.uid)
                let userInfo = UserInfo(email: user.email ?? "", name: user.displayName ?? "", id: user.uid, photo: user.photoURL?.absoluteString)
                let usersData = userInfo.toDictionary()
                usersRef.setData(usersData)
            }}

                  // The rest of your code
              
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
//                self.dismiss(animated: true)
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
                        self.showAlert(title: "Success", message: "註冊成功！請前往登入畫面並輸入登入資訊。")
                        self.addData()
                    }
                }}}
    }

    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
            if title == "Success" {
//                LoginViewController.loginStatus = true
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
