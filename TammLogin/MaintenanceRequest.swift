//
//  MaintenanceRequest.swift
//  TammLogin
//
//  Created by BP-36-215-15 on 31/12/2025.
//

import Foundation
import UIKit
import FirebaseFirestore

struct MaintenanceRequest {
    let id: String  // Document ID from Firestore
    let ticketID: String
    let userId: String
    let userEmail: String
    let issueCategory: String
    let priorityLevel: String
    let roomAccessNotes: String
    let timestamp: Date
    var status: String  // "Pending", "Active", "Completed", "Denied"
    let requestTitle: String?
    let building: String?
    let floor: String?
    let roomNo: String?
    let detailedDescription: String?
    let imageURL: String?

    // Staff fields (OPTIONAL)
    let staffID: String?
    let staffEmail: String?
    let staffTimeStamp: Timestamp?

    // Computed properties for display
    var locationString: String {
        var parts: [String] = []
        if let building = building { parts.append("Building: \(building)") }
        if let floor = floor { parts.append("Floor: \(floor)") }
        if let roomNo = roomNo { parts.append("Room: \(roomNo)") }
        return parts.isEmpty ? "No location specified" : parts.joined(separator: ", ")
    }

    var titleDisplay: String {
        return requestTitle ?? "Maintenance Request"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }

    // Initialize from Firestore document
    init?(id: String, data: [String: Any]) {
        guard let ticketID = data["ticketID"] as? String,
              let userId = data["userId"] as? String,
              let userEmail = data["userEmail"] as? String,
              let issueCategory = data["issueCategory"] as? String,
              let priorityLevel = data["priorityLevel"] as? String,
              let roomAccessNotes = data["roomAccessNotes"] as? String,
              let status = data["status"] as? String else {
            return nil
        }

        self.id = id
        self.ticketID = ticketID
        self.userId = userId
        self.userEmail = userEmail
        self.issueCategory = issueCategory
        self.priorityLevel = priorityLevel
        self.roomAccessNotes = roomAccessNotes
        self.status = status

        // Handle timestamp
        if let timestamp = data["timestamp"] as? Timestamp {
            self.timestamp = timestamp.dateValue()
        } else {
            self.timestamp = Date()
        }

        self.requestTitle = data["requestTitle"] as? String
        self.building = data["building"] as? String
        self.floor = data["floor"] as? String
        self.roomNo = data["roomNo"] as? String
        self.detailedDescription = data["detailedDescription"] as? String
        self.imageURL = data["imageURL"] as? String

        // Staff fields
        self.staffID = data["staffID"] as? String
        self.staffEmail = data["staffEmail"] as? String
        self.staffTimeStamp = data["staffTimeStamp"] as? Timestamp
    }
}
