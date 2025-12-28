//
//  InvoiceAccountExtensions.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

// MARK: - InvoiceAccount to PartPaymentItem Conversion

extension InvoiceAccount {
    /// Converts an InvoiceAccount model to PartPaymentItem for use in views
    func toPartPaymentItem() -> PartPaymentItem {
        return PartPaymentItem(
            id: id,
            title: title,
            subtitle: subtitle,
            amount: amount,
            progress: progress,
            installmentAmount: installmentAmount,
            totalAmount: totalAmount,
            completedPayments: completedPayments,
            totalPayments: totalPayments,
            nextDueDate: nextDueDate,
            autopaySource: autopaySource
        )
    }
}

// MARK: - PartPaymentItem struct (from BauhausDetailView)

struct PartPaymentItem: Hashable, Identifiable {
    let id: UUID
    var title: String
    var subtitle: String
    var amount: String
    var progress: Double
    var installmentAmount: String = ""
    var totalAmount: String = ""
    var completedPayments: Int = 0
    var totalPayments: Int = 0
    var nextDueDate: String = ""
    var autopaySource: String = ""
    
    var hasDetailedSchedule: Bool {
        !installmentAmount.isEmpty &&
        !totalAmount.isEmpty &&
        totalPayments > 0 &&
        !nextDueDate.isEmpty
    }
}


