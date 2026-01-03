//
//  RequestFullDetailsViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 31/12/2025.
//

import UIKit

class RequestFullDetailsViewController: UIViewController {

    private let request: MaintenanceRequest

    init(request: MaintenanceRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Details"

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        addRow("Ticket ID", request.ticketID, to: stack)
        addRow("Access Notes", request.roomAccessNotes, to: stack)
        addRow("User Email", request.userEmail, to: stack)
        addRow("Date", request.formattedDate, to: stack)

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func addRow(_ title: String, _ value: String, to stack: UIStackView) {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 14)

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.numberOfLines = 0
        valueLabel.font = .systemFont(ofSize: 14)

        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(valueLabel)
    }
}
