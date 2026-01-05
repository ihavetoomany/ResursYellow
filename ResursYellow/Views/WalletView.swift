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
    let id: UUID
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
    
    init(
        id: UUID = UUID(),
        merchant: String,
        subtitle: String,
        amount: String,
        icon: String?,
        color: Color,
        isOverdue: Bool,
        statusOverride: String? = nil,
        category: InvoiceCategory,
        detail: InvoiceData,
        isSelected: Bool = false
    ) {
        self.id = id
        self.merchant = merchant
        self.subtitle = subtitle
        self.amount = amount
        self.icon = icon
        self.color = color
        self.isOverdue = isOverdue
        self.statusOverride = statusOverride
        self.category = category
        self.detail = detail
        self.isSelected = isSelected
    }
    
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
    @StateObject private var dataManager = DataManager.shared
    private let dateService = DateService.shared
    @StateObject private var localizationService = LocalizationService.shared
    
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    @State private var currentSummaryIndex: Int = 0
    @State private var selectedSegment: WalletSegment = .invoices
    
    // Helper to ensure views update when language changes
    private var currentLanguage: Language {
        localizationService.currentLanguage // This triggers SwiftUI updates
    }
    
    private func localized(_ key: String) -> String {
        _ = currentLanguage // Reference to trigger updates
        return localizationService.localizedString(key, fallback: key)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: dateService.currentDate())
        switch hour {
        case 5..<11: return localizationService.localizedString("greeting_morning", fallback: "Good morning")
        case 11..<16: return localizationService.localizedString("greeting_day", fallback: "Good day")
        case 16..<23: return localizationService.localizedString("greeting_evening", fallback: "Good evening")
        default: return localizationService.localizedString("greeting_night", fallback: "Good night")
        }
    }

    // Data sources for sections - converted from DataManager
    private var toPayInvoices: [InvoiceItem] {
        let overdue = dataManager.invoicesForCategory(.overdue)
        let dueSoon = dataManager.invoicesForCategory(.dueSoon)
        return (overdue + dueSoon).map { invoice in
            InvoiceItem(
                id: invoice.id,
                merchant: invoice.merchant,
                subtitle: invoice.subtitle(dateService: dateService),
                amount: invoice.amount,
                icon: invoice.icon,
                color: invoice.color,
                isOverdue: invoice.isOverdue,
                statusOverride: invoice.statusOverride,
                category: invoice.category.toInvoiceCategory(),
                detail: invoice.toInvoiceData(dateService: dateService),
                isSelected: false
            )
        }
    }
    
    private var allInvoices: [InvoiceItem] {
        dataManager.invoices.map { invoice in
            InvoiceItem(
                id: invoice.id,
                merchant: invoice.merchant,
                subtitle: invoice.subtitle(dateService: dateService),
                amount: invoice.amount,
                icon: invoice.icon,
                color: invoice.color,
                isOverdue: invoice.isOverdue,
                statusOverride: invoice.statusOverride,
                category: invoice.category.toInvoiceCategory(),
                detail: invoice.toInvoiceData(dateService: dateService),
                isSelected: false
            )
        }
    }
    
    private var allPurchases: [PurchaseItem] {
        dataManager.transactions.compactMap { transaction in
            guard let transactionData = transaction.toTransactionData(dateService: dateService) else {
                return nil
            }
            let paymentMethod = transaction.inferredPaymentMethod()
            let (icon, color) = transaction.iconAndColor()
            let category = transaction.purchaseCategory()
            let dateStr = dateService.formatRelativeDate(offset: transaction.dateOffset)
            let timeStr = dateService.formatDate(dateService.relativeDate(offset: transaction.dateOffset), format: "h:mm a")
            let subtitle = "\(dateStr), \(timeStr)"
            
            return PurchaseItem(
                id: transaction.id,
                title: transaction.description,
                merchant: transaction.merchant ?? transaction.description,
                subtitle: subtitle,
                amount: transaction.amount,
                icon: icon,
                color: color,
                category: category,
                paymentMethod: paymentMethod,
                transaction: transactionData
            )
        }
    }
    
    private var recentPurchases: [PurchaseItem] {
        Array(allPurchases.prefix(5))
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
                        Text(self.localized("Invoices")).tag(WalletSegment.invoices)
                        Text(self.localized("Purchases")).tag(WalletSegment.purchases)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Content based on selected segment
                    Group {
                        if selectedSegment == .invoices {
                            VStack(spacing: 12) {
                                if allInvoices.isEmpty {
                                    EmptyStateRow(title: self.localized("No unpaid invoices"), subtitle: self.localized("You're all caught up for now"))
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
                                    EmptyStateRow(title: self.localized("No recent purchases"), subtitle: self.localized("Your recent activity will appear here"))
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
                AISupportChatView()
            }
        }
    }
}

// MARK: - AI Support Chat View
struct AISupportChatView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var localizationService = LocalizationService.shared
    @State private var messages: [ChatMessage] = []
    @State private var inputText: String = ""
    @State private var isTyping: Bool = false
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Chat messages
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Welcome message
                            if messages.isEmpty {
                                VStack(spacing: 20) {
                                    // AI Avatar
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 48, weight: .medium))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.blue, .purple],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 80, height: 80)
                                        .background(
                                            Circle()
                                                .fill(.ultraThinMaterial)
                                                .overlay(
                                                    Circle()
                                                        .strokeBorder(
                                                            LinearGradient(
                                                                colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                                                                startPoint: .topLeading,
                                                                endPoint: .bottomTrailing
                                                            ),
                                                            lineWidth: 2
                                                        )
                                                )
                                        )
                                        .shadow(color: .blue.opacity(0.2), radius: 12, x: 0, y: 4)
                                        .padding(.top, 20)
                                    
                                    Text(localizationService.localizedString("AI Bank Support", fallback: "AI Bank Support"))
                                        .font(.title2.weight(.semibold))
                                    
                                    Text(localizationService.localizedString("How can I help you today?", fallback: "How can I help you today?"))
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal)
                                    
                                    // Quick action buttons
                                    VStack(spacing: 12) {
                                        QuickActionButton(
                                            title: localizationService.localizedString("Check Account Balance", fallback: "Check Account Balance"),
                                            icon: "creditcard.fill"
                                        ) {
                                            sendMessage(localizationService.localizedString("Check Account Balance", fallback: "Check Account Balance"))
                                        }
                                        
                                        QuickActionButton(
                                            title: localizationService.localizedString("Payment Questions", fallback: "Payment Questions"),
                                            icon: "doc.text.fill"
                                        ) {
                                            sendMessage(localizationService.localizedString("I have questions about payments", fallback: "I have questions about payments"))
                                        }
                                        
                                        QuickActionButton(
                                            title: localizationService.localizedString("Invoice Help", fallback: "Invoice Help"),
                                            icon: "list.bullet.rectangle.fill"
                                        ) {
                                            sendMessage(localizationService.localizedString("I need help with invoices", fallback: "I need help with invoices"))
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                                }
                                .padding(.vertical, 32)
                            } else {
                                ForEach(messages) { message in
                                    ChatBubble(message: message)
                                        .id(message.id)
                                }
                                
                                if isTyping {
                                    TypingIndicator()
                                        .id("typing")
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                    }
                    .onChange(of: messages.count) { _, _ in
                        if let lastMessage = messages.last {
                            withAnimation {
                                proxy.scrollTo(lastMessage.id, anchor: .bottom)
                            }
                        }
                    }
                    .onChange(of: isTyping) { _, newValue in
                        if newValue {
                            withAnimation {
                                proxy.scrollTo("typing", anchor: .bottom)
                            }
                        }
                    }
                }
                
                // Input area
                HStack(spacing: 12) {
                    TextField(
                        localizationService.localizedString("Type your message...", fallback: "Type your message..."),
                        text: $inputText,
                        axis: .vertical
                    )
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
                    )
                    .focused($isInputFocused)
                    .lineLimit(1...5)
                    
                    Button {
                        sendMessage(inputText)
                        inputText = ""
                        isInputFocused = false
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32, weight: .medium))
                            .foregroundStyle(inputText.isEmpty ? .secondary : Color.blue)
                    }
                    .disabled(inputText.isEmpty)
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {
                        Text(localizationService.localizedString("AI Bank Support", fallback: "AI Bank Support"))
                            .font(.headline)
                        Text(localizationService.localizedString("Online", fallback: "Online"))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .tint(.primary)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.ultraThinMaterial)
    }
    
    private func sendMessage(_ text: String) {
        guard !text.isEmpty else { return }
        
        let userMessage = ChatMessage(
            id: UUID(),
            text: text,
            isFromUser: true,
            timestamp: Date()
        )
        
        messages.append(userMessage)
        
        // Simulate AI response
        isTyping = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
            let aiResponse = generateAIResponse(for: text)
            let aiMessage = ChatMessage(
                id: UUID(),
                text: aiResponse,
                isFromUser: false,
                timestamp: Date()
            )
            await MainActor.run {
                messages.append(aiMessage)
                isTyping = false
            }
        }
    }
    
    private func generateAIResponse(for userInput: String) -> String {
        let lowercased = userInput.lowercased()
        
        if lowercased.contains("balance") || lowercased.contains("account") {
            return localizationService.localizedString(
                "Your Resurs Gold account has 15,000 SEK available credit out of a 30,000 SEK limit. Would you like more details?",
                fallback: "Your Resurs Gold account has 15,000 SEK available credit out of a 30,000 SEK limit. Would you like more details?"
            )
        } else if lowercased.contains("payment") || lowercased.contains("pay") {
            return localizationService.localizedString(
                "I can help you with payments! You can pay invoices directly from the Wallet tab, set up payment plans, or schedule payments. What would you like to do?",
                fallback: "I can help you with payments! You can pay invoices directly from the Wallet tab, set up payment plans, or schedule payments. What would you like to do?"
            )
        } else if lowercased.contains("invoice") {
            return localizationService.localizedString(
                "I see you have 2 overdue invoices totaling 1,621 SEK. Would you like me to help you set up a payment plan or pay them now?",
                fallback: "I see you have 2 overdue invoices totaling 1,621 SEK. Would you like me to help you set up a payment plan or pay them now?"
            )
        } else {
            return localizationService.localizedString(
                "I'm here to help with your banking needs. You can ask me about your account balance, payments, invoices, or any other banking questions. How can I assist you?",
                fallback: "I'm here to help with your banking needs. You can ask me about your account balance, payments, invoices, or any other banking questions. How can I assist you?"
            )
        }
    }
}

