//
//  Invoice.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

struct Invoice: Identifiable, Codable, Hashable {
    let id: UUID
    let merchant: String
    let amount: String
    let dueDateOffset: Int // Days from Nov 20, 2025
    let invoiceNumber: String
    let issueDateOffset: Int // Days from Nov 20, 2025
    let status: String
    let colorName: String // "orange", "green", "yellow", "cyan", etc.
    let icon: String?
    let isOverdue: Bool
    var statusOverride: String?
    let category: InvoiceCategory
    
    enum InvoiceCategory: String, Codable {
        case overdue
        case dueSoon
        case handledScheduled
        case handledPaid
    }
    
    var color: Color {
        switch colorName.lowercased() {
        case "orange": return .orange
        case "green": return .green
        case "yellow": return .yellow
        case "cyan": return .cyan
        case "blue": return .blue
        case "red": return .red
        default: return .blue
        }
    }
    
    init(
        id: UUID = UUID(),
        merchant: String,
        amount: String,
        dueDateOffset: Int,
        invoiceNumber: String,
        issueDateOffset: Int,
        status: String,
        colorName: String,
        icon: String? = nil,
        isOverdue: Bool = false,
        statusOverride: String? = nil,
        category: InvoiceCategory
    ) {
        self.id = id
        self.merchant = merchant
        self.amount = amount
        self.dueDateOffset = dueDateOffset
        self.invoiceNumber = invoiceNumber
        self.issueDateOffset = issueDateOffset
        self.status = status
        self.colorName = colorName
        self.icon = icon
        self.isOverdue = isOverdue
        self.statusOverride = statusOverride
        self.category = category
    }
}

