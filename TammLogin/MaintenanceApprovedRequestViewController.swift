//
//  MaintenanceApprovedRequestViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MaintenanceApprovedRequestsViewController: UIViewController {

    private var approvedRequests: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?

    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.separatorStyle = .none
        table.backgroundColor = .systemBackground
        return table
    }()

    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No approved requests"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        fetchApprovedRequests()
    }

    deinit {
        listener?.remove()
    }

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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            MaintenanceApprovedRequestsCell.self,
            forCellReuseIdentifier: MaintenanceApprovedRequestsCell.reuseID
        )
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
    }

    private func fetchApprovedRequests() {
        let db = Firestore.firestore()

        listener = db.collection("maintenanceRequests")
            .whereField("status", isEqualTo: "Approved")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("Error: \(error.localizedDescription)")
                    return
                }

                let docs = snapshot?.documents ?? []
                self.approvedRequests = docs
                    .compactMap { MaintenanceRequest(id: $0.documentID, data: $0.data()) }
                    .sorted { $0.timestamp > $1.timestamp }

                self.emptyStateLabel.isHidden = !self.approvedRequests.isEmpty
                self.tableView.reloadData()
            }
    }

    private func acceptRequest(_ request: MaintenanceRequest) {
        guard let user = Auth.auth().currentUser else { return }

        let data: [String: Any] = [
            "status": "Active",
            "staffEmail": user.email ?? "",
            "staffID": user.uid,
            "staffTimeStamp": Timestamp(date: Date())
        ]

        Firestore.firestore()
            .collection("maintenanceRequests")
            .document(request.id)
            .updateData(data)
    }
}

// MARK: - TableView
extension MaintenanceApprovedRequestsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        approvedRequests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: MaintenanceApprovedRequestsCell.reuseID,
            for: indexPath
        ) as! MaintenanceApprovedRequestsCell

        let request = approvedRequests[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

// MARK: - Cell Delegate
extension MaintenanceApprovedRequestsViewController: MaintenanceApprovedCellDelegate {

    func didTapAccept(for request: MaintenanceRequest) {
        acceptRequest(request)
    }

    func didTapView(for request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }
}
