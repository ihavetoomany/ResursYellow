//
//  WalletView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

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
        CreditAccount(name: "Resurs Family", available: 15_000, limit: 30_000)
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

struct MerchantPurchaseSummary: Identifiable {
    let id = UUID()
    let merchant: String
    let totalAmount: Double
    let displayAmount: String
    let transactionCount: Int
    let icon: String
    let color: Color
}

struct SavingsGoal: Identifiable {
    let id = UUID()
    let name: String
    let contributed: Double
    let target: Double
    let deadline: String
    let color: Color
    
    var contributedLabel: String {
        formattedSEK(contributed)
    }
    
    var targetLabel: String {
        formattedSEK(target)
    }
    
    var progress: Double {
        guard target > 0 else { return 0 }
        return min(contributed / target, 1)
    }
}

extension SavingsGoal {
    static let sampleData: [SavingsGoal] = [
        SavingsGoal(
            name: "Emergency fund",
            contributed: 12_500,
            target: 20_000,
            deadline: "Dec 31",
            color: .mint
        ),
        SavingsGoal(
            name: "Winter vacation",
            contributed: 8_200,
            target: 15_000,
            deadline: "Feb 15",
            color: .cyan
        ),
        SavingsGoal(
            name: "Home upgrade",
            contributed: 5_600,
            target: 25_000,
            deadline: "Jun 1",
            color: .purple
        ),
        SavingsGoal(
            name: "Electric bike",
            contributed: 3_300,
            target: 12_000,
            deadline: "Apr 20",
            color: .orange
        )
    ]
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
    case resursFamily = "Resurs Family"
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
                statusOverride: "1 week",
                category: .dueSoon,
                detail: InvoiceData(
                    merchant: "Elgiganten",
                    amount: "900 SEK",
                    dueDate: "Nov 16, 2025",
                    invoiceNumber: "INV-2025-11-003",
                    issueDate: "Nov 2, 2025",
                    status: "Due in 1 week",
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
    case savings
}

struct WalletView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    private let creditAccounts = CreditAccount.sampleAccounts
    private let paymentPlans = PaymentPlansManager().paymentPlans
    private let savingsGoals = SavingsGoal.sampleData
    
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<11:
            return "Good morning"
        case 11..<16:
            return "Good day"
        case 16..<23:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
    private var outstandingInvoices: [InvoiceItem] {
        InvoiceItem.overdueSamples + InvoiceItem.dueSoonSamples
    }
    
    private var invoicePreview: [InvoiceItem] {
        Array(outstandingInvoices.prefix(3))
    }
    
    private var purchasesPreview: [PurchaseItem] {
        Array(PurchaseItem.sampleData.prefix(3))
    }
    
    private var actionsPreview: [ActionItem] {
        Array(ActionItem.priorityItems.prefix(3))
    }
    
    private var savingsPreview: [SavingsGoal] {
        Array(savingsGoals.prefix(3))
    }
    
    private var merchantSummaries: [MerchantPurchaseSummary] {
        let grouped = Dictionary(grouping: PurchaseItem.sampleData, by: { $0.merchant })
        return grouped.map { merchant, purchases in
            let total = purchases.reduce(0) { $0 + $1.numericAmount }
            return MerchantPurchaseSummary(
                merchant: merchant,
                totalAmount: total,
                displayAmount: formattedSEK(total),
                transactionCount: purchases.count,
                icon: purchases.first?.icon ?? "cart.fill",
                color: purchases.first?.color ?? .blue
            )
        }
        .sorted { $0.totalAmount > $1.totalAmount }
    }
    
    private var unpaidInvoicesCount: Int {
        outstandingInvoices.count
    }
    
    private var outstandingAmountLabel: String {
        formattedSEK(outstandingInvoices.reduce(0) { $0 + $1.numericAmount })
    }
    
    private var usedCreditLabel: String {
        let usedCredit = creditAccounts.reduce(0) { total, account in
            total + max(0, account.limit - account.available)
        }
        return formattedSEK(usedCredit)
    }
    
    private var savingsBalanceLabel: String {
        formattedSEK(savingsGoals.reduce(0) { $0 + $1.contributed })
    }
    
