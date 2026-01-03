//
//  AdminActiveRequestCell.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit

protocol AdminActiveRequestCellDelegate: AnyObject {
    func didTapView(for request: MaintenanceRequest)
    func didTapEdit(for request: MaintenanceRequest)
    func didTapRemove(for request: MaintenanceRequest)
}

final class AdminActiveRequestCell: UITableViewCell {

    static let reuseID = "AdminActiveRequestCell"

    weak var delegate: AdminActiveRequestCellDelegate?
    private var request: MaintenanceRequest?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priorityLabel = UILabel()

    private let viewButton = makeButton("View", .systemBlue)
    private let editButton = makeButton("Edit", .systemYellow)
    private let removeButton = makeButton("Remove", .systemRed)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupActions()
    }

    required init?(coder: NSCoder) { fatalError() }

    private static func makeButton(_ title: String, _ color: UIColor) -> UIButton {
        let b = UIButton(type: .system)
        b.setTitle(title, for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = color
        b.layer.cornerRadius = 8
        return b
    }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.layer.shadowOpacity = 0.1
        containerView.translatesAutoresizingMaskIntoConstraints = false

        let stack = UIStackView(arrangedSubviews: [viewButton, editButton, removeButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        [titleLabel, locationLabel, categoryLabel, priorityLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(priorityLabel)
        containerView.addSubview(stack)

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

            categoryLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),

            priorityLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            priorityLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            stack.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            stack.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    func configure(with request: MaintenanceRequest) {
        self.request = request
        titleLabel.text = request.titleDisplay
        locationLabel.text = request.locationString
        categoryLabel.text = "Category: \(request.issueCategory)"
        priorityLabel.text = request.priorityLevel
    }

    private func setupActions() {
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        removeButton.addTarget(self, action: #selector(removeTapped), for: .touchUpInside)
    }

    @objc private func viewTapped() {
        guard let request else { return }
        delegate?.didTapView(for: request)
    }

    @objc private func editTapped() {
        guard let request else { return }
        delegate?.didTapEdit(for: request)
    }

    @objc private func removeTapped() {
        guard let request else { return }
        delegate?.didTapRemove(for: request)
    }
}
