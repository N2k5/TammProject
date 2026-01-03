//
//  MaintenanceApprovedRequestCell.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit

// MARK: - Delegate
protocol MaintenanceApprovedCellDelegate: AnyObject {
    func didTapAccept(for request: MaintenanceRequest)
    func didTapView(for request: MaintenanceRequest)
}

final class MaintenanceApprovedRequestsCell: UITableViewCell {

    static let reuseID = "MaintenanceApprovedRequestsCell"

    weak var delegate: MaintenanceApprovedCellDelegate?
    private var request: MaintenanceRequest?

    // MARK: - UI
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priorityLabel = UILabel()

    private let acceptButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Accept", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()

    private let viewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        titleLabel.font = .boldSystemFont(ofSize: 16)
        locationLabel.font = .systemFont(ofSize: 14)
        locationLabel.textColor = .secondaryLabel
        categoryLabel.font = .systemFont(ofSize: 13)
        categoryLabel.textColor = .tertiaryLabel
        priorityLabel.font = .boldSystemFont(ofSize: 13)
        priorityLabel.textAlignment = .right

        let buttonStack = UIStackView(arrangedSubviews: [acceptButton, viewButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 8
        buttonStack.distribution = .fillEqually
        buttonStack.translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, locationLabel, categoryLabel, priorityLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(priorityLabel)
        containerView.addSubview(buttonStack)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),

            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            categoryLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            priorityLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            priorityLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            buttonStack.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            buttonStack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            buttonStack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            buttonStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            buttonStack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    private func setupActions() {
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
    }

    // MARK: - Configure
    func configure(with request: MaintenanceRequest) {
        self.request = request
        titleLabel.text = request.titleDisplay
        locationLabel.text = request.locationString
        categoryLabel.text = "Category: \(request.issueCategory)"

        switch request.priorityLevel {
        case "Low":
            priorityLabel.text = "🟢 Low"
            priorityLabel.textColor = .systemGreen
        case "Medium":
            priorityLabel.text = "🟡 Medium"
            priorityLabel.textColor = .systemOrange
        case "Urgent/Critical":
            priorityLabel.text = "🔴 Urgent"
            priorityLabel.textColor = .systemRed
        default:
            priorityLabel.text = request.priorityLevel
            priorityLabel.textColor = .secondaryLabel
        }
    }

    // MARK: - Actions
    @objc private func acceptTapped() {
        guard let request else { return }
        delegate?.didTapAccept(for: request)
    }

    @objc private func viewTapped() {
        guard let request else { return }
        delegate?.didTapView(for: request)
    }
}

