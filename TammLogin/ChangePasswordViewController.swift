//
//  ChangePasswordViewController.swift
//  TammLogin
//
//  Created by BP-36-213-09 on 23/12/2025.
//

import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {


    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveButtonTapped(_ sender: UIButton) {
        changePassword()
    }

    private func changePassword() {

        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            showAlert(title: "Error", message: "User not logged in.")
            return
        }

        let oldPassword = oldPasswordTextField.text ?? ""
        let newPassword = newPasswordTextField.text ?? ""
        let confirmPassword = confirmPasswordTextField.text ?? ""

        // MARK: - Validation
        if oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty {
            showAlert(title: "Error", message: "All fields are required.")
            return
        }

        if newPassword != confirmPassword {
            showAlert(title: "Error", message: "New passwords do not match.")
            return
        }

        if newPassword.count < 6 {
            showAlert(title: "Error", message: "Password must be at least 6 characters.")
            return
        }

        // MARK: - Re-authenticate user
        let credential = EmailAuthProvider.credential(withEmail: email, password: oldPassword)

        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                self.showAlert(title: "Error", message: "Old password is incorrect.")
                print(error.localizedDescription)
                return
            }

            // MARK: - Update password
            user.updatePassword(to: newPassword) { error in
                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }

                self.showAlert(title: "Success", message: "Password changed successfully.") {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

    // MARK: - Alert Helper
    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

