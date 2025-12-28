//
//  Transaction.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    let dateOffset: Int // Days from Nov 20, 2025
    let description: String
    let amount: String
    let amountColorName: String // "red", "green", etc.
    let merchant: String?
    let paymentMethod: String? // "Resurs Gold", "Bauhaus Invoice", etc.
    let category: TransactionCategory?
    let accountId: UUID? // Link to InvoiceAccount if applicable
    
    enum TransactionCategory: String, Codable {
        case purchase
        case payment
        case refund
        case other
    }
    
    enum TransactionType: String, Codable {
        case purchase
        case payment
        case refund
    }
    
    var amountColor: Color {
        switch amountColorName.lowercased() {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        default: return .primary
        }
    }
    
    init(
        id: UUID = UUID(),
        dateOffset: Int,
        description: String,
        amount: String,
        amountColorName: String,
        merchant: String? = nil,
        paymentMethod: String? = nil,
        category: TransactionCategory? = nil,
        accountId: UUID? = nil
    ) {
        self.id = id
        self.dateOffset = dateOffset
        self.description = description
        self.amount = amount
        self.amountColorName = amountColorName
        self.merchant = merchant
        self.paymentMethod = paymentMethod
        self.category = category
        self.accountId = accountId
    }
}


