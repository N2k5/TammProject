//
//  HistoryViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit
import FirebaseFirestore

class HistoryViewController: UIViewController {

    // MARK: - IBOutlets (Storyboard)
    @IBOutlet weak var monthCountLabel: UILabel!
    @IBOutlet weak var totalCountLabel: UILabel!
    @IBOutlet weak var activeCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties
    private var requests: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchStats()
        fetchHistory()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200

        // 🔑 REQUIRED for programmatic cell
        tableView.register(
            HistoryRequestCell.self,
            forCellReuseIdentifier: "HistoryRequestCell"
        )
    }

    // MARK: - Stats
    private func fetchStats() {
        fetchMonthlyCount()
        fetchTotalCount()
        fetchActiveCount()
    }

    private func fetchMonthlyCount() {
        let range = currentMonthRange()

        db.collection("maintenanceRequests")
            .whereField("timestamp", isGreaterThanOrEqualTo: range.start)
            .whereField("timestamp", isLessThan: range.end)
            .getDocuments { snapshot, _ in
                self.monthCountLabel.text = "\(snapshot?.documents.count ?? 0)"
            }
    }

    private func fetchTotalCount() {
        db.collection("maintenanceRequests")
            .getDocuments { snapshot, _ in
                self.totalCountLabel.text = "\(snapshot?.documents.count ?? 0)"
            }
    }

    private func fetchActiveCount() {
        db.collection("maintenanceRequests")
            .whereField("status", isEqualTo: "Active")
            .getDocuments { snapshot, _ in
                self.activeCountLabel.text = "\(snapshot?.documents.count ?? 0)"
            }
    }

    private func currentMonthRange() -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date()

        let start = calendar.date(
            from: calendar.dateComponents([.year, .month], from: now)
        )!

        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return (start, end)
    }

    // MARK: - History List
    private func fetchHistory() {
        listener = db.collection("maintenanceRequests")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { snapshot, _ in
                self.requests = snapshot?.documents.compactMap {
                    MaintenanceRequest(id: $0.documentID, data: $0.data())
                } ?? []

                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
}

// MARK: - UITableViewDelegate & DataSource
extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

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

// MARK: - HistoryRequestCellDelegate
extension HistoryViewController: HistoryRequestCellDelegate {

    func didTapView(request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }
}
