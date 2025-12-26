//
//  WalletView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI
import UIKit

private struct VisibleCardInfo: Equatable {
    let index: Int
    let minX: CGFloat
}

private struct VisibleCardPreferenceKey: PreferenceKey {
    static var defaultValue: [VisibleCardInfo] = []
    static func reduce(value: inout [VisibleCardInfo], nextValue: () -> [VisibleCardInfo]) {
        value.append(contentsOf: nextValue())
    }
}

private func availableSymbol(_ preferred: String, fallback: String) -> String {
    if UIImage(systemName: preferred) != nil {
        return preferred
    }
    return fallback
}

private let sekNumberFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.groupingSeparator = " "
    formatter.maximumFractionDigits = 0
    return formatter
}()

private func formattedSEK(_ value: Double) -> String {
    let formatted = sekNumberFormatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
    return "\(formatted) SEK"
}

struct CreditAccount: Identifiable {
    let id = UUID()
    let name: String
    let available: Double
    let limit: Double
    
    var availableLabel: String {
        formattedSEK(available)
    }
    
    var limitLabel: String {
        formattedSEK(limit)
    }
}

extension CreditAccount {
    static let sampleAccounts: [CreditAccount] = [
        CreditAccount(name: "Resurs Gold", available: 15_000, limit: 30_000)
    ]
}

struct ActionItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    static let allItems: [ActionItem] = [
        ActionItem(
            title: "Connect Bank Account",
            subtitle: "Link your bank",
            icon: "building.columns.fill",
            color: .blue
        ),
        ActionItem(
            title: "Complete Loan Application",
            subtitle: "Finish your application",
            icon: "doc.text.fill",
            color: .orange
        ),
        ActionItem(
            title: "Update KYC",
            subtitle: "Verify your identity",
            icon: "person.text.rectangle.fill",
            color: .purple
        ),
        ActionItem(
            title: "Activate Click to Pay",
            subtitle: "Enable quick payments",
            icon: "hand.tap.fill",
            color: .cyan
        ),
        ActionItem(
            title: "Enable Biometric Login",
            subtitle: "Use Face ID for quick access",
            icon: "faceid",
            color: .green
        ),
        ActionItem(
            title: "Review Spending Report",
            subtitle: "See monthly trends",
            icon: "chart.pie.fill",
            color: .pink
        )
    ]
    
    static let priorityItems: [ActionItem] = Array(allItems.prefix(5))
}

struct TransactionData: Hashable {
    let merchant: String
    let amount: String
    let date: String
    let time: String
    let paymentMethod: PaymentMethod
    
    init(
        merchant: String,
        amount: String,
        date: String,
        time: String,
        paymentMethod: PaymentMethod
    ) {
        if !paymentMethod.isValid(for: merchant) {
            assertionFailure("Payment method \(paymentMethod.rawValue) cannot be used with merchant \(merchant)")
        }
        self.merchant = merchant
        self.amount = amount
        self.date = date
        self.time = time
        self.paymentMethod = paymentMethod.isValid(for: merchant) ? paymentMethod : .resursFamily
    }
}

enum PaymentMethod: String, CaseIterable, Identifiable {
    case swish = "Swish"
    case resursFamily = "Resurs Gold"
    case bauhausInvoice = "Bauhaus Invoice"
    case bauhausAccount = "Bauhaus Account"
    case netonnetAccount = "Netonnet Account"
    case julaAccount = "Jula Account"
    
    var id: String { rawValue }
    
    var displayName: String {
        rawValue
    }
    
    var iconName: String {
        switch self {
        case .swish:
            return "arrow.triangle.2.circlepath.circle.fill"
        case .resursFamily:
            return "heart.fill"
        case .bauhausInvoice:
            return "doc.text.fill"
        case .bauhausAccount:
            return "building.columns"
        case .netonnetAccount:
            return "bolt.fill"
        case .julaAccount:
            return "shippingbox.fill"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .swish:
            return .green
        case .resursFamily:
            return .blue
        case .bauhausInvoice:
            return .orange
        case .bauhausAccount:
            return Color(red: 1.0, green: 0.65, blue: 0.3)
        case .netonnetAccount:
            return .indigo
        case .julaAccount:
            return .red
        }
    }
    
    func isValid(for merchant: String) -> Bool {
        let normalizedMerchant = merchant.lowercased()
        switch self {
        case .bauhausInvoice, .bauhausAccount:
            return normalizedMerchant.contains("bauhaus")
        case .netonnetAccount:
            return normalizedMerchant.contains("netonnet")
        case .julaAccount:
            return normalizedMerchant.contains("jula")
        default:
            return true
        }
    }
}

extension PaymentMethod {
    var isMerchantAccount: Bool {
        switch self {
        case .bauhausInvoice, .bauhausAccount, .netonnetAccount, .julaAccount:
            return true
        default:
            return false
        }
    }
    
