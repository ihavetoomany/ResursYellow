//
//  PaymentPlansManager.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-11-03.
//

import SwiftUI
import Combine

struct PaymentPlan: Identifiable {
    let id = UUID()
    let name: String
    let totalAmount: String
    let paidAmount: String
    let progress: Double
    let dueDate: String
    let monthlyAmount: String?
    let icon: String
    let color: Color
}

class PaymentPlansManager: ObservableObject {
    @Published var paymentPlans: [PaymentPlan] = [
        PaymentPlan(
            name: "Home Office Setup",
            totalAmount: "18 200 SEK",
            paidAmount: "6 000 SEK",
            progress: 0.33,
            dueDate: "Paid off in 6 months",
            monthlyAmount: "2 000 SEK/month",
            icon: "doc.text.fill",
            color: .purple
        ),
        PaymentPlan(
            name: "New Kitchen Appliances",
            totalAmount: "28 500 SEK",
            paidAmount: "25 650 SEK",
            progress: 0.9,
            dueDate: "1 payment left",
            monthlyAmount: "2 850 SEK/month",
            icon: "doc.text.fill",
            color: .green
        )
    ]
    
    func addPaymentPlan(name: String, startingAmount: String) {
        let newPaymentPlan = PaymentPlan(
            name: name,
            totalAmount: startingAmount,
            paidAmount: "0 SEK",
            progress: 0.0,
            dueDate: "Just created",
            monthlyAmount: nil,
            icon: "tray.fill",
            color: .blue
        )
        paymentPlans.insert(newPaymentPlan, at: 0) // Insert at the beginning
    }
}

