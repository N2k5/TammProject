//
//  RequestSummaryViewController.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 31/12/2025.
//

import UIKit

class RequestSummaryViewController: UIViewController {

    private let request: MaintenanceRequest

    // UI
    private let titleLabel = UILabel()
    private let locationLabel = UILabel()
    private let imageView = UIImageView()
    private let viewDetailsButton = UIButton(type: .system)
    private let categoryLabel = UILabel()
    private let priorityLabel = UILabel()
    private let descriptionLabel = UILabel()

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
        populate()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = ""

        titleLabel.font = .boldSystemFont(ofSize: 24)
        titleLabel.textColor = .systemBlue
        
        categoryLabel.font = .systemFont(ofSize: 16, weight: .medium)
        categoryLabel.textColor = .label
        
        priorityLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        priorityLabel.textColor = .secondaryLabel

        locationLabel.font = .systemFont(ofSize: 16)
        locationLabel.textColor = .secondaryLabel
        locationLabel.numberOfLines = 0
        
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0

        imageView.backgroundColor = .secondarySystemBackground
        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        viewDetailsButton.setTitle("View Details", for: .normal)
        viewDetailsButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        viewDetailsButton.addTarget(self, action: #selector(viewDetailsTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            titleLabel,
            categoryLabel,
            priorityLabel,
            locationLabel,
            descriptionLabel,
            imageView,
            viewDetailsButton
        ])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func populate() {
        titleLabel.text = request.titleDisplay
        categoryLabel.text = "Category: \(request.issueCategory)"
        priorityLabel.text = "Priority: \(request.priorityLevel)"
        locationLabel.text = "Location: \(request.locationString)"
        descriptionLabel.text = request.detailedDescription ?? "No description provided"

        if let urlString = request.imageURL,
           let url = URL(string: urlString) {
            loadImage(from: url)
        }
    }

    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }.resume()
    }

    @objc private func viewDetailsTapped() {
        let vc = RequestFullDetailsViewController(request: request)
        navigationController?.pushViewController(vc, animated: true)
    }
}
