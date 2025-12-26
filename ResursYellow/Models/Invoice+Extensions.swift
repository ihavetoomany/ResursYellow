//
//  Invoice+Extensions.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

extension Invoice {
    func toInvoiceItem(dateService: DateService) -> InvoiceItem {
        let dueDate = dateService.formatDateOffset(dueDateOffset)
        let issueDate = dateService.formatDateOffset(issueDateOffset)
        
        return InvoiceItem(
            merchant: merchant,
            subtitle: dueDate,
            amount: amount,
            icon: icon,
            color: color,
            isOverdue: isOverdue,
            statusOverride: statusOverride,
            category: category.toInvoiceCategory(),
            detail: InvoiceData(
                merchant: merchant,
                amount: amount,
                dueDate: dueDate,
                invoiceNumber: invoiceNumber,
                issueDate: issueDate,
                status: status,
                color: color
            )
        )
    }
}

// Note: toInvoiceCategory() is defined in InvoiceExtensions.swift to avoid duplication

