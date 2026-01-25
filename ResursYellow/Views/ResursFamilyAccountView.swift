//
//  ResursFamilyAccountView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-11-02.
//

import SwiftUI
import Combine

struct ResursFamilyAccountView: View {
    @StateObject private var dataManager = DataManager.shared
    
    // Invoice Accounts - Resurs Gold's own payment plans (filtered from DataManager)
    private var invoiceAccounts: [PartPaymentItem] {
        // Filter invoice accounts for Resurs Gold (autopaySource contains "Resurs Gold" or "Mastercard")
        dataManager.invoiceAccounts
            .filter { account in
                account.autopaySource.lowercased().contains("resurs gold") ||
                account.autopaySource.lowercased().contains("mastercard")
            }
            .map { $0.toPartPaymentItem() }
    }
    
    // Benefits for Resurs Family
    private let benefits: [(icon: String, title: String, desc: String)] = [
        ("calendar.badge.clock", "Flexible Payments", "Choose flexible part payment plans for large purchases."),
        ("creditcard.fill", "Easy Checkout", "Use your Resurs Family card for quick and secure payments."),
        ("heart.fill", "Family Sharing", "Share your credit account with family members."),
        ("shield.checkerboard", "Payment Protection", "Protect your purchases with optional payment insurance.")
    ]
    
    // Documents for Resurs Family
    private let documents: [(icon: String, titleKey: String, descKey: String)] = [
        ("doc.text.fill", "Credit Agreement", "View your credit account terms and conditions"),
        ("doc.text", "Terms and Conditions", "Read the terms and conditions for Resurs Family"),
        ("hand.raised.fill", "Privacy Policy", "Review how we handle your personal information"),
        ("doc.on.doc.fill", "Payment Plan Agreement", "View your active payment plan agreements")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                // Account Overview Card
                AccountOverviewCard()
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                    
                // Credit Cards Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cards")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        VStack(spacing: 12) {
                            CreditCardMini(
                                holder: "Jane Doe",
                                lastFour: "1234",
                                used: "13 000 SEK",
                                color: .green
                            )
                            
                            CreditCardMini(
                                holder: "John Doe",
                                lastFour: "5678",
                                used: "10 995 SEK",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                // Purchases Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Purchases")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Handle "View all" tap
                            }) {
                                Text("View all")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        VStack(spacing: 12) {
                            PurchaseRow(
                                title: "Elgiganten",
                                subtitle: "Today - Stockholm",
                                amount: "5 699 kr",
                                icon: "display.2",
                                color: .green,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: true
                            )
                            
                            PurchaseRow(
                                title: "ICA Maxi",
                                subtitle: "Yesterday - Lund",
                                amount: "1 245 kr",
                                icon: "cart.fill",
                                color: .brown,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: false
                            )
                            
                            PurchaseRow(
                                title: "Stadium Outlet",
                                subtitle: "2 days ago - Orebro",
                                amount: "1 080 kr",
                                icon: "sportscourt.fill",
                                color: .purple,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: false
                            )
                            
                            PurchaseRow(
                                title: "Clas Ohlson",
                                subtitle: "3 days ago - Malmo",
                                amount: "890 kr",
                                icon: "lightbulb.fill",
                                color: .yellow,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: false
                            )
                            
                            PurchaseRow(
                                title: "Åhléns",
                                subtitle: "1 week ago - Stockholm",
                                amount: "2 450 kr",
                                icon: "bag.fill",
                                color: .pink,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: true
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                // Invoice Accounts Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Accounts")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Handle "View all" tap
                            }) {
                                Text("View all")
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        VStack(spacing: 12) {
                            ForEach(invoiceAccounts) { payment in
                                NavigationLink(value: payment) {
                                    ResursGoldPartPaymentRow(payment: payment, showsDisclosure: true)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                // Benefits Section
                VStack(alignment: .leading, spacing: 16) {
                        Text("Benefits and services")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 4)
                            .padding(.top, 12)
                        VStack(spacing: 12) {
                            ForEach(benefits, id: \.title) { benefit in
                                HStack(spacing: 16) {
                                    Image(systemName: benefit.icon)
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.15))
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(benefit.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(benefit.desc)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                // Documents Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Documents".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                        .padding(.top, 12)
                    VStack(spacing: 12) {
                        ForEach(Array(documents.enumerated()), id: \.offset) { index, document in
                            Button(action: {
                                // Handle document tap - could navigate to document detail view
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: document.icon)
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.15))
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(document.titleKey.localized)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        Text(document.descKey.localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Resurs Family")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(for: PartPaymentItem.self) { account in
            InvoiceAccountDetailView(account: account)
        }
    }
}

struct ResursGoldPartPaymentRow: View {
    let payment: PartPaymentItem
    let showsDisclosure: Bool
    
    private func calculateUsedCredit(completedPayments: Int, installmentAmount: String) -> String {
        // Extract numeric value from installmentAmount (e.g., "5 326 kr" -> 5326)
        let cleaned = installmentAmount
            .replacingOccurrences(of: "kr", with: "")
            .replacingOccurrences(of: "SEK", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
        if let amount = Double(cleaned) {
            let totalUsed = amount * Double(completedPayments)
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = " "
            formatter.maximumFractionDigits = 0
            if let formatted = formatter.string(from: NSNumber(value: totalUsed)) {
                return "\(formatted) kr"
            }
        }
        return "0 kr"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(payment.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            
            if payment.amount.contains("left to pay") {
                let components = payment.amount.components(separatedBy: " left to pay")
                let amountValue = components.first ?? payment.amount
                HStack(spacing: 4) {
                    Text(amountValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("left to pay")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            } else if payment.title == "Main Account" || payment.title == "Flex August" {
                HStack(spacing: 4) {
                    Text("Debt:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(payment.amount)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .padding(.top, 8)
            } else {
                Text(payment.amount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            ProgressView(value: payment.progress)
                .tint(payment.title == "Main Account" ? .green : .blue)
            
            HStack {
                if payment.title == "Main Account" {
                    Text(payment.amount == "0 kr" ? "All purchases are paid" : "Options available on next invoice")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if payment.title == "Flex August" {
                    Text("Part payment ongoing")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("\(payment.completedPayments) of \(payment.totalPayments) payments")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if !(payment.title == "Main Account" && payment.amount == "0 kr") {
                    Text(payment.nextDueDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AccountOverviewCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Credit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("56 005 SEK")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Limit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("80 000 SEK")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 30)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Used Credit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("23 995 SEK")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CreditCardMini: View {
    let holder: String
    let lastFour: String
    let used: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(holder)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("•••• \(lastFour)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(used)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Used")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    ResursFamilyAccountView()
        .preferredColorScheme(.dark)
}

