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
import AuthenticationServices
import CryptoKit

class LoginViewController: UIViewController {
    static var loginStatus = false
    var database = Firestore.firestore()
    let user = Auth.auth().currentUser
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
    
    @IBOutlet weak var stackView: UIStackView!
    
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
        
        @IBOutlet weak var appleSigninButton: ASAuthorizationAppleIDButton!  {
            didSet {
                appleSigninButton.layer.cornerRadius = 8
                
                let appleIconImageView = UIImageView(image: UIImage(named: "apple"))
                appleIconImageView.contentMode = .scaleAspectFill
                appleSigninButton.addSubview(appleIconImageView)
                
                appleIconImageView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    appleIconImageView.centerYAnchor.constraint(equalTo: appleSigninButton.centerYAnchor),
                    appleIconImageView.leadingAnchor.constraint(equalTo: appleSigninButton.leadingAnchor, constant: 35),
                    appleIconImageView.widthAnchor.constraint(equalToConstant: 28),
                    appleIconImageView.heightAnchor.constraint(equalToConstant: 28)
                ])
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 將使用者進入畫面預設成select log-in
        segmentedControl.selectedSegmentIndex = 0
        stackView.isHidden = true
        doneButton.isHidden = true
        
//        nameLabel.isEnabled = false
//        nameTextField.isEnabled = false
//        nameLabel.textColor = UIColor.lightGray
//        nameTextField.backgroundColor = UIColor(named: "lightGreen")

