//
//  PendingRequestsCell.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 31/12/2025.
//

import UIKit

// MARK: - Delegate Protocol
protocol PendingRequestCellDelegate: AnyObject {
    func didTapApprove(for request: MaintenanceRequest)
    func didTapView(for request: MaintenanceRequest)
    func didTapDeny(for request: MaintenanceRequest)
}

class PendingRequestCell: UITableViewCell {
    
    // MARK: - Properties
    weak var delegate: PendingRequestCellDelegate?
    private var request: MaintenanceRequest?
    
    // MARK: - UI Components
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 13)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let approveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Approve", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 0.396, green: 0.780, blue: 0.533, alpha: 1.0)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let viewButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("View", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let denyButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Deny", for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 14)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemRed
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
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
        
        contentView.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(locationLabel)
        containerView.addSubview(categoryLabel)
        containerView.addSubview(priorityLabel)
        containerView.addSubview(buttonStackView)
        
        buttonStackView.addArrangedSubview(approveButton)
        buttonStackView.addArrangedSubview(viewButton)
        buttonStackView.addArrangedSubview(denyButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            locationLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            locationLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            categoryLabel.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: 8),
            categoryLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            priorityLabel.centerYAnchor.constraint(equalTo: categoryLabel.centerYAnchor),
            priorityLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            buttonStackView.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 12),
            buttonStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            buttonStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            buttonStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            buttonStackView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func setupActions() {
        approveButton.addTarget(self, action: #selector(approveTapped), for: .touchUpInside)
        viewButton.addTarget(self, action: #selector(viewTapped), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(denyTapped), for: .touchUpInside)
    }
    
    // MARK: - Configure
    func configure(with request: MaintenanceRequest) {
        self.request = request
        
        titleLabel.text = request.titleDisplay
        locationLabel.text = request.locationString
        categoryLabel.text = "Category: \(request.issueCategory)"
        
        // Priority color coding
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
            priorityLabel.textColor = .tertiaryLabel
        }
    }
    
    // MARK: - Actions
    @objc private func approveTapped() {
        guard let request = request else { return }
        delegate?.didTapApprove(for: request)
    }
    
    @objc private func viewTapped() {
        guard let request = request else { return }
        delegate?.didTapView(for: request)
    }
    
    @objc private func denyTapped() {
        guard let request = request else { return }
        delegate?.didTapDeny(for: request)
    }
}