    var supportsPartPayConversion: Bool {
        switch self {
        case .swish:
            return false
        default:
            return true
        }
    }
}

enum InvoiceCategory {
    case overdue
    case dueSoon
    case handledScheduled
    case handledPaid
}

struct InvoiceItem: Identifiable {
    let id = UUID()
    let merchant: String
    let subtitle: String
    let amount: String
    let icon: String?
    let color: Color
    let isOverdue: Bool
    var statusOverride: String?
    let category: InvoiceCategory
    let detail: InvoiceData
    var isSelected: Bool = false
    
    var numericAmount: Double {
        let cleaned = amount
            .replacingOccurrences(of: "kr", with: "")
            .replacingOccurrences(of: "SEK", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned) ?? 0
    }
}

extension InvoiceItem {
    static var overdueSamples: [InvoiceItem] {
        [
            InvoiceItem(
                merchant: "Bauhaus",
                subtitle: "Nov 7, 2025",
                amount: "726 kr",
                icon: nil,
                color: .orange,
                isOverdue: true,
                statusOverride: nil,
                category: .overdue,
                detail: InvoiceData(
                    merchant: "Bauhaus",
                    amount: "726 kr",
                    dueDate: "Nov 7, 2025",
                    invoiceNumber: "INV-2025-11-001",
                    issueDate: "Nov 7, 2025",
                    status: "Overdue by 2 days",
                    color: .orange
                )
            ),
            InvoiceItem(
                merchant: "Gekås",
                subtitle: "Oct 25, 2025",
                amount: "895 SEK",
                icon: nil,
                color: .orange,
                isOverdue: true,
                statusOverride: nil,
                category: .overdue,
                detail: InvoiceData(
                    merchant: "Gekås",
                    amount: "895 SEK",
                    dueDate: "Nov 8, 2025",
                    invoiceNumber: "INV-2025-10-052",
                    issueDate: "Oct 25, 2025",
                    status: "Overdue by 1 day",
                    color: .orange
                )
            )
        ]
    }
    
    static var dueSoonSamples: [InvoiceItem] {
        [
            InvoiceItem(
                merchant: "Netonnet",
                subtitle: "Nov 12, 2025",
                amount: "1 568 SEK",
                icon: nil,
                color: .yellow,
                isOverdue: false,
                statusOverride: "3 days",
                category: .dueSoon,
                detail: InvoiceData(
                    merchant: "Netonnet",
                    amount: "1 568 SEK",
                    dueDate: "Nov 12, 2025",
                    invoiceNumber: "INV-2025-11-001",
                    issueDate: "Nov 5, 2025",
                    status: "Due in 3 days",
                    color: .yellow
                )
            ),
            InvoiceItem(
                merchant: "Elgiganten",
                subtitle: "Nov 16, 2025",
                amount: "900 SEK",
                icon: nil,
                color: .yellow,
                isOverdue: false,
                statusOverride: "Snoozed",
                category: .dueSoon,
                detail: InvoiceData(
                    merchant: "Elgiganten",
                    amount: "900 SEK",
                    dueDate: "Nov 16, 2025",
                    invoiceNumber: "INV-2025-11-003",
                    issueDate: "Nov 2, 2025",
                    status: "Snoozed",
                    color: .yellow
                )
            )
        ]
    }
    
    static var handledScheduledSamples: [InvoiceItem] {
        [
            InvoiceItem(
                merchant: "Clas Ohlson",
                subtitle: "Nov 1, 2025",
                amount: "785 SEK",
                icon: "checkmark",
                color: .cyan,
                isOverdue: false,
                statusOverride: nil,
                category: .handledScheduled,
                detail: InvoiceData(
                    merchant: "Clas Ohlson",
                    amount: "785 SEK",
                    dueDate: "Nov 15, 2025",
                    invoiceNumber: "INV-2025-11-002",
                    issueDate: "Nov 1, 2025",
                    status: "Scheduled for Nov 15",
                    color: .cyan
                )
            )
        ]
    }
    
    static var handledPaidSamples: [InvoiceItem] {
        [
            InvoiceItem(
                merchant: "Stadium",
                subtitle: "Oct 25, 2025",
                amount: "2 340 SEK",
                icon: "checkmark",
                color: .green,
                isOverdue: false,
                statusOverride: nil,
                category: .handledPaid,
                detail: InvoiceData(
                    merchant: "Stadium",
                    amount: "2 340 SEK",
                    dueDate: "Nov 8, 2025",
                    invoiceNumber: "INV-2025-10-058",
                    issueDate: "Oct 25, 2025",
                    status: "Paid on Nov 8",
                    color: .green
                )
            ),
            InvoiceItem(
                merchant: "ICA",
                subtitle: "Oct 20, 2025",
                amount: "452 SEK",
                icon: "checkmark",
                color: .green,
                isOverdue: false,
                statusOverride: nil,
                category: .handledPaid,
                detail: InvoiceData(
                    merchant: "ICA",
                    amount: "452 SEK",
                    dueDate: "Nov 3, 2025",
                    invoiceNumber: "INV-2025-10-045",
                    issueDate: "Oct 20, 2025",
                    status: "Paid on Nov 3",
                    color: .green
                )
            ),
            InvoiceItem(
                merchant: "Åhléns",
                subtitle: "Oct 14, 2025",
                amount: "300 SEK",
                icon: "checkmark",
                color: .green,
                isOverdue: false,
                statusOverride: nil,
                category: .handledPaid,
                detail: InvoiceData(
                    merchant: "Åhléns",
                    amount: "300 SEK",
                    dueDate: "Oct 28, 2025",
                    invoiceNumber: "INV-2025-10-038",
                    issueDate: "Oct 14, 2025",
                    status: "Paid on Oct 28",
                    color: .green
                )
            )
        ]
    }
}

