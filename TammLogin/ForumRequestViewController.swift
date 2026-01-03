//
//  ForumRequestViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 31/12/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class ForumRequestViewController: UIViewController {

    // MARK: - OUTLETS
    @IBOutlet weak var requestTitleTextField: UITextField!
    @IBOutlet weak var buildingTextField: UITextField!
    @IBOutlet weak var floorTextField: UITextField!
    @IBOutlet weak var roomNoTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!

    @IBOutlet weak var issueCategoryButton: UIButton!
    @IBOutlet weak var priorityLevelButton: UIButton!
    @IBOutlet weak var roomAccessNotesTextField: UITextField!
    @IBOutlet weak var attachedImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!

    // MARK: - STATE
    private var selectedIssueCategory: String?
    private var selectedPriorityLevel: String?
    private var attachedImage: UIImage?

    // MARK: - CONSTANTS
    private let issueCategories = ["Plumbing", "Electrical", "HVAC", "Furniture"]
    private let priorityLevels = ["Low", "Medium", "Urgent/Critical"]

    // MARK: - LIFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        configureIssueCategoryMenu()
        configurePriorityLevelMenu()
    }

    // MARK: - ACTIONS
    @IBAction func attachPhotoTapped(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    @IBAction func submitButtonTapped(_ sender: UIButton) {
        guard
            let title = requestTitleTextField.text, !title.isEmpty,
            let building = buildingTextField.text, !building.isEmpty,
            let floor = floorTextField.text, !floor.isEmpty,
            let room = roomNoTextField.text, !room.isEmpty,
            let description = descriptionTextField.text, !description.isEmpty
        else {
            showAlert(title: "Missing Information",
                      message: "Please fill in all required fields.")
            return
        }

        guard let issueCategory = selectedIssueCategory else {
            showAlert(title: "Missing Issue Category",
                      message: "Please select an issue category.")
            return
        }

        guard let priorityLevel = selectedPriorityLevel else {
            showAlert(title: "Missing Priority Level",
                      message: "Please select a priority level.")
            return
        }

        guard let image = attachedImage else {
            showAlert(title: "Image Required",
                      message: "Please attach an image before submitting.")
            return
        }

        submitButton.isEnabled = false
        submitRequestToFirebase(
            title: title,
            building: building,
            floor: floor,
            room: room,
            description: description,
            issueCategory: issueCategory,
            priorityLevel: priorityLevel,
            accessNotes: roomAccessNotesTextField.text ?? "",
            image: image
        )
    }

    // MARK: - FIREBASE SUBMIT
    private func submitRequestToFirebase(
        title: String,
        building: String,
        floor: String,
        room: String,
        description: String,
        issueCategory: String,
        priorityLevel: String,
        accessNotes: String,
        image: UIImage
    ) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        guard let user = Auth.auth().currentUser else {
            submitButton.isEnabled = true
            showAlert(
                title: "Session Error",
                message: "Please log out and log back in."
            )
            return
        }

        let docRef = db.collection("maintenanceRequests").document()
        let documentID = docRef.documentID

        let ticketID = "TICKET-\(Int(Date().timeIntervalSince1970 * 1000))-\(UUID().uuidString.prefix(4))"

        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            submitButton.isEnabled = true
            showAlert(title: "Image Error", message: "Failed to process image.")
            return
        }

        let imageRef = storage
            .reference()
            .child("maintenance_requests/\(documentID).jpg")

        imageRef.putData(imageData) { [weak self] _, error in
            if let error = error {
                self?.submitButton.isEnabled = true
                self?.showAlert(title: "Upload Failed",
                                 message: error.localizedDescription)
                return
            }

            imageRef.downloadURL { url, error in
                if let error = error {
                    self?.submitButton.isEnabled = true
                    self?.showAlert(title: "Upload Failed",
                                     message: error.localizedDescription)
                    return
                }

                guard let imageURL = url?.absoluteString else {
                    self?.submitButton.isEnabled = true
                    self?.showAlert(title: "Upload Failed",
                                     message: "Invalid image URL.")
                    return
                }

                let data: [String: Any] = [
                    "requestTitle": title,
                    "building": building,
                    "floor": floor,
                    "roomNo": room,
                    "detailedDescription": description,
                    "issueCategory": issueCategory,
                    "priorityLevel": priorityLevel,
                    "roomAccessNotes": accessNotes,
                    "imageURL": imageURL,
                    "status": "Pending",
                    "ticketID": ticketID,
                    "timestamp": FieldValue.serverTimestamp(),
                    "userId": user.uid,
                    "userEmail": user.email ?? ""
                ]

                docRef.setData(data) { error in
                    self?.submitButton.isEnabled = true

                    if let error = error {
                        self?.showAlert(title: "Submission Failed",
                                         message: error.localizedDescription)
                    } else {
                        self?.showAlert(title: "Success",
                                         message: "Maintenance request submitted.")
                    }
                }
            }
        }
    }

    // MARK: - MENUS
    private func configureIssueCategoryMenu() {
        let actions = issueCategories.map { category in
            UIAction(title: category) { [weak self] _ in
                self?.selectedIssueCategory = category
                self?.issueCategoryButton.setTitle(category, for: .normal)
            }
        }

        issueCategoryButton.menu = UIMenu(title: "Select Issue Category",
                                          children: actions)
        issueCategoryButton.showsMenuAsPrimaryAction = true
    }

    private func configurePriorityLevelMenu() {
        let actions = priorityLevels.map { level in
            UIAction(title: level) { [weak self] _ in
                self?.selectedPriorityLevel = level
                self?.priorityLevelButton.setTitle(level, for: .normal)
            }
        }

        priorityLevelButton.menu = UIMenu(title: "Select Priority Level",
                                          children: actions)
        priorityLevelButton.showsMenuAsPrimaryAction = true
    }

    // MARK: - ALERT
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - IMAGE PICKER
extension ForumRequestViewController:
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let image =
            (info[.editedImage] ?? info[.originalImage]) as? UIImage

        attachedImage = image
        attachedImageView.image = image
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
