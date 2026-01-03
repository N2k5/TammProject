//
//  MyTaskViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MyTasksViewController: UIViewController {

    private var tasks: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?

    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No active tasks"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchMyTasks()
    }

    deinit {
        listener?.remove()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(MyTaskCell.self, forCellReuseIdentifier: MyTaskCell.reuseID)
        tableView.delegate = self
        tableView.dataSource = self

        view.addSubview(tableView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func fetchMyTasks() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = Firestore.firestore()
            .collection("maintenanceRequests")
            .whereField("status", isEqualTo: "Active")
            .whereField("staffID", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }

                self.tasks = snap?.documents.compactMap {
                    MaintenanceRequest(id: $0.documentID, data: $0.data())
                }.sorted { $0.timestamp > $1.timestamp } ?? []

                self.emptyLabel.isHidden = !self.tasks.isEmpty
                self.tableView.reloadData()
            }
    }

    private func markTaskComplete(_ request: MaintenanceRequest) {
        let alert = UIAlertController(
            title: "Complete Task",
            message: "Are you sure you want to submit this task as complete?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .default) { _ in
            Firestore.firestore()
                .collection("maintenanceRequests")
                .document(request.id)
                .updateData(["status": "Complete"])
        })

        present(alert, animated: true)
    }
}

extension MyTasksViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: MyTaskCell.reuseID,
            for: indexPath
        ) as! MyTaskCell

        let request = tasks[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

extension MyTasksViewController: MyTaskCellDelegate {

    func didTapView(for request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapFinish(for request: MaintenanceRequest) {
        markTaskComplete(request)
    }

    func didTapChat(for request: MaintenanceRequest) {
        let vc = ChatViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }
}
