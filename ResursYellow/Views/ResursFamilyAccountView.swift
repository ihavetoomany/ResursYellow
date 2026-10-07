//
//  ResursFamilyAccountView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-11-02.
//

import SwiftUI
import Combine

// MARK: - Adaptive Card Background
private struct AdaptiveCardBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .light {
            Color.white
        } else {
            Color.clear.background(.regularMaterial)
        }
    }
}

/// The Resurs credit products that share this detail screen.
struct ResursCreditProduct {
    let title: String
    let available: String
    let limit: String
    let used: String
    let icon: String
    let tint: Color
    /// Family-only extras (family sharing benefit, settings copy)
    let isFamily: Bool

    static let family = ResursCreditProduct(title: "Resurs Family", available: "56 005 SEK", limit: "80 000 SEK", used: "23 995 SEK", icon: "heart.fill", tint: .blue, isFamily: true)
    // Figures match the Resurs Gold wallet card (31 500 kr available)
    static let gold = ResursCreditProduct(title: "Resurs Gold", available: "31 500 SEK", limit: "50 000 SEK", used: "18 500 SEK", icon: "creditcard.fill", tint: RyColor.primaryMain, isFamily: false)
}

struct ResursFamilyAccountView: View {
    var product: ResursCreditProduct = .family
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var showSettings = false
    @Environment(\.colorScheme) var colorScheme
    
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
    
    // Benefits (family sharing only for Resurs Family)
    private var benefits: [(icon: String, title: String, desc: String)] {
        var list: [(icon: String, title: String, desc: String)] = [
            ("calendar.badge.clock", "Flexible Payments".localized, "Choose flexible part payment plans for large purchases.".localized),
            ("creditcard.fill", "Easy Checkout".localized, String(format: "Use your %@ card for quick and secure payments.".localized, product.title))
        ]
        if product.isFamily {
            list.append(("heart.fill", "Family Sharing".localized, "Share your credit account with family members.".localized))
        }
        list.append(("shield.checkerboard", "Payment Protection".localized, "Protect your purchases with optional payment insurance.".localized))
        return list
    }
    
