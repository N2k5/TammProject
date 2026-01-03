//
//  ChatViewController.swift
//  TammLogin
//
//  Created by BP-36-213-09 on 03/01/2026.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

final class ChatViewController: UIViewController {

    private let request: MaintenanceRequest
    private var messages: [ChatMessage] = []
    private var listener: ListenerRegistration?

    private let tableView = UITableView()
    private let inputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)

    init(request: MaintenanceRequest) {
        self.request = request
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Chat"
        view.backgroundColor = .systemBackground
        setupUI()
        listen()
    }

    deinit { listener?.remove() }

    private func setupUI() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ChatBubbleCell.self,
                           forCellReuseIdentifier: ChatBubbleCell.reuseID)
        tableView.dataSource = self
        tableView.separatorStyle = .none

        inputBar.translatesAutoresizingMaskIntoConstraints = false
        inputBar.backgroundColor = .secondarySystemBackground

        textField.placeholder = "Message..."
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false

        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)

        view.addSubview(tableView)
        view.addSubview(inputBar)
        inputBar.addSubview(textField)
        inputBar.addSubview(sendButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputBar.heightAnchor.constraint(equalToConstant: 56),

            textField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),

            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func listen() {
        listener = Firestore.firestore()
            .collection("maintenanceRequests")
            .document(request.id)
            .collection("chats")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self else { return }

                self.messages = snap?.documents.compactMap {
                    ChatMessage(id: $0.documentID, data: $0.data())
                } ?? []

                self.tableView.reloadData()
                self.scroll()
            }
    }

    @objc private func send() {
        guard
            let text = textField.text,
            !text.isEmpty,
            let uid = Auth.auth().currentUser?.uid
        else { return }

        let role = uid == request.userId ? "user" : "staff"

        Firestore.firestore()
            .collection("maintenanceRequests")
            .document(request.id)
            .collection("chats")
            .addDocument(data: [
                "senderId": uid,
                "senderRole": role,
                "text": text,
                "timestamp": Timestamp()
            ])

        textField.text = ""
    }

    private func scroll() {
        guard !messages.isEmpty else { return }
        let index = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: index, at: .bottom, animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        messages.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: ChatBubbleCell.reuseID,
            for: indexPath
        ) as! ChatBubbleCell

        let message = messages[indexPath.row]
        let isMe = message.senderId == Auth.auth().currentUser?.uid
        cell.configure(message: message, isMe: isMe)
        return cell
    }
}
