//
//  ChatMessage.swift
//  TammLogin
//
//  Created by BP-36-213-09 on 03/01/2026.
//

import FirebaseFirestore

struct ChatMessage {
    let id: String
    let senderId: String
    let senderRole: String
    let text: String
    let timestamp: Timestamp

    init?(id: String, data: [String: Any]) {
        guard
            let senderId = data["senderId"] as? String,
            let senderRole = data["senderRole"] as? String,
            let text = data["text"] as? String,
            let timestamp = data["timestamp"] as? Timestamp
        else { return nil }

        self.id = id
        self.senderId = senderId
        self.senderRole = senderRole
        self.text = text
        self.timestamp = timestamp
    }
}
