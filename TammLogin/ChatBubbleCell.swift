//
//  ChatBubbleCell.swift
//  TammLogin
//
//  Created by BP-36-213-09 on 03/01/2026.
//

import UIKit

final class ChatBubbleCell: UITableViewCell {

    static let reuseID = "ChatBubbleCell"

    private let bubbleLabel = PaddingLabel()
    private var leading: NSLayoutConstraint!
    private var trailing: NSLayoutConstraint!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear

        bubbleLabel.numberOfLines = 0
        bubbleLabel.layer.cornerRadius = 16
        bubbleLabel.clipsToBounds = true
        bubbleLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleLabel.font = .systemFont(ofSize: 16)

        contentView.addSubview(bubbleLabel)

        leading = bubbleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        trailing = bubbleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        NSLayoutConstraint.activate([
            bubbleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            bubbleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            bubbleLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            leading
        ])
    }

    func configure(message: ChatMessage, isMe: Bool) {
        bubbleLabel.text = message.text
        bubbleLabel.backgroundColor = isMe ? .systemBlue : .systemGray5
        bubbleLabel.textColor = isMe ? .white : .label

        leading.isActive = !isMe
        trailing.isActive = isMe
    }
}
