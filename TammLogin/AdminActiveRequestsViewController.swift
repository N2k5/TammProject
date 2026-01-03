//
//  AdminActiveRequestsViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit
import FirebaseFirestore

final class AdminActiveRequestsViewController: UIViewController {

    private var requests: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?

    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchActiveRequests()
    }

    deinit { listener?.remove() }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(
            AdminActiveRequestCell.self,
            forCellReuseIdentifier: AdminActiveRequestCell.reuseID
        )
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)

        // 🔧 FIX: constrain to SAFE AREA instead of view.bottomAnchor
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func fetchActiveRequests() {
        listener = Firestore.firestore()
            .collection("maintenanceRequests")
            .whereField("status", isEqualTo: "Active")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }

                self.requests = snap?.documents.compactMap {
                    MaintenanceRequest(id: $0.documentID, data: $0.data())
                }
                .sorted { $0.timestamp > $1.timestamp } ?? []

                self.tableView.reloadData()
            }
    }

    private func denyRequest(_ request: MaintenanceRequest) {
        let alert = UIAlertController(
            title: "Remove Request",
            message: "Are you sure you want to do this? This cannot be undone.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { _ in
            Firestore.firestore()
                .collection("maintenanceRequests")
                .document(request.id)
                .updateData(["status": "Denied"])
        })

        present(alert, animated: true)
    }
}

extension AdminActiveRequestsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: AdminActiveRequestCell.reuseID,
            for: indexPath
        ) as! AdminActiveRequestCell

        let request = requests[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

extension AdminActiveRequestsViewController: AdminActiveRequestCellDelegate {

    func didTapView(for request: MaintenanceRequest) {
        navigationController?.pushViewController(
            RequestSummaryViewController(request: request),
            animated: true
        )
    }

    func didTapEdit(for request: MaintenanceRequest) {
        let vc = EditMaintenanceRequestViewController(request: request)
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    func didTapRemove(for request: MaintenanceRequest) {
        denyRequest(request)
    }
}
