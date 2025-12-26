//
//  Transaction+Extensions.swift
//  ResursYellow
//
//  Created on 2025-12-26.
//

import Foundation
import SwiftUI

extension Transaction {
    func toPurchaseItem(dateService: DateService) -> PurchaseItem? {
        guard let merchant = merchant else { return nil }
        
        // Determine icon and color based on merchant
        let (icon, color): (String, Color) = {
            switch merchant.lowercased() {
            case let m where m.contains("bauhaus"):
                return ("hammer.fill", .orange)
            case let m where m.contains("netonnet") || m.contains("netonnet"):
                return ("bolt.fill", .blue)
            case let m where m.contains("jula"):
                return ("wrench.and.screwdriver", .red)
            case let m where m.contains("clas"):
                return ("lightbulb.fill", .yellow)
            case let m where m.contains("elgiganten"):
                return ("display.2", .green)
            case let m where m.contains("lyko"):
                return ("drop.fill", .pink)
            case let m where m.contains("ica"):
                return ("cart.fill", .brown)
            case let m where m.contains("willys"):
                return ("cart.circle.fill", .teal)
            case let m where m.contains("stadium"):
                return ("sportscourt.fill", .purple)
            default:
                return ("creditcard.fill", .blue)
            }
        }()
        
        // Determine category
        let purchaseCategory: PurchaseCategory = {
            if amountColorName == "red" && category == .purchase {
                return .large
            }
            return .shopping
        }()
        
        // Determine payment method
        let paymentMethod: PaymentMethod = {
            if let pm = self.paymentMethod {
                switch pm {
                case "Resurs Gold": return .resursFamily
                case "Bauhaus Invoice": return .bauhausInvoice
                case "Netonnet Account": return .netonnetAccount
                case "Jula Account": return .julaAccount
                case "Swish": return .swish
                default: return .resursFamily
                }
            }
            return .resursFamily
        }()
        
        let dateStr = dateService.formatRelativeDate(offset: dateOffset)
        let subtitle = "\(dateStr) - Location"
        
        return PurchaseItem(
            title: description,
            merchant: merchant,
            subtitle: subtitle,
            amount: amount,
            icon: icon,
            color: color,
            category: purchaseCategory,
            paymentMethod: paymentMethod,
            transaction: TransactionData(
                merchant: merchant,
                amount: amount,
                date: dateStr,
                time: "Time",
                paymentMethod: paymentMethod
            )
        )
    }
    
    // Note: toTransactionItem() is defined in TransactionExtensions.swift to avoid duplication
}

