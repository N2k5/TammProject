import UIKit
import FirebaseFirestore
import FirebaseAuth

final class MaintenanceHistoryViewController: UIViewController {

    // MARK: - Firestore
    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    
    private let maintenanceUIDField = "staffID"

    // MARK: - Data
    private var requests: [MaintenanceRequest] = []

    // MARK: - UI
    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "No accepted requests yet"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Request History"
        tabBarItem.title = "History" // optional (tab bar label)

        view.backgroundColor = .systemBackground
        setupTableView()
        fetchHistory()
    }

    deinit {
        listener?.remove()
    }

    // MARK: - Setup
    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 220
        tableView.delegate = self
        tableView.dataSource = self

        // ✅ Use the new maintenance-only cell (View + Check Review)
        tableView.register(
            MaintenanceHistoryRequestCell.self,
            forCellReuseIdentifier: "MaintenanceHistoryRequestCell"
        )

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

    // MARK: - Data
    private func fetchHistory() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("❌ No logged in user")
            return
        }

        // Firestore: only requests where accepted/assigned maintenance UID == current user UID
        listener = db.collection("maintenanceRequests")
            .whereField(maintenanceUIDField, isEqualTo: uid)
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self else { return }

                if let error {
                    print("❌ Maintenance history listener error:", error.localizedDescription)
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

// MARK: - TableView
extension MaintenanceHistoryViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MaintenanceHistoryRequestCell",
            for: indexPath
        ) as! MaintenanceHistoryRequestCell

        let request = requests[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

// MARK: - Cell Delegate
extension MaintenanceHistoryViewController: MaintenanceHistoryRequestCellDelegate {

    func didTapView(request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapCheckReview(request: MaintenanceRequest) {
        let vc = ReviewDetailsViewController(requestID: request.id)
        navigationController?.pushViewController(vc, animated: true)
    }
}
