//
//  MyTaskCell.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 01/01/2026.
//

import UIKit

protocol MyTaskCellDelegate: AnyObject {
    func didTapView(for request: MaintenanceRequest)
    func didTapFinish(for request: MaintenanceRequest)
    func didTapChat(for request: MaintenanceRequest)
}

final class MyTaskCell: UITableViewCell {

    static let reuseID = "MyTaskCell"

    weak var delegate: MyTaskCellDelegate?
    private var request: MaintenanceRequest?

    private let containerView = UIView()
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let categoryLabel = UILabel()
    private let priorityLabel = UILabel()

    private let viewButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("View", for: .normal)
        b.backgroundColor = .systemBlue
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        return b
    }()

    private let finishButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Finish", for: .normal)
        b.backgroundColor = .systemGreen
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 8
        return b
    }()

    private let chatButton: UIButton = {
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

        let stack = UIStackView(arrangedSubviews: [
            finishButton,
            viewButton,
            chatButton
        ])
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
            locationLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

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

    private func setupActions() {
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        finishButton.addTarget(self, action: #selector(finishTapped), for: .touchUpInside)
        chatButton.addTarget(self, action: #selector(chatTapped), for: .touchUpInside)
    }

    func configure(with request: MaintenanceRequest) {
        self.request = request
        titleLabel.text = request.titleDisplay
        locationLabel.text = request.locationString
        categoryLabel.text = "Category: \(request.issueCategory)"
        priorityLabel.text = request.priorityLevel
        chatButton.isHidden = request.status != "Active"
    }

    @objc private func viewTapped() {
        guard let request else { return }
        delegate?.didTapView(for: request)
    }

    @objc private func finishTapped() {
        guard let request else { return }
        delegate?.didTapFinish(for: request)
    }

    @objc private func chatTapped() {
        guard let request else { return }
        delegate?.didTapChat(for: request)
    }
}
