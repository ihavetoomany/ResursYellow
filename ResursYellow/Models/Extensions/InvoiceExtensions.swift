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
    /// Converts an Invoice model to InvoiceData for use in InvoiceDetailView.
    /// Upcoming, overdue, and scheduled invoices show due date "Jan 31"; paid show "Dec 31".
    func toInvoiceData(dateService: DateService) -> InvoiceData {
        let dueDate: String
        let issueDate: String
        switch category {
        case .overdue, .dueSoon, .handledScheduled:
            dueDate = dateService.dueDateJan31()
            issueDate = dateService.formatDateOffset(issueDateOffset, format: "MMM d")
        case .handledPaid:
            dueDate = dateService.dueDateDec31()
            issueDate = dateService.dueDateDec31()
        }
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
    
    /// Gets the subtitle string for display in lists. "Jan 31" for overdue/dueSoon/handledScheduled; "Dec 31" for paid. Optional subtitleSuffix (e.g. "(3 600 kr)") is appended after the date.
    func subtitle(dateService: DateService) -> String {
        let dateString: String
        switch category {
        case .overdue, .dueSoon, .handledScheduled:
            dateString = dateService.dueDateJan31()
        case .handledPaid:
            dateString = dateService.dueDateDec31()
        }
        if let suffix = subtitleSuffix, !suffix.isEmpty {
            return "\(dateString) \(suffix)"
        }
        return dateString
    }

    /// Subtitle for list rows. For overdue and due-soon, prefixes the date with "Due " (e.g. "Due Jan 31").
    func listSubtitle(dateService: DateService) -> String {
        let raw = subtitle(dateService: dateService)
        switch category {
        case .overdue, .dueSoon:
            return "Due " + raw
        default:
            return raw
        }
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

