import UIKit
import FirebaseFirestore
import FirebaseAuth

final class YourRequestsViewController: UIViewController {

    private var requests: [MaintenanceRequest] = []
    private var listener: ListenerRegistration?

    private let tableView = UITableView()
    private let emptyLabel: UILabel = {
        let l = UILabel()
        l.text = "You haven't submitted any requests yet"
        l.textAlignment = .center
        l.textColor = .secondaryLabel
        l.isHidden = true
        return l
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchUserRequests()
    }

    deinit { listener?.remove() }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Your Requests"

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.register(UserRequestCell.self,
                           forCellReuseIdentifier: UserRequestCell.reuseID)
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

    private func fetchUserRequests() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        listener = Firestore.firestore()
            .collection("maintenanceRequests")
            .whereField("userId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }

                self.requests = snap?.documents.compactMap {
                    MaintenanceRequest(id: $0.documentID, data: $0.data())
                }.sorted { $0.timestamp > $1.timestamp } ?? []

                self.emptyLabel.isHidden = !self.requests.isEmpty
                self.tableView.reloadData()
            }
    }

    private func confirmCancelAndDelete(_ request: MaintenanceRequest) {
        let alert = UIAlertController(
            title: "Cancel Request",
            message: "Are you sure you want to cancel this request? This will delete it permanently.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive) { _ in
            Firestore.firestore()
                .collection("maintenanceRequests")
                .document(request.id)
                .delete { error in
                    if let error = error {
                        print("❌ Failed to delete request:", error)
                    } else {
                        print("✅ Request deleted:", request.id)
                    }
                }
        })

        present(alert, animated: true)
    }
}

extension YourRequestsViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        requests.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: UserRequestCell.reuseID,
            for: indexPath
        ) as! UserRequestCell

        let request = requests[indexPath.row]
        cell.configure(with: request)
        cell.delegate = self
        return cell
    }
}

extension YourRequestsViewController: UserRequestCellDelegate {

    func didTapView(for request: MaintenanceRequest) {
        let vc = RequestSummaryViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapChat(for request: MaintenanceRequest) {
        let vc = ChatViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }

    func didTapReview(for request: MaintenanceRequest) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "FeedbackViewController") as! FeedbackViewController
        vc.requestID = request.id
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }

    // ✅ NEW: Cancel request (delete from DB)
    func didTapCancel(for request: MaintenanceRequest) {
        confirmCancelAndDelete(request)
    }
}
