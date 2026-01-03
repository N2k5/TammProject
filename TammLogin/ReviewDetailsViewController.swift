import UIKit
import FirebaseFirestore

final class ReviewDetailsViewController: UIViewController {

    private let requestID: String

    private let ratingLabel: UILabel = {
        let l = UILabel()
        l.font = .boldSystemFont(ofSize: 22)
        l.textAlignment = .center
        l.text = "Loading..."
        return l
    }()

    private let commentLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 16)
        l.textColor = .secondaryLabel
        l.numberOfLines = 0
        l.text = "Loading..."
        return l
    }()

    init(requestID: String) {
        self.requestID = requestID
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Review"
        view.backgroundColor = .systemBackground
        setupUI()
        loadReview()
    }

    private func setupUI() {
        let stack = UIStackView(arrangedSubviews: [ratingLabel, commentLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func loadReview() {
        Firestore.firestore()
            .collection("maintenanceRequests")
            .document(requestID)
            .getDocument { [weak self] snap, error in
                guard let self else { return }

                if error != nil {
                    self.ratingLabel.text = "No rating"
                    self.commentLabel.text = "No comment"
                    return
                }

                let data = snap?.data() ?? [:]

                let rating: Int? = {
                    if let r = data["rating"] as? Int { return r }
                    if let r = data["rating"] as? NSNumber { return r.intValue }
                    return nil
                }()

                // your requested key is rateComment
                let comment = (data["rateComment"] as? String)
                    // fallback if you ever used another key name
                    ?? (data["ratingComment"] as? String)
                    ?? ""

                if let rating, (1...5).contains(rating) {
                    self.ratingLabel.text = "Rating: \(rating)/5"
                } else {
                    self.ratingLabel.text = "No rating"
                }

                let trimmed = comment.trimmingCharacters(in: .whitespacesAndNewlines)
                self.commentLabel.text = trimmed.isEmpty ? "No comment" : trimmed
            }
    }
}
