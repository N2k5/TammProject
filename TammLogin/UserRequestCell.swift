import UIKit

protocol UserRequestCellDelegate: AnyObject {
    func didTapView(for request: MaintenanceRequest)
    func didTapChat(for request: MaintenanceRequest)
    func didTapReview(for request: MaintenanceRequest)
    func didTapCancel(for request: MaintenanceRequest)   // ✅ NEW
}

final class UserRequestCell: UITableViewCell {

    static let reuseID = "UserRequestCell"

    weak var delegate: UserRequestCellDelegate?
    private var request: MaintenanceRequest?

    private let containerView = UIView()
    private let statusLabel = UILabel()
    private let ticketLabel = UILabel()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()

    private let viewButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("View", for: .normal)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        return b
    }()

    // We reuse this button as Chat OR Review OR Cancel depending on status.
    private let actionButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Chat", for: .normal)
        b.backgroundColor = .systemPurple
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        return b
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false

        [statusLabel, ticketLabel, titleLabel, locationLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        viewButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)
        containerView.addSubview(statusLabel)
        containerView.addSubview(ticketLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(viewButton)
        containerView.addSubview(actionButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            statusLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            ticketLabel.centerYAnchor.constraint(equalTo: statusLabel.centerYAnchor),
            ticketLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: statusLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: ticketLabel.trailingAnchor),

            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            viewButton.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 12),
            viewButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            viewButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            viewButton.heightAnchor.constraint(equalToConstant: 36),

            actionButton.topAnchor.constraint(equalTo: viewButton.bottomAnchor, constant: 8),
            actionButton.leadingAnchor.constraint(equalTo: viewButton.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: viewButton.trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    func configure(with request: MaintenanceRequest) {
        self.request = request

        statusLabel.text = request.status.uppercased()
        statusLabel.textColor = statusColor(request.status)
        ticketLabel.text = request.ticketID
        titleLabel.text = request.titleDisplay
        locationLabel.text = request.locationString

        // ✅ ACTIVE => Chat
        if request.status == "Active" {
            actionButton.isHidden = false
            actionButton.setTitle("Chat", for: .normal)
            actionButton.backgroundColor = .systemPurple
        }
        // ✅ COMPLETE => Review
        else if request.status == "Complete" {
            actionButton.isHidden = false
            actionButton.setTitle("Review", for: .normal)
            actionButton.backgroundColor = .systemGreen
        }
        // ✅ Pending/Approved/Denied => Cancel (no more blank space)
        else if request.status == "Pending" || request.status == "Approved" || request.status == "Denied" {
            actionButton.isHidden = false
            actionButton.setTitle("Cancel", for: .normal)
            actionButton.backgroundColor = .systemRed
        }
        // Anything else => hide
        else {
            actionButton.isHidden = true
        }
    }

    private func statusColor(_ status: String) -> UIColor {
        switch status {
        case "Pending": return .systemOrange
        case "Approved": return .systemBlue
        case "Active": return .systemGreen
        case "Complete": return .systemGray
        case "Denied": return .systemRed
        default: return .secondaryLabel
        }
    }

    private func setupActions() {
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
    }

    @objc private func viewTapped() {
        guard let request else { return }
        delegate?.didTapView(for: request)
    }

    @objc private func actionTapped() {
        guard let request else { return }

        if request.status == "Complete" {
            delegate?.didTapReview(for: request)
        } else if request.status == "Active" {
            delegate?.didTapChat(for: request)
        } else if request.status == "Pending" || request.status == "Approved" || request.status == "Denied" {
            delegate?.didTapCancel(for: request)   // ✅ delete
        }
    }
}
