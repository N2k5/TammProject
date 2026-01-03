//
//  LoginViewController.swift
//  TammLogin
//
//  Created by BP-36-212-19 on 28/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class LoginViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!

    // MARK: - Firestore
    let db = Firestore.firestore()

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
        guard let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !email.isEmpty,
              let password = passwordTextField.text,
              !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter email and password")
            return
        }

        // Firebase Auth login
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }

            if let error = error {
                print("Auth error:", error.localizedDescription)
                self.showAlert(title: "Login Failed", message: "Wrong email or password")
                return
            }

            print("Logged in UID:", authResult?.user.uid ?? "No UID")

            // Fetch user document from Firestore by email
            self.db.collection("Users")
                .whereField("email", isEqualTo: email)
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("Firestore error:", error.localizedDescription)
                        self.showAlert(title: "Error", message: "Could not fetch user data")
                        return
                    }

                    guard let document = snapshot?.documents.first else {
                        print("No document found for email:", email)
                        self.showAlert(title: "Error", message: "User data not found")
                        return
                    }

                    print("Document data:", document.data())

                    let role = document.data()["role"] as? String ?? "user"
                    print("User role:", role)

                    // Navigate based on role
                    DispatchQueue.main.async {
                        self.navigateToDashboard(forRole: role)
                    }
                }
        }
    }

    // MARK: - Navigation
    func navigateToDashboard(forRole role: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        var destinationVC: UIViewController

        switch role {
        case "admin":
            destinationVC = storyboard.instantiateViewController(withIdentifier: "AdminDashboardVC")
        case "maintenance":
            // Navigate to first page of maintenance request form
            destinationVC = storyboard.instantiateViewController(withIdentifier: "MaintenanceDashboardVC")
        default:
            destinationVC = storyboard.instantiateViewController(withIdentifier: "UserDashboardVC")
        }

        let nav = UINavigationController(rootViewController: destinationVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    // MARK: - Alert Helper
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
