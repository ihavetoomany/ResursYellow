//
//  InvoiceAccountDetailView.swift
//  ResursYellow
//
//  Created on 2025-11-09.
//

import SwiftUI

struct InvoiceAccountDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @StateObject private var dataManager = DataManager.shared
    private let dateService = DateService.shared
    @State private var cachedInvoices: [InvoiceItem] = []
    @State private var cachedTransactions: [TransactionItem] = []
    
    let account: PartPaymentItem
    
    var body: some View {
        
        ZStack(alignment: .top) {
            // Scrollable Content
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Tracking element
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .named("scroll")).minY) { oldValue, newValue in
                                    scrollObserver.offset = max(0, -newValue)
                                }
                        }
                        .frame(height: 0)
                        .id("scrollTop")
                        
                        // Account for header height (minimized)
                        Color.clear.frame(height: 60)
                    
                        VStack(spacing: 24) {
                            // Account description text
                            Text("This account is the main account of the Resurs Gold product. Every month, around the 5th, a new invoice is created reflecting the balance of the previous month. Due date is always the last day of the month and there are always options to part pay on the invoice.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Account Info Section
                            accountInfoSection
                            
                            // Next Payment Card
                            nextPaymentCard
                            
                            // Transactions Section
                            transactionsSection
                            
                            // Invoice History Section
                            invoiceHistorySection
                            
                            // Actions Section
                            actionsSection
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 24)
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        proxy.scrollTo("scrollTop", anchor: .top)
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            
            // Sticky Header (always minimized)
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
                    
                    // Always show minimized title
                    Text(account.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .background(Color(uiColor: .systemBackground).opacity(0.95))
            .background(.ultraThinMaterial)
        }
        .navigationBarHidden(true)
        .onAppear {
            if cachedInvoices.isEmpty {
                cachedInvoices = generateInvoices()
            }
            if cachedTransactions.isEmpty {
                cachedTransactions = loadTransactions()
            }
        }
    }
    
    // MARK: - Next Payment Card
    private var nextPaymentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Next payment")
                    .font(.headline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("To pay by \(formatDueDate(account.nextDueDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.installmentAmount.isEmpty ? account.amount : account.installmentAmount)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Received amount")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("0 kr")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Account Info Section
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Account information")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Account Number")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(generateAccountNumber())
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.title == "Main Account" ? "Credit Account" : account.title == "Flex August" ? "Flex" : "Invoice Account")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Credit Limit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("80 000 kr")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Utilized Credit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.totalAmount.isEmpty ? account.amount : account.totalAmount)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("OCR")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(generateOCR())
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Bankgiro")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("123-456")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
            }
        }
        .padding(20)
        .background(Color.blue.opacity(0.1))
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Transactions Section
    private var transactionsSection: some View {
        let transactions = cachedTransactions
        
        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Transactions")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    // Handle view all transactions
                }) {
                    Text("View all")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            if transactions.isEmpty {
                Text("No transactions yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
            } else {
                VStack(spacing: 12) {
                    ForEach(Array(transactions.prefix(8)), id: \.id) { transaction in
                        TransactionRow(
                            date: transaction.date,
                            description: transaction.description,
                            amount: transaction.amount,
                            amountColor: transaction.amountColor
                        )
                    }
                }
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Invoice History Section
    private var invoiceHistorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Invoices")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    // Handle view all invoices
                }) {
                    Text("View all")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            
            VStack(spacing: 12) {
                ForEach(Array(generatedInvoices.prefix(8))) { invoice in
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
            }
        }
        .padding(.top, 24)
    }
    
    private var generatedInvoices: [InvoiceItem] {
        cachedInvoices
    }
    
    private func generateInvoices() -> [InvoiceItem] {
        // Static list of 8 invoices for the last 8 months (optimized for performance)
        let monthNames = ["DEC", "NOV", "OCT", "SEP", "AUG", "JUL", "JUN", "MAY"]
        let amounts = [12345, 10232, 3453, 5678, 8901, 2345, 6789, 4567]
        let issueDates = ["2026-01-05", "2025-12-05", "2025-11-05", "2025-10-05", "2025-09-05", "2025-08-05", "2025-07-05", "2025-06-05"]
        let dueDates = ["Jan 31, 2026", "Dec 31, 2025", "Nov 30, 2025", "Oct 31, 2025", "Sep 30, 2025", "Aug 31, 2025", "Jul 31, 2025", "Jun 30, 2025"]
        let invoiceNumbers = ["RG-DEC-2025", "RG-NOV-2025", "RG-OCT-2025", "RG-SEP-2025", "RG-AUG-2025", "RG-JUL-2025", "RG-JUN-2025", "RG-MAY-2025"]
        
        // Create NumberFormatter once
        let amountFormatter = NumberFormatter()
        amountFormatter.numberStyle = .decimal
        amountFormatter.groupingSeparator = " "
        amountFormatter.maximumFractionDigits = 0
        amountFormatter.minimumFractionDigits = 0
        
        var invoices: [InvoiceItem] = []
        
        for i in 0..<8 {
            let isPaid = i > 0 // All except current month are paid
            let amountString = (amountFormatter.string(from: NSNumber(value: amounts[i])) ?? "\(amounts[i])") + " kr"
            let merchantName = "Resurs Gold - \(monthNames[i])"
            let statusText = isPaid ? "Paid" : "Due soon"
            
            let invoice = InvoiceItem(
                merchant: merchantName,
                subtitle: issueDates[i],
                amount: amountString,
                icon: "doc.text.fill",
                color: isPaid ? .green : .blue,
                isOverdue: false,
                statusOverride: isPaid ? statusText : nil,
                category: isPaid ? .handledPaid : .dueSoon,
                detail: InvoiceData(
                    merchant: merchantName,
                    amount: amountString,
                    dueDate: dueDates[i],
                    invoiceNumber: invoiceNumbers[i],
                    issueDate: issueDates[i],
                    status: statusText,
                    color: isPaid ? .green : .blue
                )
            )
            
            invoices.append(invoice)
        }
        
        return invoices
    }
    
    private func formatAmount(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        return (formatter.string(from: NSNumber(value: value)) ?? "\(Int(value))") + " kr"
    }
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 24)
            
            VStack(spacing: 0) {
                Button {
                    // Handle pay extra action
                } label: {
                    HStack {
                        Text("Pay Extra")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading, 16)
                
                Button {
                    // Handle make end payment action
                } label: {
                    HStack {
                        Text("Make end payment")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.leading, 16)
                
                Button {
                    // Handle close account action
                } label: {
                    HStack {
                        Text("Close account")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                    .padding(16)
                }
                .buttonStyle(.plain)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Helper Methods
    private func generateAccountNumber() -> String {
        // Generate account number based on account ID
        let hash = abs(account.id.hashValue) % 1000000000
        return String(format: "%09d", hash)
    }
    
    private func generateOCR() -> String {
        // Generate a simple OCR number based on account title
        let hash = abs(account.title.hashValue) % 10000000
        return String(format: "%07d", hash)
    }
    
    private func formatDueDate(_ dateString: String) -> String {
        // Parse date string (format: "Nov 30, 2025") and format as "Nov 30"
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MMM d"
            return outputFormatter.string(from: date)
        }
        
        // Fallback: return original string if parsing fails
        return dateString
    }
    
    private func loadTransactions() -> [TransactionItem] {
        // Find the InvoiceAccount that matches this PartPaymentItem
        guard let invoiceAccount = dataManager.invoiceAccounts.first(where: { $0.id == account.id }) else {
            return []
        }
        
        // Get transactions for this account and sort by dateOffset first (before conversion)
        let accountTransactions = dataManager.transactionsForAccount(invoiceAccount.id)
            .sorted { $0.dateOffset > $1.dateOffset } // Newest first
        
        return accountTransactions.map { transaction in
            let item = transaction.toTransactionItem(dateService: dateService)
            // Change red amounts to white
            if transaction.amountColorName.lowercased() == "red" {
                return TransactionItem(
                    id: item.id,
                    date: item.date,
                    description: item.description,
                    amount: item.amount,
                    amountColor: .white
                )
            }
            return item
        }
    }
}

// MARK: - Supporting Views
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TransactionRow: View {
    let date: String
    let description: String
    let amount: String
    let amountColor: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(description)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(amount)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(amountColor)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// TransactionItem is now defined in TransactionExtensions.swift

// MARK: - Actions Sheet
struct ActionsSheet: View {
    @Environment(\.dismiss) var dismiss
    let onPayExtra: () -> Void
    let onMakeEndPayment: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Button(action: onPayExtra) {
                HStack {
                    Spacer()
                    Text("Pay Extra")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(Color.clear)
                .overlay(
                    Capsule()
                        .stroke(Color.blue, lineWidth: 1.5)
                )
            }
            
            Button(action: onMakeEndPayment) {
                HStack {
                    Spacer()
                    Text("Make end payment")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    Spacer()
                }
                .padding(.vertical, 16)
                .background(Color.clear)
                .overlay(
                    Capsule()
                        .stroke(Color.blue, lineWidth: 1.5)
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 20)
    }
}

