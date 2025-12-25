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
                
                Divider()
                
                HStack {
                    Text("Next invoice")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.installmentAmount.isEmpty ? account.amount : account.installmentAmount)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Next due")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.nextDueDate.isEmpty ? "Not scheduled" : account.nextDueDate)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Status")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Upcoming")
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
        var transactions: [TransactionItem] = []
        
        // Add transactions for Flex August account with specific dates
        if account.title == "Flex August" {
            transactions = [
                TransactionItem(
                    date: "Oct 30, 2025",
                    description: "Payment received",
                    amount: account.installmentAmount.isEmpty ? "917 kr" : account.installmentAmount,
                    amountColor: .green
                ),
                TransactionItem(
                    date: "Sep 30, 2025",
                    description: "Payment received",
                    amount: account.installmentAmount.isEmpty ? "917 kr" : account.installmentAmount,
                    amountColor: .green
                ),
                TransactionItem(
                    date: "Aug 30, 2025",
                    description: "Payment received",
                    amount: account.installmentAmount.isEmpty ? "917 kr" : account.installmentAmount,
                    amountColor: .green
                ),
                TransactionItem(
                    date: "Jul 10, 2025",
                    description: "Apoteket Hjärtat",
                    amount: "5 500 kr",
                    amountColor: .red
                )
            ]
        } else {
            // Default transactions for other accounts
            transactions = [
                TransactionItem(
                    date: "Nov 15, 2025",
                    description: "Payment received",
                    amount: account.installmentAmount.isEmpty ? "5 326 kr" : account.installmentAmount,
                    amountColor: .green
                ),
                TransactionItem(
                    date: "Oct 15, 2025",
                    description: "Payment received",
                    amount: account.installmentAmount.isEmpty ? "5 326 kr" : account.installmentAmount,
                    amountColor: .green
                ),
                TransactionItem(
                    date: "Sep 15, 2025",
                    description: "Payment received",
                    amount: account.installmentAmount.isEmpty ? "5 326 kr" : account.installmentAmount,
                    amountColor: .green
                )
            ]
        }
        
        return transactions
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

struct TransactionItem: Identifiable {
    let id = UUID()
    let date: String
    let description: String
    let amount: String
    let amountColor: Color
}

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