// MARK: - Chat Message Model
struct ChatMessage: Identifiable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}

// MARK: - Chat Bubble
struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer(minLength: 60)
            }
            
            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(.body)
                    .foregroundStyle(message.isFromUser ? .white : .primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        message.isFromUser
                            ? LinearGradient(
                                colors: [.blue, .blue.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color(.systemGray6), Color(.systemGray5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        in: RoundedRectangle(cornerRadius: 18)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                message.isFromUser
                                    ? Color.white.opacity(0.2)
                                    : Color.white.opacity(0.18),
                                lineWidth: 1
                            )
                    )
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            if !message.isFromUser {
                Spacer(minLength: 60)
            }
        }
    }
}

// MARK: - Typing Indicator
struct TypingIndicator: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(.secondary)
                        .frame(width: 8, height: 8)
                        .offset(y: isAnimating ? -4 : 0)
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.15),
                            value: isAnimating
                        )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
            
            Spacer(minLength: 60)
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                    .foregroundStyle(Color.blue)
                    .frame(width: 24)
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(Color.white.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

struct PurchaseItem: Identifiable {
    let id: UUID
    let title: String
    let merchant: String
    let subtitle: String
    let amount: String
    let icon: String
    let color: Color
    let category: PurchaseCategory
    let paymentMethod: PaymentMethod
    let transaction: TransactionData?
    
    init(
        id: UUID = UUID(),
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
        
        self.id = id
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
    @StateObject private var localizationService = LocalizationService.shared
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
                    Text(localizationService.localizedString("Purchases", fallback: "Purchases"))
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationService.localizedString("Purchases", fallback: "Purchases"))
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
    @StateObject private var localizationService = LocalizationService.shared
    
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
                    Text(localizationService.localizedString("Actions", fallback: "Actions"))
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationService.localizedString("Actions", fallback: "Actions"))
                        .font(.largeTitle.weight(.bold))
                    Text("\(actionItems.count) \(localizationService.localizedString("suggestions", fallback: "suggestions"))")
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
    @StateObject private var localizationService = LocalizationService.shared
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
                    Text(localizationService.localizedString("Invoices", fallback: "Invoices"))
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizationService.localizedString("Invoices", fallback: "Invoices"))
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
    
    @StateObject private var localizationService = LocalizationService.shared
    
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
                Text("\(localizationService.localizedString("Paid with", fallback: "Paid with")) \(paymentMethod.displayName)")
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
                    Text(localizationService.localizedString("Part Pay", fallback: "Part Pay"))
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


