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
    
    let account: PartPaymentItem
    
    var body: some View {
        let scrollProgress = min(scrollObserver.offset / 100, 1.0)
        
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
                        
                        // Account for header height
                        Color.clear.frame(height: 120)
                    
                        VStack(spacing: 24) {
                            // Account Info Section
                            accountInfoSection
                            
                            // Transactions Section
                            transactionsSection
                            
                            // Actions Section
                            actionsSection
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
            
            // Sticky Header
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
                        Text(account.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
                
                if scrollProgress <= 0.5 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Invoice Account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(1.0 - scrollProgress * 2)
                        
                        Text(account.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
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
        .navigationBarHidden(true)
    }
    
    // MARK: - Account Info Section
    private var accountInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Account Info")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Total debt")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(account.totalAmount.isEmpty ? account.amount : account.totalAmount)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Button(action: {
                        let value = account.totalAmount.isEmpty ? account.amount : account.totalAmount
                        UIPasteboard.general.string = value
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                    Button(action: {
                        UIPasteboard.general.string = generateOCR()
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                    Button(action: {
                        UIPasteboard.general.string = "540-1234"
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
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
                    Button(action: {
                        let value = account.installmentAmount.isEmpty ? account.amount : account.installmentAmount
                        UIPasteboard.general.string = value
                    }) {
                        Image(systemName: "doc.on.doc")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                Divider()
                
                HStack {
                    Text("Due")
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
                        amount: transaction.amount
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
        [
            TransactionItem(
                date: "Nov 15, 2025",
                description: "Payment received",
                amount: account.installmentAmount.isEmpty ? "5 326 kr" : account.installmentAmount
            ),
            TransactionItem(
                date: "Oct 15, 2025",
                description: "Payment received",
                amount: account.installmentAmount.isEmpty ? "5 326 kr" : account.installmentAmount
            ),
            TransactionItem(
                date: "Sep 15, 2025",
                description: "Payment received",
                amount: account.installmentAmount.isEmpty ? "5 326 kr" : account.installmentAmount
            )
        ]
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
}