    // Documents
    private var documents: [(icon: String, titleKey: String, descKey: String)] { [
        ("doc.text.fill", "Credit Agreement", "View your credit account terms and conditions"),
        ("doc.text", "Terms and Conditions", String(format: "Read the terms and conditions for %@".localized, product.title)),
        ("hand.raised.fill", "Privacy Policy", "Review how we handle your personal information"),
        ("doc.on.doc.fill", "Payment Plan Agreement", "View your active payment plan agreements")
    ] }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Extended background for navigation bar area
            if colorScheme == .light {
                Color(white: 0.93) // Neutral grey
                    .ignoresSafeArea()
            } else {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Scroll offset tracker
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.frame(in: .named("scroll")).minY) { _, newValue in
                                scrollObserver.offset = max(0, -newValue)
                            }
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: 16) {
                    // Account Overview Card
                    AccountOverviewCard(product: product)
                        .padding(.horizontal)
                        .padding(.top, 4)
                        .padding(.bottom, 16)
                    
                // Purchases Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Purchases".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Handle "View all" tap
                            }) {
                                Text("View all".localized)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        
                        VStack(spacing: 12) {
                            PurchaseRow(
                                title: "Elgiganten",
                                subtitle: "Today - Stockholm".localized,
                                amount: "5 699 kr",
                                icon: "display.2",
                                color: .green,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: true,
                                showsPaymentMethodLine: false
                            )
                            
                            PurchaseRow(
                                title: "ICA Maxi",
                                subtitle: "Yesterday - Lund".localized,
                                amount: "1 245 kr",
                                icon: "cart.fill",
                                color: .brown,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: false,
                                showsPaymentMethodLine: false
                            )
                            
                            PurchaseRow(
                                title: "Stadium Outlet",
                                subtitle: "2 days ago - Orebro".localized,
                                amount: "1 080 kr",
                                icon: "sportscourt.fill",
                                color: .purple,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: false,
                                showsPaymentMethodLine: false
                            )
                            
                            PurchaseRow(
                                title: "Clas Ohlson",
                                subtitle: "3 days ago - Malmo".localized,
                                amount: "890 kr",
                                icon: "lightbulb.fill",
                                color: .yellow,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: false,
                                showsPaymentMethodLine: false
                            )
                            
                            PurchaseRow(
                                title: "Åhléns",
                                subtitle: "1 week ago - Stockholm".localized,
                                amount: "2 450 kr",
                                icon: "bag.fill",
                                color: .pink,
                                paymentMethod: .resursFamily,
                                showsPartPayBadge: true,
                                showsPaymentMethodLine: false
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                // Invoice Accounts Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Accounts".localized)
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Handle "View all" tap
                            }) {
                                Text("View all".localized)
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
                    
                // Credit Cards Section
                VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cards".localized)
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
                    
                // Benefits Section
                VStack(alignment: .leading, spacing: 16) {
                        Text("Benefits and services".localized)
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
                                .background(AdaptiveCardBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                    
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
                                .background(AdaptiveCardBackground())
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                
                // Help and Support Section - HIG: Consistent support access
                HelpAndSupportSection()
                    .padding(.horizontal)
                }
                .padding(.vertical, 24)
            }
            .containerRelativeFrame(.horizontal) // pin content to the viewport width: no sideways drag
            }
            .coordinateSpace(name: "scroll")
        }
        .navigationTitle(product.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(scrollObserver.offset > 10 ? Color(uiColor: .systemBackground) : Color.clear, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .shadow(color: scrollObserver.offset > 10 ? .black.opacity(0.1) : .clear, radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSettings) {
            ServiceSettingsView(serviceName: product.title, serviceColor: product.tint)
                .presentationBackground {
                    AdaptiveSheetBackground()
                }
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
                    Text(payment.title.localized)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(payment.subtitle.localized)
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
                    Text("left to pay".localized)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            } else if payment.title == "Main Account" || payment.title == "Part Payment AUG" || payment.title == "Emergency Buffer" {
                HStack(spacing: 4) {
                    Text(payment.title == "Emergency Buffer" ? "Savings:".localized : "Debt:".localized)
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
                .tint(payment.title == "Main Account" ? .green : payment.title == "Emergency Buffer" ? .orange : .blue)
            
            HStack {
                if payment.title == "Main Account" {
                    Text(payment.amount == "0 kr" ? "All purchases are paid".localized : "Options available on next invoice".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if payment.title == "Emergency Buffer" {
                    Text(payment.installmentAmount.isEmpty ? "Reserved for unexpected expenses".localized : String(format: "%@ monthly".localized, payment.installmentAmount))
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if payment.title == "Part Payment AUG" {
                    Text("Part payment ongoing".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text(String(format: "%d of %d payments".localized, payment.completedPayments, payment.totalPayments))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if payment.title == "Emergency Buffer" {
                    Text(payment.totalAmount)
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if !(payment.title == "Main Account" && payment.amount == "0 kr") {
                    Text(payment.nextDueDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(16)
        .background(AdaptiveCardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AccountOverviewCard: View {
    var product: ResursCreditProduct = .family
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Credit".localized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(product.available)
                        .font(.system(size: 32, weight: .bold))
                }
                
                Spacer()
                
                Image(systemName: product.icon)
                    .font(.title)
                    .foregroundColor(product.tint)
                    .frame(width: 56, height: 56)
                    .background(product.tint.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Limit".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(product.limit)
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 30)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Used Credit".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(product.used)
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
        .background(AdaptiveCardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CreditCardMini: View {
    let holder: String
    let lastFour: String
    let used: String
    let color: Color
    @Environment(\.colorScheme) var colorScheme
    
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
                Text("Used".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(AdaptiveCardBackground())
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ResursFamilyAccountView()
        .preferredColorScheme(.dark)
}