    private var merchantPurchaseTotalLabel: String {
        formattedSEK(merchantSummaries.reduce(0) { $0 + $1.totalAmount })
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "John",
                subtitle: greeting,
                trailingButton: "person.fill",
                trailingButtonTint: .black,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showProfile = true
                }
            ) {
                VStack(spacing: 28) {
                    let invoicesTap: () -> Void = { navigationPath.append(WalletDestination.invoices) }
                    let creditTap: () -> Void = { navigationPath.append(WalletDestination.purchases(filter: PurchaseFilter.mastercard)) }
                    let savingsTap: () -> Void = { navigationPath.append(WalletDestination.savings) }
                    let merchantPurchasesTap: () -> Void = { navigationPath.append(WalletDestination.purchases(filter: PurchaseFilter.merchants)) }
                    
                    WalletSummaryBento(
                        unpaidCount: unpaidInvoicesCount,
                        outstandingTotal: outstandingAmountLabel,
                        usedCredit: usedCreditLabel,
                        savingsBalance: savingsBalanceLabel,
                        merchantPurchaseTotal: merchantPurchaseTotalLabel,
                        onInvoicesTap: invoicesTap,
                        onCreditTap: creditTap,
                        onSavingsTap: savingsTap,
                        onMerchantPurchasesTap: merchantPurchasesTap
                    )
                    .padding(.horizontal)
                    
                    invoicesSection
                    purchasesSection
                    savingsSection
                    actionsSection
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: WalletDestination.self) { destination in
                switch destination {
                case .invoices:
                    InvoicesList(navigationPath: $navigationPath)
                case .purchases(let filter):
                    PurchasesList(
                        navigationPath: $navigationPath,
                        initialFilter: filter
                    )
                case .savings:
                    SavingsList(goals: savingsGoals)
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
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
    
    private var invoicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            WalletSectionHeader(
                title: "Upcoming invoices",
                actionTitle: "View all",
                action: { navigationPath.append(WalletDestination.invoices) }
            )
            
            VStack(spacing: 12) {
                if invoicePreview.isEmpty {
                    EmptyStateRow(
                        title: "No unpaid invoices",
                        subtitle: "We'll let you know when something is due"
                    )
                } else {
                    ForEach(invoicePreview) { invoice in
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
        }
        .padding(.horizontal)
    }
    
    private var purchasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            WalletSectionHeader(
                title: "Latest purchases",
                actionTitle: "View all",
                action: { navigationPath.append(WalletDestination.purchases(filter: .all)) }
            )
            
            VStack(spacing: 12) {
                ForEach(purchasesPreview) { purchase in
                    if let transaction = purchase.transaction {
                        Button {
                            navigationPath.append(transaction)
                        } label: {
                            PurchaseRow(
                                title: purchase.title,
                                subtitle: purchase.subtitleWithoutTime,
                                amount: purchase.amount,
                                icon: purchase.icon,
                                color: purchase.color,
                                paymentMethod: purchase.paymentMethod
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        PurchaseRow(
                            title: purchase.title,
                            subtitle: purchase.subtitleWithoutTime,
                            amount: purchase.amount,
                            icon: purchase.icon,
                            color: purchase.color,
                            paymentMethod: purchase.paymentMethod
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            WalletSectionHeader(
                title: "Priority actions",
                actionTitle: "View all",
                action: { navigationPath.append(WalletDestination.actions) }
            )
            
            VStack(spacing: 12) {
                ForEach(actionsPreview) { action in
                    ActionRow(
                        title: action.title,
                        subtitle: action.subtitle,
                        icon: action.icon,
                        color: action.color
                    )
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var savingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            WalletSectionHeader(
                title: "Savings goals",
                actionTitle: "View all",
                action: { navigationPath.append(WalletDestination.savings) }
            )
            
            VStack(spacing: 12) {
                if savingsPreview.isEmpty {
                    EmptyStateRow(
                        title: "No savings goals yet",
                        subtitle: "Create your first goal to start building momentum"
                    )
                } else {
                    ForEach(savingsPreview) { goal in
                        SavingsGoalRow(goal: goal)
                    }
                }
            }
        }
        .padding(.horizontal)
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
    case mastercard
    case merchants
    case swish
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .all:
            return "All"
        case .mastercard:
            return "Mastercard"
        case .merchants:
            return "Merchants"
        case .swish:
            return "Swish"
        }
    }
    
    var summaryDescription: String {
        switch self {
        case .all:
            return "All activity"
        case .mastercard:
            return "Resurs Mastercard"
        case .merchants:
            return "Connected merchants"
        case .swish:
            return "Swish payments"
        }
    }
    
    var accessibilityHint: String {
        switch self {
        case .all:
            return "Shows every purchase"
        case .mastercard:
            return "Shows purchases paid with Resurs Family Mastercard"
        case .merchants:
            return "Shows purchases paid with merchant accounts"
        case .swish:
            return "Shows purchases paid with Swish"
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
        if let transaction = purchase.transaction {
            Button {
                navigationPath.append(transaction)
            } label: {
                PurchaseRow(
                    title: purchase.title,
                    subtitle: purchase.subtitleWithoutTime,
                    amount: purchase.amount,
                    icon: purchase.icon,
                    color: purchase.color,
                    paymentMethod: purchase.paymentMethod
                )
            }
            .buttonStyle(.plain)
        } else {
            PurchaseRow(
                title: purchase.title,
                subtitle: purchase.subtitleWithoutTime,
                amount: purchase.amount,
                icon: purchase.icon,
                color: purchase.color,
                paymentMethod: purchase.paymentMethod
            )
        }
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

struct SavingsList: View {
    let goals: [SavingsGoal]
    @Environment(\.dismiss) private var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    
    private var summaryText: String {
        let totalSaved = goals.reduce(0) { $0 + $1.contributed }
        return "\(goals.count) goal\(goals.count == 1 ? "" : "s") · \(formattedSEK(totalSaved)) saved"
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
                                    .onChange(of: geo.frame(in: .named("savingsScroll")).minY) { _, newValue in
                                        scrollObserver.offset = max(0, -newValue)
                                    }
                            }
                            .frame(height: 0)
                            .id("savingsTop")
                            
                            Color.clear.frame(height: 120)
                            
                            VStack(spacing: 16) {
                                ForEach(goals) { goal in
                                    SavingsGoalRow(goal: goal)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 32)
                        }
                    }
                    .coordinateSpace(name: "savingsScroll")
                    .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("savingsTop", anchor: .top)
                        }
                    }
                }
                
                savingsHeader(scrollProgress: scrollProgress)
                    .frame(width: geometry.size.width)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func savingsHeader(scrollProgress: CGFloat) -> some View {
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
                    Text("Savings")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
            
            if scrollProgress <= 0.5 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Savings")
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
                .frame(width: 36, height: 36)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
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

struct SavingsGoalRow: View {
    let goal: SavingsGoal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(goal.name)
                        .font(.subheadline.weight(.semibold))
                    Text("Target \(goal.targetLabel) · by \(goal.deadline)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(goal.contributedLabel)
                    .font(.headline.weight(.semibold))
            }
            
            ProgressView(value: goal.progress)
            .progressViewStyle(.linear)
            .tint(goal.color)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(goal.name) savings goal. \(goal.contributedLabel) of \(goal.targetLabel) saved, due \(goal.deadline)")
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
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
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
            
            Text(amount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
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
        let circle = Circle()
            .fill(isSelected ? Color.accentColor : color)
            .frame(width: 44, height: 44)
            .overlay {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .foregroundColor(.white)
                } else if let icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(.white)
                }
            }
        
        if let onStatusTap {
            Button(action: onStatusTap) {
                circle
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Select \(title) for batch payment")
        } else {
            circle
        }
    }
}

struct CreditInfoBox: View {
    let accounts: [CreditAccount]
    @Binding var showDetails: Bool
    
    var body: some View {
        Button {
            showDetails = true
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                header
                
                Divider()
                    .background(Color.primary.opacity(0.1))
                
                VStack(spacing: 12) {
                    ForEach(Array(accounts.enumerated()), id: \.element.id) { index, account in
                        CreditAccountRow(account: account)
                        if index < accounts.count - 1 {
                            Divider()
                                .background(Color.primary.opacity(0.05))
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .buttonStyle(.plain)
        .background(.ultraThinMaterial)
        .background(Color(uiColor: .systemGreen).opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Available credit overview")
        .accessibilityValue(accessibilitySummary)
        .accessibilityHint("Opens detailed view with credit account PIN information")
        .sheet(isPresented: $showDetails) {
            CreditDetailsSheet()
                .presentationDetents([.fraction(0.33)])
                .presentationDragIndicator(.visible)
        }
    }
    private var accessibilitySummary: String {
        accounts
            .map { "\($0.name): \($0.availableLabel) available" }
            .joined(separator: ", ")
    }
    
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("My Cards")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            Spacer()
            Image(systemName: "creditcard.circle.fill")
                .font(.title3)
                .foregroundColor(.secondary)
        }
    }
}

struct CreditDetailsSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var showPIN = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                pinSection
                Spacer(minLength: 6)
                holdToRevealButton
            }
            .background(.ultraThinMaterial)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
    
    private var pinSection: some View {
        VStack(spacing: 14) {
            Text("Credit Card PIN")
                .font(.title2)
                .fontWeight(.bold)
            
            pinDisplay
            
            Text("Use this PIN for credit account purchases")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 8)
    }
    
    private var pinDisplay: some View {
        HStack(spacing: 12) {
            ForEach(currentDigits, id: \.self) { digit in
                pinDigitBox(for: digit)
            }
        }
    }
    
    private var holdToRevealButton: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: showPIN ? "eye.fill" : "eye.slash.fill")
                    .font(.title3)
                Text("Hold to show PIN")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.blue)
            .clipShape(Capsule())
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 12)
        .onLongPressGesture(minimumDuration: .infinity, maximumDistance: 44, pressing: { isPressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                showPIN = isPressing
            }
        }, perform: {})
        .accessibilityHint("Press and hold to temporarily reveal your PIN")
    }
    
    private var currentDigits: [String] {
        showPIN ? ["1", "2", "3", "4"] : ["*", "*", "*", "*"]
    }
    
    private func pinDigitBox(for digit: String) -> some View {
        Text(digit)
            .font(.system(size: 32, weight: .bold))
            .foregroundColor(.blue)
            .frame(width: 55, height: 65)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
    }
}

struct CreditAccountRow: View {
    let account: CreditAccount
    
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(accentColor.opacity(0.2))
                .frame(width: 48, height: 48)
                .overlay(
                    Image(systemName: "creditcard.fill")
                        .font(.title3)
                        .foregroundColor(accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(account.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(accentColor)
                    Text("View PIN")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(account.availableLabel)
                    .font(.headline)
                    .fontWeight(.bold)
                Text("available")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(account.name) has \(account.availableLabel) available")
    }
    
    private let accentColor = Color(uiColor: .systemGreen)
}

struct WalletInfoBox: View {
    let outstandingInvoices: [InvoiceItem]
    let batchInvoices: [InvoiceItem]
    
    private var outstandingTotal: String {
        formattedSEK(outstandingInvoices.filter { !$0.isSelected }.reduce(0) { $0 + $1.numericAmount })
    }
    
    private var batchTotal: String {
        formattedSEK(batchInvoices.reduce(0) { $0 + $1.numericAmount })
    }
    
    private var overdueCount: Int {
        outstandingInvoices.filter { $0.isOverdue && !$0.isSelected }.count
    }
    
    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Amount to Pay")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(outstandingTotal)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                
                if overdueCount > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                        Text("\(overdueCount) overdue invoice\(overdueCount == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Divider()
            
            HStack(spacing: 8) {
                Image(systemName: "square.grid.2x2.fill")
                    .foregroundColor(.blue)
                Text("Part payment options available")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if !batchInvoices.isEmpty {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(batchInvoices.count) selected")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Text("Ready for batch payment")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Text(batchTotal)
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
        }
        .padding(20)
        .background(Color.orange.opacity(0.1))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
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

struct WalletSummaryBento: View {
    let unpaidCount: Int
    let outstandingTotal: String
    let usedCredit: String
    let savingsBalance: String
    let merchantPurchaseTotal: String
    let onInvoicesTap: () -> Void
    let onCreditTap: () -> Void
    let onSavingsTap: () -> Void
    let onMerchantPurchasesTap: () -> Void
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.adaptive(minimum: 160), spacing: 12, alignment: .top)
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 12) {
            WalletSummaryCard(
                title: "Invoices to pay",
                headline: outstandingTotal,
                hint: "View all invoices",
                icon: "doc.text.fill",
                tint: .orange,
                action: onInvoicesTap
            )
            
            WalletSummaryCard(
                title: "Used Credit",
                headline: usedCredit,
                hint: "View all purchases",
                icon: "creditcard.fill",
                tint: .green,
                action: onCreditTap
            )
            
            WalletSummaryCard(
                title: "Savings",
                headline: savingsBalance,
                hint: "View all savings",
                icon: "shield.fill",
                tint: .mint,
                action: onSavingsTap
            )
            
            WalletSummaryCard(
                title: "Merchants",
                headline: merchantPurchaseTotal,
                hint: "View all purchases",
                icon: "bag.fill",
                tint: .indigo,
                action: onMerchantPurchasesTap
            )
        }
    }
}

struct WalletSummaryCard: View {
    let title: String
    let headline: String
    let hint: String
    let icon: String
    let tint: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tint)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(tint.opacity(0.15))
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .tracking(0.6)
                    Text(headline)
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundColor(.primary)
                }
                
                Text(hint)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(tint)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .buttonStyle(.plain)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(title). \(headline)")
        .accessibilityHint(hint)
    }
}

#Preview {
    WalletView()
        .preferredColorScheme(.dark)
}
