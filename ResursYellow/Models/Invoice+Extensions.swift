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
        let data = toInvoiceData(dateService: dateService)
        return InvoiceItem(
            merchant: merchant,
            subtitle: subtitle(dateService: dateService),
            amount: data.amount,
            icon: icon,
            color: color,
            isOverdue: isOverdue,
            statusOverride: statusOverride,
            category: category.toInvoiceCategory(),
            detail: data
        )
    }
}

// Note: toInvoiceCategory() is defined in InvoiceExtensions.swift to avoid duplication

