//
//  InvoiceExtensions.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

// MARK: - Invoice Conversion Helpers

extension Invoice {
    /// Converts an Invoice model to InvoiceData for use in InvoiceDetailView
    func toInvoiceData(dateService: DateService) -> InvoiceData {
        let dueDate = dateService.formatDateOffset(dueDateOffset)
        let issueDate = dateService.formatDateOffset(issueDateOffset)
        
        return InvoiceData(
            merchant: merchant,
            amount: detailAmount ?? amount,
            dueDate: dueDate,
            invoiceNumber: invoiceNumber,
            issueDate: issueDate,
            status: status,
            color: color
        )
    }
    
    /// Gets the subtitle string for display in lists
    func subtitle(dateService: DateService) -> String {
        return dateService.formatDateOffset(issueDateOffset)
    }
}

extension Invoice.InvoiceCategory {
    /// Converts Invoice.InvoiceCategory to PaymentsView's InvoiceCategory
    func toInvoiceCategory() -> InvoiceCategory {
        switch self {
        case .overdue:
            return .overdue
        case .dueSoon:
            return .dueSoon
        case .handledScheduled:
            return .handledScheduled
        case .handledPaid:
            return .handledPaid
        }
    }
}

