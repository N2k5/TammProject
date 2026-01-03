//
//  PendingRequestsViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 31/12/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class PendingRequestsViewController: UIViewController {

    // MARK: - Properties
    private var pendingRequests: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?

    // MARK: - UI Components
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        return table
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No pending requests"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchPendingRequests()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(
            PendingRequestCell.self,
            forCellReuseIdentifier: "PendingRequestCell"
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }

    private func fetchPendingRequests() {
        let db = Firestore.firestore()

        listener = db.collection("maintenanceRequests")
            .whereField("status", isEqualTo: "Pending")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error fetching pending requests: \(error.localizedDescription)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.pendingRequests = []
                    self.updateUI()
                    return
                }

                let requests = documents.compactMap {
                    MaintenanceRequest(id: $0.documentID, data: $0.data())
                }

                self.pendingRequests = requests.sorted {
                    $0.timestamp > $1.timestamp
                }

                self.updateUI()
            }
    }

    private func updateUI() {
        emptyStateLabel.isHidden = !pendingRequests.isEmpty
        tableView.reloadData()
    }

    // MARK: - Actions
    private func approveRequest(_ request: MaintenanceRequest) {
        updateRequestStatus(
            request,
            newStatus: "Approved",
            successMessage: "Request approved!"
        )
    }

    private func denyRequest(_ request: MaintenanceRequest) {
        let alert = UIAlertController(
            title: "Deny Request",
            message: "Are you sure you want to deny this request?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Deny", style: .destructive) { [weak self] _ in
            self?.updateRequestStatus(
                request,
                newStatus: "Denied",
                successMessage: "Request denied"
            )
        })
        present(alert, animated: true)
    }

    private func updateRequestStatus(
        _ request: MaintenanceRequest,
        newStatus: String,
        successMessage: String
    ) {
        let db = Firestore.firestore()

        db.collection("maintenanceRequests")
            .document(request.id)
            .updateData(["status": newStatus]) { error in
                if let error = error {
                    self.showAlert(
                        title: "Error",
                        message: error.localizedDescription
                    )
                } else {
                    self.showAlert(
                        title: "Success",
                        message: successMessage
                    )
                }
            }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & DataSource
extension PendingRequestsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        pendingRequests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "PendingRequestCell",
            for: indexPath
        ) as! PendingRequestCell

        let request = pendingRequests[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

// MARK: - PendingRequestCellDelegate
extension PendingRequestsViewController: PendingRequestCellDelegate {

    func didTapApprove(for request: MaintenanceRequest) {
        approveRequest(request)
    }

    func didTapView(for request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func didTapDeny(for request: MaintenanceRequest) {
        denyRequest(request)
    }
}
