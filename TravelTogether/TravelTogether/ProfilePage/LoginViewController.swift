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

//@available(iOS 13.0, *)
//extension LoginViewController: ASAuthorizationControllerDelegate {
//
//  func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//    if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//      guard let nonce = currentNonce else {
//        fatalError("Invalid state: A login callback was received, but no login request was sent.")
//      }
//      guard let appleIDToken = appleIDCredential.identityToken else {
//        print("Unable to fetch identity token")
//        return
//      }
//      guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//        return
//      }
//      // Initialize a Firebase credential, including the user's full name.
//      let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
//                                                        rawNonce: nonce,
//                                                        fullName: appleIDCredential.fullName)
//        
//        print("user: \(appleIDCredential.user)")
//         print("fullName: \(appleIDCredential.fullName?.description ?? "N/A")")
//         print("Email: \(appleIDCredential.email ?? "N/A")")
//         print("realUserStatus: \(appleIDCredential.realUserStatus)")
//      // Sign in with Firebase.
//      Auth.auth().signIn(with: credential) { (authResult, error) in
//          if (error != nil) {
//          // Error. If error.code == .MissingOrInvalidNonce, make sure
//          // you're sending the SHA256-hashed nonce as a hex string with
//          // your request to Apple.
//              print(error?.localizedDescription)
//          return
//        }
//        // User is signed in to Firebase with Apple.
//        // ...
//      }
//    }
//  }
//
//  func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//    // Handle error.
//    print("Sign in with Apple errored: \(error)")
//  }
//
//}

//extension LoginViewController {
//    private func randomNonceString(length: Int = 32) -> String {
//        precondition(length > 0)
//        let charset: Array<Character> = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        var result = ""
//        var remainingLength = length
//
//        while(remainingLength > 0) {
//            let randoms: [UInt8] = (0 ..< 16).map { _ in
//                var random: UInt8 = 0
//                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//                if (errorCode != errSecSuccess) {
//                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//                }
//                return random
//            }
//
//            randoms.forEach { random in
//                if (remainingLength == 0) {
//                    return
//                }
//
//                if (random < charset.count) {
//                    result.append(charset[Int(random)])
//                    remainingLength -= 1
//                }
//            }
//        }
//        return result
//    }
//
//    private func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap {
//            return String(format: "%02x", $0)
//        }.joined()
//        return hashString
//    }
//}
//
//extension LoginViewController: ASAuthorizationControllerDelegate {
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        // 登入成功
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            
//            print("user: \(appleIDCredential.user)")
//           print("fullName: \(String(describing: appleIDCredential.fullName))")
//           print("Email: \(String(describing: appleIDCredential.email))")
//           print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
//            
//            guard let nonce = currentNonce else {
//                fatalError("Invalid state: A login callback was received, but no login request was sent.")
//            }
//            guard let appleIDToken = appleIDCredential.identityToken else {
//                CustomFunc.customAlert(title: "", message: "Unable to fetch identity token", vc: self, actionHandler: nil)
//                return
//            }
//            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                CustomFunc.customAlert(title: "", message: "Unable to serialize token string from data\n\(appleIDToken.debugDescription)", vc: self, actionHandler: nil)
//                return
//            }
//            // 產生 Apple ID 登入的 Credential
//            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
//            // 與 Firebase Auth 進行串接
//            firebaseSignInWithApple(credential: credential)
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        // 登入失敗，處理 Error
//        switch error {
//        case ASAuthorizationError.canceled:
//            CustomFunc.customAlert(title: "使用者取消登入", message: "", vc: self, actionHandler: nil)
//            break
//        case ASAuthorizationError.failed:
//            CustomFunc.customAlert(title: "授權請求失敗", message: "", vc: self, actionHandler: nil)
//            break
//        case ASAuthorizationError.invalidResponse:
//            CustomFunc.customAlert(title: "授權請求無回應", message: "", vc: self, actionHandler: nil)
//            break
//        case ASAuthorizationError.notHandled:
//            CustomFunc.customAlert(title: "授權請求未處理", message: "", vc: self, actionHandler: nil)
//            break
//        case ASAuthorizationError.unknown:
//            CustomFunc.customAlert(title: "授權失敗，原因不知", message: "", vc: self, actionHandler: nil)
//            break
//        default:
//            break
//        }
//    }
//}
//extension LoginViewController {
//    // MARK: - 透過 Credential 與 Firebase Auth 串接
//    func firebaseSignInWithApple(credential: AuthCredential) {
//        Auth.auth().signIn(with: credential) { authResult, error in
//            guard error == nil else {
//                CustomFunc.customAlert(title: "", message: "\(String(describing: error!.localizedDescription))", vc: self, actionHandler: nil)
//                return
//            }
//            CustomFunc.customAlert(title: "登入成功！", message: "", vc: self, actionHandler: self.getFirebaseUserInfo)
//            LoginViewController.loginStatus = true
//            self.dismiss(animated: true)
//        }
//    }
//    
//    // MARK: - Firebase 取得登入使用者的資訊
//    func getFirebaseUserInfo() {
//        let currentUser = Auth.auth().currentUser
//        guard let user = currentUser else {
//            CustomFunc.customAlert(title: "無法取得使用者資料！", message: "", vc: self, actionHandler: nil)
//            return
//        }
//        let uid = user.uid
//        let email = user.email
//        CustomFunc.customAlert(title: "使用者資訊", message: "UID：\(uid)\nEmail：\(email!)", vc: self, actionHandler: nil)
//       
//            let usersRef = self.database.collection("UserInfo").document(user.uid)
//            let userInfo = UserInfo(email: user.email ?? "", name: user.displayName ?? "User", id: user.uid, photo: user.photoURL?.absoluteString)
//            let usersData = userInfo.toDictionary()
//            usersRef.setData(usersData, merge: true)
//        
//        
//    }
//}
//class CustomFunc {
//    static func customAlert(title: String, message: String, vc: UIViewController, actionHandler: (() -> Void)?) {
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//
//        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
//            // Perform any action specified in the handler
//            actionHandler?()
//        }
//
//        alertController.addAction(okAction)
//
//        // Present the alert
//        vc.present(alertController, animated: true, completion: nil)
//    }
//}