        let font = UIFont.systemFont(ofSize: 16, weight: .light)
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
        view.frame = CGRect(x: 0, y: (UIScreen.main.bounds.height) - 800,
                            width: UIScreen.main.bounds.width, height: 800 )
    }
    
    @IBAction func changeMode(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            appleSigninButton.isHidden = false
            googleSigninButton.isHidden = false
            stackView.isHidden = true
            doneButton.isHidden = true
        } else if sender.selectedSegmentIndex == 1 {
            appleSigninButton.isHidden = true
            googleSigninButton.isHidden = true
            stackView.isHidden = false
            doneButton.isHidden = false
            // select log-in: 無法輸入、灰字、灰框
            nameLabel.isEnabled = false
            nameTextField.isEnabled = false
            nameLabel.textColor = UIColor.lightGray
            nameTextField.backgroundColor = UIColor(named: "lightGreen")
        } else {
            appleSigninButton.isHidden = true
            googleSigninButton.isHidden = true
            // select sign-up: 可輸入
            stackView.isHidden = false
            doneButton.isHidden = false
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

        self.signInWithFirebase(credential)
                }
    }
    
    @IBAction func appleSigninButtonTapped(_ sender: Any) {
        startSignInWithAppleFlow()
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
            
            if let user = authResult?.user {
                let usersRef = self.database.collection("UserInfo").document(user.uid)
                let userInfo = UserInfo(email: user.email ?? "", name: user.displayName ?? "User", id: user.uid, photo: user.photoURL?.absoluteString)
                let usersData = userInfo.toDictionary()
                usersRef.setData(usersData, merge: true)
            }}
      }

    @IBAction func doneButtonTapped(_ sender: Any) {
        
        let emailText = emailTextField.text ?? ""
        let passwordText = passwordTextField.text ?? ""
        let nameText = nameTextField.text ?? ""
        
        // select log-in
        if segmentedControl.selectedSegmentIndex == 1 {
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
//                        self.showAlert(title: "Success", message: "註冊成功！請前往登入畫面並輸入登入資訊。")
                        self.addData()
                        Auth.auth().signIn(withEmail: emailText, password: passwordText) { result, error in
                            guard error == nil else {
                                self.showAlert(title: "Error", message: "登入失敗")
                                  return
                               }
                            self.showAlert(title: "Success", message: "註冊並登入成功!")
                            LoginViewController.loginStatus = true
            //                self.dismiss(animated: true)
                    }
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

//extension LoginViewController {
//    private func randomNonceString(length: Int = 32) -> String {
//      precondition(length > 0)
//      var randomBytes = [UInt8](repeating: 0, count: length)
//      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
//      if errorCode != errSecSuccess {
//        fatalError(
//          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
//        )
//      }
//
//      let charset: [Character] =
//        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//
//      let nonce = randomBytes.map { byte in
//        // Pick a random character from the set, wrapping around if needed.
//        charset[Int(byte) % charset.count]
//      }
//
//      return String(nonce)
//    }
//    
//    @available(iOS 13, *)
//    private func sha256(_ input: String) -> String {
//      let inputData = Data(input.utf8)
//      let hashedData = SHA256.hash(data: inputData)
//      let hashString = hashedData.compactMap {
//        String(format: "%02x", $0)
//      }.joined()
//
//      return hashString
//    }
//
//    @available(iOS 13, *)
//    func startSignInWithAppleFlow() {
//      let nonce = randomNonceString()
//      currentNonce = nonce
//      let appleIDProvider = ASAuthorizationAppleIDProvider()
//      let request = appleIDProvider.createRequest()
//      request.requestedScopes = [.fullName, .email]
//      request.nonce = sha256(nonce)
//
//      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//      authorizationController.delegate = self
//      authorizationController.presentationContextProvider = self
//      authorizationController.performRequests()
//    }
//}
extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
        
    /// - Parameter controller: _
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}

@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate {

  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
      if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
          guard let nonce = currentNonce else {
              fatalError("Invalid state: A login callback was received, but no login request was sent.")
          }
          guard let appleIDToken = appleIDCredential.identityToken else {
              print("Unable to fetch identity token")
              return
          }
          guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
              print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
              return
          }

          // Initialize a Firebase credential, including the user's full name.
          let credential = OAuthProvider.appleCredential(
              withIDToken: idTokenString,
              rawNonce: nonce,
              fullName: appleIDCredential.fullName
          )

          print("user: \(appleIDCredential.user)")
          print("fullName: \(appleIDCredential.fullName?.description ?? "N/A")")
          print("Email: \(appleIDCredential.email ?? "N/A")")
          print("realUserStatus: \(appleIDCredential.realUserStatus)")

          Auth.auth().signIn(with: credential) { authResult, error in
              if let error = error {
                  self.showAlert(title: "Error", message: "登入失敗。")
                  print("Firebase sign-in error: \(error.localizedDescription)")
                  return
              }

              self.showAlert(title: "Success", message: "登入成功！")
              print("User signed in with Firebase")
              LoginViewController.loginStatus = true

              if let user = authResult?.user {
                  let usersRef = self.database.collection("UserInfo").document(user.uid)
                  let userInfo = UserInfo(
                    email: user.email ?? "",
                    name: appleIDCredential.fullName?.givenName ?? "",
                      id: user.uid,
                      photo: user.photoURL?.absoluteString
                  )
                  let usersData = userInfo.toDictionary()
                  usersRef.setData(usersData)
              }
          }
      }

  }
   
        func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
            // 登入失敗，處理 Error
            switch error {
            case ASAuthorizationError.canceled:
                showAlert(title: "使用者取消登入", message: "")
            case ASAuthorizationError.failed:
                showAlert(title: "授權請求失敗", message: "")
            case ASAuthorizationError.invalidResponse:
                showAlert(title: "授權請求無回應", message: "")
            case ASAuthorizationError.notHandled:
                showAlert(title: "授權請求未處理", message: "")
            case ASAuthorizationError.unknown:
                showAlert(title: "授權失敗，原因不明", message: "")
            default:
                break
            }
        }

    func reauth(id appleIdToken: String, raw rawNonce: String) {
        // Initialize a fresh Apple credential with Firebase.
        let credential = OAuthProvider.credential(
          withProviderID: "apple.com",
          idToken: appleIdToken,
          rawNonce: rawNonce
        )
        // Reauthenticate current Apple user with fresh Apple credential.
        Auth.auth().currentUser?.reauthenticate(with: credential) { (authResult, error) in
          guard error != nil else { return }
          // Apple user successfully re-authenticated.
          // ...
        }
    }
    
}
extension LoginViewController {
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
}