enum WalletDestination: Hashable {
    case invoices
    case purchases(filter: PurchaseFilter = .all)
    case actions
}

enum WalletSegment: String, CaseIterable {
    case invoices = "Invoices"
    case purchases = "Purchases"
}

struct WalletView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    @State private var currentSummaryIndex: Int = 0
    @State private var selectedSegment: WalletSegment = .invoices

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11: return "Good morning"
        case 11..<16: return "Good day"
        case 16..<23: return "Good evening"
        default: return "Good night"
        }
    }

    // Data sources for sections
    private var toPayInvoices: [InvoiceItem] {
        InvoiceItem.overdueSamples + InvoiceItem.dueSoonSamples
    }
    private var allInvoices: [InvoiceItem] {
        InvoiceItem.overdueSamples + 
        InvoiceItem.dueSoonSamples + 
        InvoiceItem.handledScheduledSamples + 
        InvoiceItem.handledPaidSamples
    }
    private var allPurchases: [PurchaseItem] {
        PurchaseItem.sampleData
    }
    private var recentPurchases: [PurchaseItem] {
        Array(PurchaseItem.sampleData.prefix(5))
    }
    private var suggestedActions: [ActionItem] {
        Array(ActionItem.priorityItems.prefix(5))
    }
    
    private var unpaidCount: Int { toPayInvoices.count }
    
    private var totalUnpaidAmountLabel: String {
        let total = toPayInvoices.reduce(0.0) { $0 + $1.numericAmount }
        return formattedSEK(total)
    }

    private var availableFamilyCreditLabel: String {
        // Use CreditAccount.sampleAccounts and show available from the Resurs Gold account if present
        let accounts = CreditAccount.sampleAccounts
        let family = accounts.first { $0.name.lowercased().contains("family") }
        let available = family?.available ?? accounts.first?.available ?? 0
        return formattedSEK(available)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "John",
                subtitle: greeting,
                minimizedTitle: "Wallet",
                trailingButton: availableSymbol("sparkle2", fallback: "sparkle"),
                trailingButtonTint: .primary,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: { showProfile = true }
            ) {
                // Content: keep existing sections in order
                VStack(spacing: 24) {
                    // Horizontal summary boxes
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button {
                                navigationPath.append(WalletDestination.invoices)
                            } label: {
                                ZStack(alignment: .leading) {
                                    SummaryBox(title: "To Pay", headline: totalUnpaidAmountLabel, subtitle: "2 invoices overdue", icon: "doc.text.fill", tint: .orange)
                                    Color.clear.frame(width: 1)
                                        .accessibilityHidden(true)
                                        .id("summaryAnchor0")
                                }
                            }
                            .buttonStyle(.plain)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: VisibleCardPreferenceKey.self,
                                            value: [VisibleCardInfo(index: 0, minX: geo.frame(in: .named("summaryScroll")).minX)]
                                        )
                                }
                            )
                            
                            Button {
                                // Switch to Banking tab and request deep link to Resurs Gold account view
                                NotificationCenter.default.post(name: .switchToBanking, object: nil, userInfo: ["destination": "ResursFamilyAccountView"])
                            } label: {
                                ZStack(alignment: .leading) {
                                    SummaryBox(title: "Resurs Gold", headline: availableFamilyCreditLabel, subtitle: "Avaliable credit", icon: "creditcard.fill", tint: .green)
                                    Color.clear.frame(width: 1)
                                        .accessibilityHidden(true)
                                        .id("summaryAnchor1")
                                }
                            }
                            .buttonStyle(.plain)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: VisibleCardPreferenceKey.self,
                                            value: [VisibleCardInfo(index: 1, minX: geo.frame(in: .named("summaryScroll")).minX)]
                                        )
                                }
                            )
                            
                            Button {
                                // Navigate to Merchants tab to add merchant
                                NotificationCenter.default.post(name: .switchToMerchants, object: nil)
                            } label: {
                                ZStack(alignment: .leading) {
                                    SummaryBox(
                                        title: "Connect",
                                        headline: "Add Merchant",
                                        subtitle: "Find your favorite stores",
                                        icon: "plus",
                                        tint: .blue
                                    )
                                    Color.clear.frame(width: 1)
                                        .accessibilityHidden(true)
                                        .id("summaryAnchor2")
                                }
                            }
                            .buttonStyle(.plain)
                            .background(
                                GeometryReader { geo in
                                    Color.clear
                                        .preference(
                                            key: VisibleCardPreferenceKey.self,
                                            value: [VisibleCardInfo(index: 2, minX: geo.frame(in: .named("summaryScroll")).minX)]
                                        )
                                }
                            )
                        }
                        .scrollTargetLayout()
                        .padding(.horizontal)
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .coordinateSpace(name: "summaryScroll")
                    .onPreferenceChange(VisibleCardPreferenceKey.self) { infos in
                        guard !infos.isEmpty else { return }
                        // Find the card with minX closest to the ScrollView's leading edge (0)
                        let newIndex = infos.min(by: { abs($0.minX) < abs($1.minX) })?.index ?? currentSummaryIndex
                        if newIndex != currentSummaryIndex {
                            currentSummaryIndex = newIndex
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    }

                    // Segmented Control for Invoices/Purchases
                    Picker("Content", selection: $selectedSegment) {
                        Text("Invoices").tag(WalletSegment.invoices)
                        Text("Purchases").tag(WalletSegment.purchases)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Content based on selected segment
                    Group {
                        if selectedSegment == .invoices {
                            VStack(spacing: 12) {
                                if allInvoices.isEmpty {
                                    EmptyStateRow(title: "No unpaid invoices", subtitle: "You're all caught up for now")
                                } else {
                                    ForEach(allInvoices) { invoice in
                                        Button {
                                            navigationPath.append(invoice.detail)
                                        } label: {
                                            InvoiceRow(
                                                title: invoice.merchant,
                                                subtitle: invoice.subtitle,
                                                amount: invoice.amount,
                                                icon: invoice.icon,
                                                color: invoice.color,
                                                isOverdue: invoice.isOverdue,
                                                statusOverride: invoice.statusOverride
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        } else {
                            VStack(spacing: 12) {
                                if allPurchases.isEmpty {
                                    EmptyStateRow(title: "No recent purchases", subtitle: "Your recent activity will appear here")
                                } else {
                                    ForEach(allPurchases) { purchase in
                                        Button {
                                            navigationPath.append(purchase.transactionDetailData)
                                        } label: {
                                            PurchaseRow(
                                                title: purchase.title,
                                                subtitle: purchase.subtitleWithoutTime,
                                                amount: purchase.amount,
                                                icon: purchase.icon,
                                                color: purchase.color,
                                                paymentMethod: purchase.paymentMethod,
                                                showsPartPayBadge: purchase.isEligibleForPartPay
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 0)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: WalletDestination.self) { destination in
                switch destination {
                case .invoices:
                    InvoicesList(navigationPath: $navigationPath)
                case .purchases(let filter):
                    PurchasesList(navigationPath: $navigationPath, initialFilter: filter)
                case .actions:
                    ActionsList(actionItems: ActionItem.allItems)
                }
            }
            .navigationDestination(for: TransactionData.self) { transaction in
                TransactionDetailView(
                    merchant: transaction.merchant,
                    amount: transaction.amount,
                    date: transaction.date,
                    time: transaction.time,
                    paymentMethod: transaction.paymentMethod
                )
            }
            .navigationDestination(for: InvoiceData.self) { invoice in
                InvoiceDetailView(invoice: invoice)
            }
            .sheet(isPresented: $showProfile) {
                let rows = suggestedActions.count
                let estimated = CGFloat(rows) * 82 + 200
                let preferredHeight = min(max(estimated, 320), UIScreen.main.bounds.height * 0.9)
                FavoritesOverlay(actions: suggestedActions)
                    .presentationDetents([.height(preferredHeight)])
            }
        }
    }
}

struct FavoritesOverlay: View {
    @Environment(\.dismiss) private var dismiss
    
    let actions: [ActionItem]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                ZStack(alignment: .top) {
                    Capsule()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 40, height: 5)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark")
                                .font(.headline.weight(.bold))
                                .foregroundColor(.primary)
                                .frame(width: 36, height: 36)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                                .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 16)
                        .padding(.top, 16)
                    }
                }
                
                Text("Recommended Actions")
                    .font(.title2.weight(.semibold))
                    .padding(.top, 4)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 12) {
                            ForEach(actions) { action in
                                ActionRow(
                                    title: action.title,
                                    subtitle: action.subtitle,
                                    icon: action.icon,
                                    color: action.color
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
                
            }
            .padding(.bottom, 12)
            .padding(.top, 0)
            .background(Color(UIColor.systemBackground).ignoresSafeArea())
        }
    }
}

struct PurchaseItem: Identifiable {
    let id = UUID()
    let title: String
    let merchant: String
    let subtitle: String
    let amount: String
    let icon: String
    let color: Color
    let category: PurchaseCategory
    let paymentMethod: PaymentMethod
    let transaction: TransactionData?
    
    var subtitleWithoutTime: String {
        let dateAndLocation = subtitle.components(separatedBy: " - ")
        let rawDate = dateAndLocation.first ?? subtitle
        let cleanedDate = rawDate.components(separatedBy: ",").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? rawDate.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard dateAndLocation.count > 1 else {
            return cleanedDate
        }
        
        let location = dateAndLocation
            .dropFirst()
            .joined(separator: " - ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return location.isEmpty ? cleanedDate : "\(cleanedDate) - \(location)"
    }
    
    var numericAmount: Double {
        let cleaned = amount
            .replacingOccurrences(of: "kr", with: "")
            .replacingOccurrences(of: "SEK", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(cleaned) ?? 0
    }

    init(
        title: String,
        merchant: String,
        subtitle: String,
        amount: String,
        icon: String,
        color: Color,
        category: PurchaseCategory,
        paymentMethod: PaymentMethod,
        transaction: TransactionData?
    ) {
        let resolvedPaymentMethod: PaymentMethod
        if paymentMethod.isValid(for: merchant) {
            resolvedPaymentMethod = paymentMethod
        } else {
            assertionFailure("Payment method \(paymentMethod.rawValue) cannot be used with merchant \(merchant)")
            resolvedPaymentMethod = .resursFamily
        }
        
        if let transaction {
            if transaction.merchant.lowercased() != merchant.lowercased() {
                assertionFailure("Transaction merchant \(transaction.merchant) should match purchase merchant \(merchant)")
            }
            if transaction.paymentMethod != resolvedPaymentMethod {
                assertionFailure("Transaction payment method must match purchase payment method")
            }
        }
        
        self.title = title
        self.merchant = merchant
        self.subtitle = subtitle
        self.amount = amount
        self.icon = icon
        self.color = color
        self.category = category
        self.paymentMethod = resolvedPaymentMethod
        self.transaction = transaction
    }
    
    static let sampleData: [PurchaseItem] = [
        PurchaseItem(
            title: "Bauhaus Megastore",
            merchant: "Bauhaus",
            subtitle: "Today, 11:20 AM - Goteborg",
            amount: "4 356 kr",
            icon: "hammer.fill",
            color: .orange,
            category: .large,
            paymentMethod: .bauhausInvoice,
            transaction: TransactionData(
                merchant: "Bauhaus",
                amount: "4 356 kr",
                date: "Today",
                time: "11:20 AM",
                paymentMethod: .bauhausInvoice
            )
        ),
        PurchaseItem(
            title: "NetOnNet Warehouse",
            merchant: "NetOnNet",
            subtitle: "Yesterday, 5:45 PM - Stockholm",
            amount: "12 499 kr",
            icon: "bolt.fill",
            color: .blue,
            category: .large,
            paymentMethod: .netonnetAccount,
            transaction: TransactionData(
                merchant: "NetOnNet",
                amount: "12 499 kr",
                date: "Yesterday",
                time: "5:45 PM",
                paymentMethod: .netonnetAccount
            )
        ),
        PurchaseItem(
            title: "Jula Kungens Kurva",
            merchant: "Jula",
            subtitle: "Yesterday, 9:05 AM - Stockholm",
            amount: "2 145 kr",
            icon: "wrench.and.screwdriver",
            color: .red,
            category: .shopping,
            paymentMethod: .julaAccount,
            transaction: TransactionData(
                merchant: "Jula",
                amount: "2 145 kr",
                date: "Yesterday",
                time: "9:05 AM",
                paymentMethod: .julaAccount
            )
        ),
        PurchaseItem(
            title: "Clas Ohlson",
            merchant: "Clas Ohlson",
            subtitle: "2 days ago, 6:40 PM - Malmo",
            amount: "890 kr",
            icon: "lightbulb.fill",
            color: .yellow,
            category: .shopping,
            paymentMethod: .resursFamily,
            transaction: nil
        ),
        PurchaseItem(
            title: "Elgiganten",
            merchant: "Elgiganten",
            subtitle: "3 days ago, 7:10 PM - Uppsala",
            amount: "5 699 kr",
            icon: "display.2",
            color: .green,
            category: .large,
            paymentMethod: .swish,
            transaction: nil
        ),
        PurchaseItem(
            title: "Lyko Beauty",
            merchant: "Lyko",
            subtitle: "4 days ago, 3:25 PM - Boras",
            amount: "640 kr",
            icon: "drop.fill",
            color: .pink,
            category: .shopping,
            paymentMethod: .swish,
            transaction: nil
        ),
        PurchaseItem(
            title: "ICA Maxi",
            merchant: "ICA Maxi",
            subtitle: "5 days ago, 5:15 PM - Lund",
            amount: "1 245 kr",
            icon: "cart.fill",
            color: .brown,
            category: .recent,
            paymentMethod: .resursFamily,
            transaction: nil
        ),
        PurchaseItem(
            title: "Willys Hemma",
            merchant: "Willys",
            subtitle: "6 days ago, 1:05 PM - Vasteras",
            amount: "925 kr",
            icon: "cart.circle.fill",
            color: .teal,
            category: .recent,
            paymentMethod: .swish,
            transaction: nil
        ),
        PurchaseItem(
            title: "Stadium Outlet",
            merchant: "Stadium",
            subtitle: "1 week ago, 4:30 PM - Orebro",
            amount: "1 080 kr",
            icon: "sportscourt.fill",
            color: .purple,
            category: .shopping,
            paymentMethod: .resursFamily,
            transaction: nil
        )
    ]
}

extension PurchaseItem {
    private static let merchantsWithPartPaySupport: Set<String> = ["jula", "netonnet"]
    
    /// Provides enough structured data to drive TransactionDetailView even when we only have a subtitle string.
    var transactionDetailData: TransactionData {
        if let transaction {
            return transaction
        }
        
        let components = subtitle.components(separatedBy: ",")
        let dateText = components.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Recent purchase"
        let timeAndLocation = components.dropFirst().first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let timeText = timeAndLocation.components(separatedBy: "-").first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Time unavailable"
        
        return TransactionData(
            merchant: merchant,
            amount: amount,
            date: dateText,
            time: timeText.isEmpty ? "Time unavailable" : timeText,
            paymentMethod: paymentMethod
        )
    }
    
    var isEligibleForPartPay: Bool {
        let merchantKey = merchant.lowercased()
        if PurchaseItem.merchantsWithPartPaySupport.contains(merchantKey) {
            return true
        }
        return paymentMethod.supportsPartPayConversion &&
        !paymentMethod.isMerchantAccount &&
        numericAmount >= 1_000
    }
}

enum PurchaseCategory: String, CaseIterable, Identifiable {
    case all = "All"
    case recent = "Recent"
    case large = "Large"
    case online = "Online"
    case dining = "Dining"
    case entertainment = "Entertainment"
    case shopping = "Shopping"
    
    var id: String { rawValue }
    
    var label: String {
        rawValue
    }
}

enum PurchaseFilter: String, CaseIterable, Identifiable {
    case all
    case partPay
    case mastercard
    case merchants
    case swish
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .all:
            return "All"
        case .mastercard:
            return "Family"
        case .merchants:
            return "Merchants"
        case .swish:
            return "Swish"
        case .partPay:
            return "Part Pay"
        }
    }
    
    var summaryDescription: String {
        switch self {
        case .all:
            return "All activity"
        case .mastercard:
            return "Resurs Gold card"
        case .merchants:
            return "Connected merchants"
        case .swish:
            return "Swish payments"
        case .partPay:
            return "Eligible for Part Pay"
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .all:
            return "Shows every purchase"
        case .mastercard:
            return "Shows purchases paid with the Resurs Gold card"
        case .merchants:
            return "Shows purchases paid with merchant accounts"
        case .swish:
            return "Shows purchases paid with Swish"
        case .partPay:
            return "Shows purchases that can be moved into Part Pay"
        }
    }
    
    func matches(_ purchase: PurchaseItem) -> Bool {
        switch self {
        case .all:
            return true
        case .mastercard:
            return purchase.paymentMethod == .resursFamily
        case .merchants:
            return purchase.paymentMethod.isMerchantAccount
        case .swish:
            return purchase.paymentMethod == .swish
        case .partPay:
            return purchase.isEligibleForPartPay
        }
    }
}

struct PurchasesList: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var selectedFilter: PurchaseFilter = .all
    
    init(
        navigationPath: Binding<NavigationPath>,
        initialFilter: PurchaseFilter = .all
    ) {
        self._navigationPath = navigationPath
        _selectedFilter = State(initialValue: initialFilter)
    }
    
    private var filteredPurchases: [PurchaseItem] {
        PurchaseItem.sampleData.filter { selectedFilter.matches($0) }
    }
    
    private var summaryText: String {
        let count = filteredPurchases.count
        return "\(count) purchase\(count == 1 ? "" : "s") · \(selectedFilter.summaryDescription)"
    }
    
    private var scrollProgress: CGFloat {
        min(scrollObserver.offset / 100, 1.0)
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    scrollablePurchases(proxy: proxy)
                }
                
                purchasesHeader(scrollProgress: scrollProgress)
                    .frame(width: geometry.size.width)
            }
        }
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func scrollablePurchases(proxy: ScrollViewProxy) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                scrollOffsetTracker
                
                Color.clear
                    .frame(height: 120)
                
                VStack(spacing: 16) {
                    filterControl
                        .padding(.top, 24)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    ForEach(filteredPurchases) { purchase in
                        purchaseRow(for: purchase)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
        .coordinateSpace(name: "purchasesScroll")
        .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                proxy.scrollTo("purchasesTop", anchor: .top)
            }
        }
    }
    
    private var scrollOffsetTracker: some View {
        GeometryReader { geo in
            Color.clear
                .onChange(of: geo.frame(in: .named("purchasesScroll")).minY) { _, newValue in
                    scrollObserver.offset = max(0, -newValue)
                }
        }
        .frame(height: 0)
        .id("purchasesTop")
    }
    
    @ViewBuilder
    private func purchaseRow(for purchase: PurchaseItem) -> some View {
        Button {
            navigationPath.append(purchase.transactionDetailData)
        } label: {
            PurchaseRow(
                title: purchase.title,
                subtitle: purchase.subtitleWithoutTime,
                amount: purchase.amount,
                icon: purchase.icon,
                color: purchase.color,
                paymentMethod: purchase.paymentMethod,
                showsPartPayBadge: purchase.isEligibleForPartPay
            )
        }
        .buttonStyle(.plain)
    }
    
    private var filterControl: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(PurchaseFilter.allCases) { filter in
                        Button {
                            guard selectedFilter != filter else { return }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                                selectedFilter = filter
                            }
                        } label: {
                            let isSelected = selectedFilter == filter
                            Text(filter.label)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(isSelected ? .primary : .secondary)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Capsule()
                                                .strokeBorder(
                                                    isSelected ? Color.accentColor.opacity(0.7) : Color.white.opacity(0.08),
                                                    lineWidth: isSelected ? 2 : 1
                                                )
                                        )
                                )
                                .shadow(
                                    color: isSelected ? Color.accentColor.opacity(0.14) : .clear,
                                    radius: 8,
                                    x: 0,
                                    y: 4
                                )
                                .contentShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(filter.label) filter")
                        .accessibilityHint(filter.accessibilityHint)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
    
    private func purchasesHeader(scrollProgress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                
                if scrollProgress > 0.5 {
                    Text("Purchases")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Purchases")
                        .font(.largeTitle.weight(.bold))
                    Text(summaryText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(Color(uiColor: .systemBackground).opacity(0.95))
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: scrollProgress)
    }
}

struct ActionsList: View {
    let actionItems: [ActionItem]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    
    var body: some View {
        let scrollProgress = min(scrollObserver.offset / 100, 1.0)
        
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            GeometryReader { geo in
                                Color.clear
                                    .onChange(of: geo.frame(in: .named("actionsScroll")).minY) { _, newValue in
                                        scrollObserver.offset = max(0, -newValue)
                                    }
                            }
                            .frame(height: 0)
                            .id("actionsTop")
                            
                            Color.clear.frame(height: 120)
                            
                            VStack(spacing: 12) {
                                ForEach(actionItems) { action in
                                    ActionRow(
                                        title: action.title,
                                        subtitle: action.subtitle,
                                        icon: action.icon,
                                        color: action.color
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                        }
                    }
                    .coordinateSpace(name: "actionsScroll")
                    .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("actionsTop", anchor: .top)
                        }
                    }
                }
                
                actionsHeader(scrollProgress: scrollProgress)
                    .frame(width: geometry.size.width)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func actionsHeader(scrollProgress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                
                if scrollProgress > 0.5 {
                    Text("Actions")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Actions")
                        .font(.largeTitle.weight(.bold))
                    Text("\(actionItems.count) suggestions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(Color(uiColor: .systemBackground).opacity(0.95))
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: scrollProgress)
    }
}

struct ActionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InvoicesList: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var overdueInvoices = InvoiceItem.overdueSamples
    @State private var dueSoonInvoices = InvoiceItem.dueSoonSamples
    @State private var scheduledInvoices = InvoiceItem.handledScheduledSamples
    @State private var paidInvoices = InvoiceItem.handledPaidSamples
    
    private var outstandingPool: [InvoiceItem] {
        overdueInvoices + dueSoonInvoices
    }
    
    private var selectedInvoices: [InvoiceItem] {
        outstandingPool.filter { $0.isSelected }
    }
    
    private var outstandingSummaryText: String {
        let amount = outstandingPool.reduce(0) { $0 + $1.numericAmount }
        return "\(outstandingPool.count) open · \(formattedSEK(amount))"
    }

    var body: some View {
        let scrollProgress = min(scrollObserver.offset / 100, 1.0)
        
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            GeometryReader { geo in
                                Color.clear
                                    .onChange(of: geo.frame(in: .named("invoicesScroll")).minY) { _, newValue in
                                        scrollObserver.offset = max(0, -newValue)
                                    }
                            }
                            .frame(height: 0)
                            .id("invoicesTop")
                            
                            Color.clear.frame(height: 120)
                            
                            VStack(spacing: 20) {
                                sectionHeader("TO PAY")
                                ForEach(overdueInvoices) { invoice in
                                    invoiceButton(for: invoice, allowBatching: true)
                                }
                                
                                ForEach(dueSoonInvoices) { invoice in
                                    invoiceButton(for: invoice, allowBatching: true)
                                }
                                
                                sectionHeader("Handled")
                                ForEach(scheduledInvoices) { invoice in
                                    invoiceButton(for: invoice, allowBatching: false)
                                }
                                
                                ForEach(paidInvoices) { invoice in
                                    invoiceButton(for: invoice, allowBatching: false)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                            .padding(.bottom, 40)
                        }
                    }
                    .coordinateSpace(name: "invoicesScroll")
                    .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("invoicesTop", anchor: .top)
                        }
                    }
                }
                
                header(scrollProgress: scrollProgress)
                    .frame(width: geometry.size.width)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func invoiceButton(for invoice: InvoiceItem, allowBatching: Bool) -> some View {
        Button {
            navigationPath.append(invoice.detail)
        } label: {
            InvoiceRow(
                title: invoice.merchant,
                subtitle: invoice.subtitle,
                amount: invoice.amount,
                icon: invoice.icon,
                color: invoice.color,
                isOverdue: invoice.isOverdue,
                statusOverride: invoice.statusOverride,
                isSelected: invoice.isSelected,
                onStatusTap: allowBatching ? {
                    toggleSelection(for: invoice)
                } : nil
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func toggleSelection(for invoice: InvoiceItem) {
        switch invoice.category {
        case .overdue:
            if let index = overdueInvoices.firstIndex(where: { $0.id == invoice.id }) {
                overdueInvoices[index].isSelected.toggle()
            }
        case .dueSoon:
            if let index = dueSoonInvoices.firstIndex(where: { $0.id == invoice.id }) {
                dueSoonInvoices[index].isSelected.toggle()
            }
        default:
            break
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
            Spacer(minLength: 12)
        }
        .padding(.horizontal, 4)
    }
    
    private func header(scrollProgress: CGFloat) -> some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 32, height: 32)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                
                if scrollProgress > 0.5 {
                    Text("Invoices")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Invoices")
                        .font(.largeTitle.weight(.bold))
                    Text(outstandingSummaryText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(Color(uiColor: .systemBackground).opacity(0.95))
        .background(.ultraThinMaterial)
        .animation(.easeInOut(duration: 0.2), value: scrollProgress)
    }
}

struct PurchaseRow: View {
    let title: String
    let subtitle: String
    let amount: String
    let icon: String
    let color: Color
    let paymentMethod: PaymentMethod
    let showsPartPayBadge: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("Paid with \(paymentMethod.displayName)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text(amount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                if showsPartPayBadge {
                    Text("Part Pay")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                        .accessibilityLabel("Eligible for Part Pay")
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct InvoiceRow: View {
    let title: String
    let subtitle: String
    let amount: String
    let icon: String?
    let color: Color
    let isOverdue: Bool
    var statusOverride: String? = nil
    var isSelected: Bool = false
    var onStatusTap: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            statusIndicator
            
            // Middle: Invoice number and date
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Right: Amount and status
            VStack(alignment: .trailing, spacing: 4) {
                Text(amount)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                if !statusText.isEmpty {
                    Text(statusText)
                        .font(.subheadline)
                        .foregroundColor(statusColor)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var statusText: String {
        if let override = statusOverride {
            return override
        }
        if isOverdue {
            return "Overdue"
        } else if color == .green {
            return "Paid"
        } else if color == .cyan {
            return "Scheduled"
        } else {
            return ""
        }
    }
    
    private var statusColor: Color {
        return color
    }
    
    @ViewBuilder
    private var statusIndicator: some View {
        let baseColor = color
        let iconName: String = {
            if isOverdue { return "doc.text.fill" } // same icon, color conveys state
            if baseColor == .green { return "doc.text.fill" }
            if baseColor == .cyan { return "doc.text.fill" }
            return "doc.text.fill"
        }()
        let indicator = RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(baseColor.opacity(0.2))
            .frame(width: 44, height: 44)
            .overlay(
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(baseColor)
            )
        if let onStatusTap {
            Button(action: onStatusTap) {
                indicator
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select \(title) for batch payment")
        } else {
            indicator
        }
    }
}

struct WalletSectionHeader: View {
    let title: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        HStack(alignment: .center) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
            Spacer(minLength: 12)
            Button(action: action) {
                HStack(spacing: 4) {
                    Text(actionTitle)
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .accessibilityHint("Opens \(title.lowercased()) list")
        }
    }
}

struct EmptyStateRow: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct SummaryBox: View {
    let title: String
    let headline: String
    let subtitle: String
    let icon: String
    let tint: Color
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(tint.opacity(0.15)))
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .tracking(0.6)
                Text(headline)
                    .font(.system(.title3, design: .rounded).weight(.bold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(title == "To Pay" && subtitle == "2 invoices overdue" ? .orange : .secondary)
            }
        }
        .frame(width: 200, alignment: .leading)
        .padding(16)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

#Preview {
    WalletView()
        .environmentObject(PaymentPlansManager())
        .preferredColorScheme(.dark)
}

