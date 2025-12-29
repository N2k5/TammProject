//
//  LoginViewController.swift
//  TammLogin
//
//  Created by BP-36-212-19 on 28/12/2025.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }

    // MARK: - Actions
    @IBAction func loginClicked(_ sender: UIButton) {
        loginUser()
    }

    // MARK: - Login Function
    func loginUser() {
        // Get email and password safely
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""

        // Check for empty fields
        if email.isEmpty || password.isEmpty {
            showAlert(title: "Error", message: "Please fill all fields")
            return
        }

        // Firebase sign-in
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in

            // Any login failure shows the same message
            if error != nil {
                self.showAlert(title: "Login Failed", message: "This email is not registered")
                return
            }

            // Successful login
            guard let user = Auth.auth().currentUser else {
                self.showAlert(title: "Login Failed", message: "Unable to fetch user data")
                return
            }

            print("✅ User logged in successfully: \(user.email ?? "")")

            // Navigate to Home
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToHome", sender: nil)
            }
        }
    }

    // MARK: - Alert Function
    func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
}
