//
//  TransactionExtensions.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

// MARK: - Transaction Conversion Helpers

extension Transaction {
    /// Converts a Transaction to TransactionData for use in TransactionDetailView
    func toTransactionData(dateService: DateService) -> TransactionData? {
        guard let paymentMethodString = paymentMethod,
              let paymentMethod = PaymentMethod(rawValue: paymentMethodString) else {
            return nil
        }
        
        let dateStr = dateService.formatRelativeDate(offset: dateOffset)
        let timeStr = dateService.formatDate(dateService.relativeDate(offset: dateOffset), format: "h:mm a")
        
        return TransactionData(
            merchant: merchant ?? description,
            amount: amount,
            date: dateStr,
            time: timeStr,
            paymentMethod: paymentMethod
        )
    }
    
    /// Gets payment method from transaction, inferring if needed
    func inferredPaymentMethod() -> PaymentMethod {
        if let paymentMethodString = paymentMethod,
           let method = PaymentMethod(rawValue: paymentMethodString) {
            return method
        }
        
        // Infer from merchant name
        let merchantName = (merchant ?? description).lowercased()
        if merchantName.contains("bauhaus") {
            return .bauhausInvoice
        } else if merchantName.contains("netonnet") {
            return .netonnetAccount
        } else if merchantName.contains("jula") {
            return .julaAccount
        } else {
            return .resursFamily
        }
    }
    
    /// Determines icon and color for a merchant
    func iconAndColor() -> (String, Color) {
        let merchantName = (merchant ?? description).lowercased()
        
        if merchantName.contains("bauhaus") {
            return ("hammer.fill", .orange)
        } else if merchantName.contains("netonnet") {
            return ("bolt.fill", .blue)
        } else if merchantName.contains("jula") {
            return ("wrench.and.screwdriver", .red)
        } else if merchantName.contains("clas") || merchantName.contains("ohlson") {
            return ("lightbulb.fill", .yellow)
        } else if merchantName.contains("elgiganten") {
            return ("display.2", .green)
        } else if merchantName.contains("lyko") {
            return ("drop.fill", .pink)
        } else if merchantName.contains("ica") || merchantName.contains("willys") {
            return ("cart.fill", .brown)
        } else if merchantName.contains("stadium") {
            return ("sportscourt.fill", .purple)
        } else {
            return ("cart.fill", .blue)
        }
    }
    
    /// Determines purchase category based on amount
    func purchaseCategory() -> PurchaseCategory {
        let numericAmount = parseAmount(amount)
        
        if numericAmount >= 5000 {
            return .large
        } else if numericAmount >= 1000 {
            return .shopping
        } else {
            return .recent
        }
    }
    
    private func parseAmount(_ amountString: String) -> Double {
        let cleaned = amountString
            .replacingOccurrences(of: "kr", with: "")
            .replacingOccurrences(of: "SEK", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned) ?? 0
    }
    
    /// Converts a Transaction to TransactionItem for use in InvoiceAccountDetailView
    func toTransactionItem(dateService: DateService) -> TransactionItem {
        let dateStr = dateService.formatDateOffset(dateOffset)
        return TransactionItem(
            id: id,
            date: dateStr,
            description: description,
            amount: amount,
            amountColor: amountColor
        )
    }
}

// MARK: - TransactionItem struct (from InvoiceAccountDetailView)

struct TransactionItem: Identifiable {
    let id: UUID
    let date: String
    let description: String
    let amount: String
    let amountColor: Color
}

