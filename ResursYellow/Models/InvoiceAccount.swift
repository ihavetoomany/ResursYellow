//
//  InvoiceAccount.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation

struct InvoiceAccount: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var subtitle: String
    var amount: String
    var progress: Double
    var installmentAmount: String
    var totalAmount: String
    var completedPayments: Int
    var totalPayments: Int
    var nextDueDate: String
    var autopaySource: String
    
    init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        amount: String,
        progress: Double,
        installmentAmount: String = "",
        totalAmount: String = "",
        completedPayments: Int = 0,
        totalPayments: Int = 0,
        nextDueDate: String = "",
        autopaySource: String = ""
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.amount = amount
        self.progress = progress
        self.installmentAmount = installmentAmount
        self.totalAmount = totalAmount
        self.completedPayments = completedPayments
        self.totalPayments = totalPayments
        self.nextDueDate = nextDueDate
        self.autopaySource = autopaySource
    }
}


