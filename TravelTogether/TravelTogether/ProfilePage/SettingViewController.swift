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
    fileprivate var currentNonce: String?
    @IBOutlet weak var closeButton: UIButton!
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
        deleteCurrentUser()
    }

    @IBAction func contactButtonTapped(_ sender: Any) {
        self.showAlert(title: "開發者聯絡資訊", message: "請以此電子信箱聯繫開發者：jenny98417rib@gmail.com")
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
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] action in
           
        }
        alert.addAction(action)
        present(alert, animated: true)
        
    }
    
    private func deleteCurrentUser() {
      do {
        let nonce = try CryptoUtils.randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = CryptoUtils.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
      } catch {
        // In the unlikely case that nonce generation fails, show error view.
//        displayError(error)
      }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
      guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
      else {
        print("Unable to retrieve AppleIDCredential")
        return
      }

      guard let _ = currentNonce else {
        fatalError("Invalid state: A login callback was received, but no login request was sent.")
      }

      guard let appleAuthCode = appleIDCredential.authorizationCode else {
        print("Unable to fetch authorization code")
        return
      }

      guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
        print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
        return
      }

      Task {
        do {
          try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
          try await Auth.auth().currentUser?.delete()
//          self.updateUI()
        } catch {
//          self.displayError(error)
        }
      }
    }


}

extension SettingViewController: ASAuthorizationControllerPresentationContextProviding {
        
    /// - Parameter controller: _
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
           return self.view.window!
    }
}

class CryptoUtils {
    static func randomNonceString(length: Int = 32) throws -> String {
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
   static func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}
