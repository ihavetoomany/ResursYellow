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
        } else if account.title == "Main Account" {
            // Credit card-style transactions for Main Account
            transactions = [
                TransactionItem(
                    date: "Nov 25, 2025",
                    description: "ICA Maxi",
                    amount: "1 245 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Nov 22, 2025",
                    description: "Stadium Outlet",
                    amount: "1 080 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Nov 18, 2025",
                    description: "Clas Ohlson",
                    amount: "890 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Nov 15, 2025",
                    description: "Åhléns",
                    amount: "2 450 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Nov 12, 2025",
                    description: "NetOnNet Warehouse",
                    amount: "12 499 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Nov 8, 2025",
                    description: "Bauhaus Megastore",
                    amount: "4 356 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Nov 3, 2025",
                    description: "Jula Kungens Kurva",
                    amount: "2 145 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 31, 2025",
                    description: "Payment received",
                    amount: "18 750 kr",
                    amountColor: .green
                ),
                TransactionItem(
                    date: "Oct 28, 2025",
                    description: "Elgiganten",
                    amount: "5 699 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 25, 2025",
                    description: "ICA",
                    amount: "452 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 20, 2025",
                    description: "Stadium",
                    amount: "2 340 SEK",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 15, 2025",
                    description: "Clas Ohlson",
                    amount: "785 SEK",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 10, 2025",
                    description: "Åhléns",
                    amount: "300 SEK",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 5, 2025",
                    description: "NetOnNet",
                    amount: "1 568 SEK",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Oct 2, 2025",
                    description: "Bauhaus",
                    amount: "4 356 kr",
                    amountColor: .red
                ),
                TransactionItem(
                    date: "Sep 30, 2025",
                    description: "Payment received",
                    amount: "15 200 kr",
                    amountColor: .green
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

