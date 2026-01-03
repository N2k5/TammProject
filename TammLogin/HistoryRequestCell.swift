//
//  HistoryRequestCell.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit

protocol HistoryRequestCellDelegate: AnyObject {
    func didTapView(request: MaintenanceRequest)
}

class HistoryRequestCell: UITableViewCell {

    weak var delegate: HistoryRequestCellDelegate?
    private var request: MaintenanceRequest?

    // MARK: - UI
    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priorityLabel = UILabel()
    private let statusBadge = UILabel()
    private let viewButton = UIButton(type: .system)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.08
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, locationLabel, categoryLabel, priorityLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.numberOfLines = 2

        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 0

        categoryLabel.font = .systemFont(ofSize: 13)
        categoryLabel.textColor = .tertiaryLabel

        priorityLabel.font = .boldSystemFont(ofSize: 13)

        statusBadge.font = .systemFont(ofSize: 12, weight: .bold)
        statusBadge.textColor = .white
        statusBadge.textAlignment = .center
        statusBadge.layer.cornerRadius = 8
        statusBadge.clipsToBounds = true
        statusBadge.translatesAutoresizingMaskIntoConstraints = false

        viewButton.setTitle("View", for: .normal)
        viewButton.titleLabel?.font = .boldSystemFont(ofSize: 14)
        viewButton.backgroundColor = .systemBlue
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.layer.cornerRadius = 8
        viewButton.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(priorityLabel)
        containerView.addSubview(statusBadge)
        containerView.addSubview(viewButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: statusBadge.leadingAnchor, constant: -8),

            statusBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            statusBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            statusBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 70),
            statusBadge.heightAnchor.constraint(equalToConstant: 24),

            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            categoryLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),

            priorityLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            priorityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            viewButton.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            viewButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            viewButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            viewButton.heightAnchor.constraint(equalToConstant: 40),
            viewButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    private func setupActions() {
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
    }

    func configure(with request: MaintenanceRequest) {
        self.request = request

        titleLabel.text = request.titleDisplay
        locationLabel.text = request.locationString
        categoryLabel.text = "Category: \(request.issueCategory)"
        priorityLabel.text = request.priorityLevel

        switch request.status {
        case "Pending":
            statusBadge.text = "Pending"
            statusBadge.backgroundColor = .systemOrange

        case "Approved":
            statusBadge.text = "Approved"
            statusBadge.backgroundColor = .systemTeal

        case "Active":
            statusBadge.text = "Active"
            statusBadge.backgroundColor = .systemBlue

        case "Complete":
            statusBadge.text = "Complete"
            statusBadge.backgroundColor = .systemGreen

        case "Denied":
            statusBadge.text = "Denied"
            statusBadge.backgroundColor = .systemRed

        default:
            statusBadge.text = request.status
            statusBadge.backgroundColor = .systemGray
        }
    }

    @objc private func viewTapped() {
        guard let request = request else { return }
        delegate?.didTapView(request: request)
    }
}


