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
    @State private var showActionsMenu = false
    
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
                            // Next Payment Card
                            nextPaymentCard
                            
                            // Account Info Section
                            accountInfoSection
                            
                            // Transactions Section
                            transactionsSection
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        .padding(.bottom, 120)
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
                        
                        Button(action: { showActionsMenu = true }) {
                            Image(systemName: "ellipsis")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial)
                                .clipShape(Circle())
                        }
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
        .sheet(isPresented: $showActionsMenu) {
            ActionsSheet(
                onPayExtra: {
                    showActionsMenu = false
                    // Handle pay extra action
                },
                onMakeEndPayment: {
                    showActionsMenu = false
                    // Handle make end payment action
                }
            )
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
            .presentationBackground(.ultraThinMaterial)
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
            
            Divider()
            
            HStack {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(account.installmentAmount.isEmpty ? account.amount : account.installmentAmount)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Invoice created")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Nov 10, 2025")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Invoice due")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Nov 30, 2025")
                    .font(.subheadline)
                    .fontWeight(.medium)
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
                    Text("Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.title == "Main Account" ? "Account" : account.title == "Flex August" ? "Flex" : "Invoice Account")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Credit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Mastercard")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Current debt")
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
                    Text("540-1234")
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
        VStack(alignment: .leading, spacing: 16) {
            Text("Transactions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(sampleTransactions, id: \.id) { transaction in
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
    
    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Actions")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                Button {
                    // Handle pay extra action
                } label: {
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
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                }
                
                Button {
                    // Handle make end payment action
                } label: {
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
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.blue, lineWidth: 1.5)
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    private func generateOCR() -> String {
        // Generate a simple OCR number based on account title
        let hash = abs(account.title.hashValue) % 10000000
        return String(format: "%07d", hash)
    }
    
    private var sampleTransactions: [TransactionItem] {
        // Find the InvoiceAccount that matches this PartPaymentItem
        guard let invoiceAccount = dataManager.invoiceAccounts.first(where: { $0.id == account.id }) else {
            return []
        }
        
        // Get transactions for this account
        let accountTransactions = dataManager.transactionsForAccount(invoiceAccount.id)
        
        // Convert to TransactionItem and sort by date (newest first)
        return accountTransactions
            .map { $0.toTransactionItem(dateService: dateService) }
            .sorted { date1, date2 in
                // Parse dates and compare (simplified - assumes format "MMM d, yyyy")
                // For simplicity, we'll sort by transaction date offset
                let t1 = dataManager.transactions.first(where: { $0.id == date1.id })
                let t2 = dataManager.transactions.first(where: { $0.id == date2.id })
                let offset1 = t1?.dateOffset ?? 0
                let offset2 = t2?.dateOffset ?? 0
                return offset1 > offset2 // Newest first
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

