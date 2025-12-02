//
//  WalletView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct TransactionData: Hashable {
    let merchant: String
    let amount: String
    let date: String
    let time: String
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

struct WalletView: View {
    @State private var selectedTab = 1
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
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
    
    private var unpaidInvoicesCount: Int {
        InvoiceItem.overdueSamples.count + InvoiceItem.dueSoonSamples.count
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
                // Sticky Pills Section
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        Button(action: { selectedTab = 1 }) {
                            Text("Purchases")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 1 ? .primary : .secondary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(selectedTab == 1 ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(selectedTab == 1 ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Button(action: { selectedTab = 0 }) {
                            Text(unpaidInvoicesCount > 0 ? "Invoices (\(unpaidInvoicesCount))" : "Invoices")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 0 ? .primary : .secondary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(selectedTab == 0 ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(selectedTab == 0 ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                        
                        Button(action: { selectedTab = 2 }) {
                            Text("Actions")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 2 ? .primary : .secondary)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(selectedTab == 2 ? Color.blue.opacity(0.2) : Color.clear)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(selectedTab == 2 ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 12)
            } content: {
                VStack(spacing: 16) {
                    // Content based on selected tab
                    if selectedTab == 1 {
                        PurchasesList(navigationPath: $navigationPath)
                    } else if selectedTab == 0 {
                        InvoicesList(navigationPath: $navigationPath)
                    } else {
                        ActionsList()
                    }
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: TransactionData.self) { transaction in
                TransactionDetailView(
                    merchant: transaction.merchant,
                    amount: transaction.amount,
                    date: transaction.date,
                    time: transaction.time
                )
            }
            .navigationDestination(for: InvoiceData.self) { invoice in
                InvoiceDetailView(invoice: invoice)
            }
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                // If not at root level, pop to root
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
                // If at root, the StickyHeaderView will handle scrolling to top
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }
}

struct PurchaseItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let amount: String
    let icon: String
    let color: Color
    let category: PurchaseCategory
    let transaction: TransactionData?
    
    static let sampleData: [PurchaseItem] = [
        PurchaseItem(title: "Coffee Shop", subtitle: "Today, 2:30 PM", amount: "45 SEK", icon: "creditcard.fill", color: .brown, category: .recent, transaction: nil),
        PurchaseItem(title: "IKEA", subtitle: "Yesterday, 5:15 PM", amount: "23 000 SEK", icon: "heart.fill", color: .blue, category: .large, transaction: TransactionData(merchant: "IKEA", amount: "23 000 SEK", date: "Nov 2, 2025", time: "5:15 PM")),
        PurchaseItem(title: "Gas Station", subtitle: "Yesterday, 8:30 AM", amount: "452 SEK", icon: "creditcard.fill", color: .brown, category: .recent, transaction: nil),
        PurchaseItem(title: "Online Purchase", subtitle: "2 days ago, 7:45 PM", amount: "900 SEK", icon: "heart.fill", color: .blue, category: .online, transaction: nil),
        PurchaseItem(title: "Restaurant", subtitle: "3 days ago, 7:00 PM", amount: "322 SEK", icon: "heart.fill", color: .blue, category: .dining, transaction: nil),
        PurchaseItem(title: "Bauhaus", subtitle: "4 days ago, 11:20 AM", amount: "4 356 kr", icon: "diamond.fill", color: .orange, category: .large, transaction: TransactionData(merchant: "Bauhaus", amount: "4 356 kr", date: "4 days ago", time: "11:20 AM")),
        PurchaseItem(title: "Bookstore", subtitle: "5 days ago, 3:15 PM", amount: "190 SEK", icon: "creditcard.fill", color: .brown, category: .recent, transaction: nil),
        PurchaseItem(title: "Movie Theater", subtitle: "6 days ago, 8:45 PM", amount: "245 SEK", icon: "creditcard.fill", color: .brown, category: .entertainment, transaction: nil),
        PurchaseItem(title: "Clothing Store", subtitle: "1 week ago, 2:30 PM", amount: "1 568 SEK", icon: "creditcard.fill", color: .brown, category: .shopping, transaction: nil)
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

struct PurchasesList: View {
    @Binding var navigationPath: NavigationPath
    @State private var showCreditDetails = false
    @State private var selectedFilter: PurchaseCategory = .all
    @State private var showFilterSheet = false
    
    private var filteredPurchases: [PurchaseItem] {
        switch selectedFilter {
        case .all:
            return PurchaseItem.sampleData
        default:
            return PurchaseItem.sampleData.filter { $0.category == selectedFilter }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            CreditInfoBox(showDetails: $showCreditDetails)
                .padding(.vertical, 8)
            
            HStack {
                filterControl
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(filteredPurchases) { purchase in
                    if let transaction = purchase.transaction {
                        Button {
                            navigationPath.append(transaction)
                        } label: {
                            PurchaseRow(
                                title: purchase.title,
                                subtitle: purchase.subtitle,
                                amount: purchase.amount,
                                icon: purchase.icon,
                                color: purchase.color
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        PurchaseRow(
                            title: purchase.title,
                            subtitle: purchase.subtitle,
                            amount: purchase.amount,
                            icon: purchase.icon,
                            color: purchase.color
                        )
                    }
                }
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showFilterSheet) {
            NavigationStack {
                List {
                    Section("Choose filter") {
                        ForEach(PurchaseCategory.allCases) { category in
                            Button {
                                selectedFilter = category
                                showFilterSheet = false
                            } label: {
                                HStack {
                                    Text(category.label)
                                    Spacer()
                                    if selectedFilter == category {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .tint(.primary)
                        }
                    }
                }
                .navigationTitle("Filter Purchases")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showFilterSheet = false
                        }
                    }
                }
            }
        }
    }
    
    private var filterControl: some View {
        Button {
            showFilterSheet = true
        } label: {
            HStack(spacing: 6) {
                Text(selectedFilter.label.uppercased())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                Image(systemName: "chevron.down")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
        }
        .buttonStyle(.plain)
    }
}

struct ActionsList: View {
    var body: some View {
        VStack(spacing: 12) {
            // "Suggestions" Section Header
            HStack {
                Text("Suggestions")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 12)
            .padding(.bottom, 4)
            
            ActionRow(
                title: "Connect Bank Account",
                subtitle: "Link your bank",
                icon: "building.columns.fill",
                color: .blue
            )
            
            ActionRow(
                title: "Complete Loan Application",
                subtitle: "Finish your application",
                icon: "doc.text.fill",
                color: .orange
            )
            
            ActionRow(
                title: "Update KYC",
                subtitle: "Verify your identity",
                icon: "person.text.rectangle.fill",
                color: .purple
            )
            
            ActionRow(
                title: "Activate Click to Pay",
                subtitle: "Enable quick payments",
                icon: "hand.tap.fill",
                color: .cyan
            )
        }
        .padding(.horizontal)
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

struct InvoicesList: View {
    @Binding var navigationPath: NavigationPath
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

    var body: some View {
        VStack(spacing: 12) {
            // Quick Info Box
            WalletInfoBox(
                outstandingInvoices: outstandingPool,
                batchInvoices: selectedInvoices
            )
                .padding(.vertical, 8)
            
            // "TO PAY" Section Header
            HStack {
                Text("TO PAY")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 4)
            .padding(.bottom, 4)
            
            ForEach(overdueInvoices) { invoice in
                invoiceButton(for: invoice, allowBatching: true)
            }
            
            ForEach(dueSoonInvoices) { invoice in
                invoiceButton(for: invoice, allowBatching: true)
            }
            
            // "Handled" Section Header
            HStack {
                Text("Handled")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
                Spacer()
            }
            .padding(.horizontal, 4)
            .padding(.top, 12)
            .padding(.bottom, 4)
            
            ForEach(scheduledInvoices) { invoice in
                invoiceButton(for: invoice, allowBatching: false)
            }
            
            ForEach(paidInvoices) { invoice in
                invoiceButton(for: invoice, allowBatching: false)
            }
        }
        .padding(.horizontal)
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
}

struct PurchaseRow: View {
    let title: String
    let subtitle: String
    let amount: String
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
                    ForEach(Array(creditAccounts.enumerated()), id: \.element.name) { index, account in
                        CreditAccountRow(
                            name: account.name,
                            available: account.available,
                            limit: account.limit
                        )
                        if index < creditAccounts.count - 1 {
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
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    private let creditAccounts: [(name: String, available: String, limit: String)] = [
        (name: "Resurs Gold", available: "25 000 SEK", limit: "50 000 SEK"),
        (name: "Resurs Family", available: "15 000 SEK", limit: "30 000 SEK")
    ]
    
    private var accessibilitySummary: String {
        creditAccounts
            .map { "\($0.name): \($0.available) available" }
            .joined(separator: ", ")
    }
    
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Available Credit")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("Across your credit accounts")
                    .font(.caption)
                    .foregroundColor(.secondary)
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
            VStack(spacing: 16) {
                // PIN Code Section
                VStack(spacing: 12) {
                    Text("Credit Account PIN")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    // PIN Display
                    HStack(spacing: 12) {
                        ForEach(showPIN ? ["1", "2", "3", "4"] : ["*", "*", "*", "*"], id: \.self) { digit in
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
                    
                    Text("Use this PIN for credit account purchases")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 24)
                
                Spacer()
                    .frame(height: 40)
                
                // Show PIN Button
                Button(action: {
                    withAnimation {
                        showPIN.toggle()
                    }
                }) {
                    HStack {
                        Image(systemName: showPIN ? "eye.slash.fill" : "eye.fill")
                            .font(.title3)
                        Text(showPIN ? "Hide PIN" : "Show PIN")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(UIColor.systemBackground))
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
}

struct CreditAccountRow: View {
    let name: String
    let available: String
    let limit: String
    
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
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundColor(accentColor)
                    Text("PIN protected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text(available)
                    .font(.headline)
                    .fontWeight(.bold)
                Text("of \(limit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(name) has \(available) available of \(limit)")
    }
    
    private let accentColor = Color(uiColor: .systemGreen)
}

struct WalletInfoBox: View {
    let outstandingInvoices: [InvoiceItem]
    let batchInvoices: [InvoiceItem]
    
    private var outstandingTotal: String {
        formattedAmount(for: outstandingInvoices.filter { !$0.isSelected }.reduce(0) { $0 + $1.numericAmount })
    }
    
    private var batchTotal: String {
        formattedAmount(for: batchInvoices.reduce(0) { $0 + $1.numericAmount })
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
    
    private func formattedAmount(for value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        let formatted = formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))"
        return "\(formatted) SEK"
    }
}

#Preview {
    WalletView()
        .preferredColorScheme(.dark)
}
