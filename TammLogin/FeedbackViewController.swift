import UIKit
import UserNotifications
import FirebaseFirestore

final class FeedbackViewController: UIViewController, UITextViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var feedbackTextView: UITextView?
    @IBOutlet weak var submitButton: UIButton?

    // Stars
    @IBOutlet weak var star1: UIButton?
    @IBOutlet weak var star2: UIButton?
    @IBOutlet weak var star3: UIButton?
    @IBOutlet weak var star4: UIButton?
    @IBOutlet weak var star5: UIButton?

    // MARK: - NEW: request doc id
    var requestID: String?

    // MARK: - Properties
    private var rating: Int = 0
    private let placeholderText = "Write your feedback..."

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        setupTextView()
        setupButton()
        updateStars()

        // Keep this if your "Notifications" feature requires permission request
        requestNotificationPermission()
    }

    // MARK: - Setup
    private func setupTextView() {
        guard let textView = feedbackTextView else { return }

        textView.delegate = self
        textView.text = placeholderText
        textView.textColor = .systemGray3
        textView.layer.cornerRadius = 12
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
    }

    private func setupButton() {
        guard let button = submitButton else { return }

        button.setTitle("Submit", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 14
    }

    // MARK: - Star Logic
    @IBAction func starTapped(_ sender: UIButton) {
        rating = sender.tag
        updateStars()
    }

    private func updateStars() {
        let stars = [star1, star2, star3, star4, star5]

        for (index, star) in stars.enumerated() {
            guard let star = star else { continue }

            let filled = index < rating
            let imageName = filled ? "star.fill" : "star"
            star.setImage(UIImage(systemName: imageName), for: .normal)
            star.tintColor = .systemGreen
        }
    }

    // MARK: - TextView Placeholder
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .label
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = placeholderText
            textView.textColor = .systemGray3
        }
    }

    // MARK: - Notifications (system notifications)
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("✅ Notification permission granted")
            } else {
                print("❌ Notification permission denied")
            }
        }
    }

    // Optional: keep for your "Notifications" feature, but we won’t use it for the on-page popup
    private func scheduleThankYouNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Thank you!"
        content.body = "We appreciate your feedback 🙌"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let request = UNNotificationRequest(
            identifier: "feedbackNotification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Submit (Firestore + popup)
    @IBAction func submitTapped(_ sender: UIButton) {
        guard let requestID, !requestID.isEmpty else {
            showAlert(title: "Error", message: "Missing request id.")
            return
        }

        // Must choose rating
        guard (1...5).contains(rating) else {
            showAlert(title: "Rating required", message: "Please select 1 to 5 stars.")
            return
        }

        let raw = feedbackTextView?.text ?? ""
        let comment = (raw == placeholderText) ? "" : raw.trimmingCharacters(in: .whitespacesAndNewlines)

        submitButton?.isEnabled = false

        Firestore.firestore()
            .collection("maintenanceRequests")
            .document(requestID)
            .updateData([
                "rating": rating,
                "rateComment": comment
            ]) { [weak self] error in
                guard let self else { return }
                self.submitButton?.isEnabled = true

                if let error {
                    self.showAlert(title: "Upload failed", message: error.localizedDescription)
                    return
                }

                let alert = UIAlertController(
                    title: "Thank you for your feedback!",
                    message: nil,
                    preferredStyle: .alert
                )

                let ok = UIAlertAction(title: "OK!", style: .default) { _ in
                    self.goHome()
                }

                alert.addAction(ok)
                present(alert, animated: true)
            }
    }

    // MARK: - Close (X)
    @IBAction func closeTapped(_ sender: UIButton) {
        goHome()
    }

    private func goHome() {
        // If pushed inside a nav controller:
        if let nav = navigationController {
            nav.popToRootViewController(animated: true)
            return
        }

        // If presented modally from a nav controller:
        if let presentingNav = presentingViewController as? UINavigationController {
            dismiss(animated: true) {
                presentingNav.popToRootViewController(animated: true)
            }
            return
        }

        // If presented modally from a tab bar:
        if let tab = presentingViewController as? UITabBarController {
            dismiss(animated: true) {
                tab.selectedIndex = 0
            }
            return
        }

        // Fallback
        dismiss(animated: true)
    }

    private func showAlert(title: String, message: String) {
        let a = UIAlertController(title: title, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default))
        present(a, animated: true)
    }
}
