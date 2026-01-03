//
//  EditMaintenanceRequestViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit
import FirebaseFirestore

final class EditMaintenanceRequestViewController: UIViewController {

    // MARK: - Properties
    private let request: MaintenanceRequest

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let titleField = UITextField()
    private let descriptionView = UITextView()

    private let buildingField = UITextField()
    private let floorField = UITextField()
    private let roomField = UITextField()

    private let accessNotesView = UITextView()

    // MARK: - Init
    init(request: MaintenanceRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        populateFields()
    }

    // MARK: - UI Setup
    private func setupUI() {
        title = "Edit Request"
        view.backgroundColor = .systemBackground

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(backTapped)
        )

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Submit",
            style: .done,
            target: self,
            action: #selector(submitTapped)
        )

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        contentStack.axis = .vertical
        contentStack.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20)
        ])

        configureFields()
        addFieldsToStack()
    }

    // MARK: - Field Configuration
    private func configureFields() {

        titleField.placeholder = "Title"
        titleField.borderStyle = .roundedRect

        buildingField.placeholder = "Building"
        floorField.placeholder = "Floor"
        roomField.placeholder = "Room"

        [buildingField, floorField, roomField].forEach {
            $0.borderStyle = .roundedRect
            $0.keyboardType = .numberPad
        }

        [descriptionView, accessNotesView].forEach {
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.systemGray4.cgColor
            $0.layer.cornerRadius = 8
            $0.font = .systemFont(ofSize: 16)
            $0.heightAnchor.constraint(equalToConstant: 120).isActive = true
        }
    }

    // MARK: - Layout Helpers
    private func addFieldsToStack() {

        contentStack.addArrangedSubview(makeLabel("Title"))
        contentStack.addArrangedSubview(titleField)

        contentStack.addArrangedSubview(makeLabel("Description"))
        contentStack.addArrangedSubview(descriptionView)

        contentStack.addArrangedSubview(makeLabel("Location"))

        contentStack.addArrangedSubview(makeInlineLocationStack())

        contentStack.addArrangedSubview(makeLabel("Access Notes"))
        contentStack.addArrangedSubview(accessNotesView)
    }

    private func makeInlineLocationStack() -> UIStackView {
        let stack = UIStackView(arrangedSubviews: [
            labeledField("Building", buildingField),
            labeledField("Floor", floorField),
            labeledField("Room", roomField)
        ])

        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }

    private func labeledField(_ label: String, _ field: UITextField) -> UIStackView {
        let l = UILabel()
        l.text = label
        l.font = .systemFont(ofSize: 12, weight: .medium)

        let stack = UIStackView(arrangedSubviews: [l, field])
        stack.axis = .vertical
        stack.spacing = 4
        return stack
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        return label
    }

    // MARK: - Populate Existing Data
    private func populateFields() {
        titleField.text = request.requestTitle
        descriptionView.text = request.detailedDescription
        accessNotesView.text = request.roomAccessNotes

        buildingField.text = request.building
        floorField.text = request.floor
        roomField.text = request.roomNo
    }

    // MARK: - Actions
    @objc private func backTapped() {
        dismiss(animated: true)
    }

    @objc private func submitTapped() {
        let alert = UIAlertController(
            title: "Confirm Changes",
            message: "Are you sure you want to change these fields? This cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            self.updateRequest()
        })

        present(alert, animated: true)
    }

    // MARK: - Firestore Update
    private func updateRequest() {

        let updatedData: [String: Any] = [
            "requestTitle": titleField.text ?? "",
            "detailedDescription": descriptionView.text ?? "",
            "building": buildingField.text ?? "",
            "floor": floorField.text ?? "",
            "roomNo": roomField.text ?? "",
            "roomAccessNotes": accessNotesView.text ?? ""
        ]

        Firestore.firestore()
            .collection("maintenanceRequests")
            .document(request.id)
            .updateData(updatedData) { _ in
                self.dismiss(animated: true)
            }
    }
}
