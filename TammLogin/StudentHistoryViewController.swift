//
//  StudentHistoryViewController.swift
//  TammLogin
//
//  Created by BP-36-213-11 on 03/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class StudentHistoryViewController: UIViewController {

    private var requests: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No requests yet"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "History"
        view.backgroundColor = .systemBackground
        setupTableView()
        fetchHistory()
    }

    deinit { listener?.remove() }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        tableView.delegate = self
        tableView.dataSource = self

        // same as admin history
        tableView.register(HistoryRequestCell.self, forCellReuseIdentifier: "HistoryRequestCell")

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

    private func fetchHistory() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = db.collection("maintenanceRequests")
            .whereField("userId", isEqualTo: uid)
            .order(by: "timestamp", descending: true)  
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("❌ Student history listener error:", error.localizedDescription)
                    return
                }

                self.requests = snapshot?.documents.compactMap {
                    MaintenanceRequest(id: $0.documentID, data: $0.data())
                } ?? []

                self.emptyLabel.isHidden = !self.requests.isEmpty
                self.tableView.reloadData()
            }
    }
}

extension StudentHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryRequestCell",
            for: indexPath
        ) as! HistoryRequestCell

        let request = requests[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

extension StudentHistoryViewController: HistoryRequestCellDelegate {
    func didTapView(request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }
}
