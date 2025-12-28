//  BauhausDetailView.swift
//  ResursYellow
//
//  Details and benefits for Bauhaus integration

import SwiftUI

struct BauhausDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @StateObject private var dataManager = DataManager.shared
    
    // Example credit info
    let availableCredit: String = "14 500 kr"
    let creditLimit: String = "20 000 kr"
    
    // Define a local struct to avoid collision with global PurchaseItem
    struct BauhausPurchase: Identifiable {
        let id = UUID()
        var title: String
        var subtitle: String
        var amount: String
        var icon: String
        var color: Color
        var category: Category
        var transaction: String?
        
        enum Category {
            case large, recent
        }
    }
    
    // Example purchases list using BauhausPurchase
    let purchases: [BauhausPurchase] = [
        BauhausPurchase(title: "Paint Roller Set", subtitle: "Nov 2, 2025", amount: "298 kr", icon: "paintbrush.pointed.fill", color: .red, category: .large, transaction: nil),
        BauhausPurchase(title: "Interior Paint", subtitle: "Nov 2, 2025", amount: "800 kr", icon: "paintpalette.fill", color: .red, category: .large, transaction: nil),
        BauhausPurchase(title: "Drop Cloth", subtitle: "Oct 5, 2025", amount: "200 kr", icon: "drop.fill", color: .red, category: .recent, transaction: nil)
    ]
    
    let benefits: [(icon: String, title: String, desc: String)] = [
        ("calendar.badge.clock", "Part Payment", "Choose flexible part payment plans for large purchases."),
        ("tag.fill", "Exclusive Deals", "Get access to member prices and special offers."),
        ("giftcard.fill", "Kickback", "Earn kickback on every purchase at Bauhaus."),
        ("shield.checkerboard", "Payment Insurance", "Protect your purchases with optional payment insurance.")
    ]
    
    // Part payments from DataManager (filtered for Bauhaus)
    private var partPayments: [PartPaymentItem] {
        dataManager.invoiceAccounts
            .filter { account in
                account.title.lowercased().contains("bauhaus") ||
                account.autopaySource.lowercased().contains("bauhaus")
            }
            .map { $0.toPartPaymentItem() }
    }
    
    let paintProjectInvoices: [PartPaymentInvoice] = [
        PartPaymentInvoice(
            installment: 1,
            dueDate: "Oct 15, 2025",
            amount: "726 kr",
            reference: "PP-2025-10-001",
            status: .paid
        ),
        PartPaymentInvoice(
            installment: 2,
            dueDate: "Nov 15, 2025",
            amount: "726 kr",
            reference: "PP-2025-11-001",
            status: .paid
        ),
        PartPaymentInvoice(
            installment: 3,
            dueDate: "Dec 15, 2025",
            amount: "726 kr",
            reference: "PP-2025-12-001",
            status: .upcoming
        ),
        PartPaymentInvoice(
            installment: 4,
            dueDate: "Jan 15, 2026",
            amount: "726 kr",
            reference: "PP-2026-01-001",
            status: .upcoming
        ),
        PartPaymentInvoice(
            installment: 5,
            dueDate: "Feb 15, 2026",
            amount: "726 kr",
            reference: "PP-2026-02-001",
            status: .upcoming
        ),
        PartPaymentInvoice(
            installment: 6,
            dueDate: "Mar 15, 2026",
            amount: "726 kr",
            reference: "PP-2026-03-001",
            status: .upcoming
        )
    ]
    
    let gardenSuppliesInvoices: [PartPaymentInvoice] = [
        PartPaymentInvoice(
            installment: 1,
            dueDate: "Sep 30, 2025",
            amount: "300 kr",
            reference: "PP-2025-09-001",
            status: .paid
        ),
        PartPaymentInvoice(
            installment: 2,
            dueDate: "Oct 30, 2025",
            amount: "300 kr",
            reference: "PP-2025-10-002",
            status: .paid
        ),
        PartPaymentInvoice(
            installment: 3,
            dueDate: "Nov 30, 2025",
            amount: "300 kr",
            reference: "PP-2025-11-002",
            status: .paid
        ),
        PartPaymentInvoice(
            installment: 4,
            dueDate: "Dec 30, 2025",
            amount: "300 kr",
            reference: "PP-2025-12-002",
            status: .upcoming
        ),
        PartPaymentInvoice(
            installment: 5,
            dueDate: "Jan 30, 2026",
            amount: "300 kr",
            reference: "PP-2026-01-002",
            status: .upcoming
        )
    ]
    
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
                        
                        // Top info box
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bauhaus offers Purchase Now, Pay Later (PNPL) with several part payment options.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("You can also open a credit account for easy checkout and part payment at Bauhaus stores and online.")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            Divider()
                            HStack(spacing: 32) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Available Credit")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(availableCredit)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Credit Limit")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(creditLimit)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                }
                                Spacer()
                            }
                        }
                        .padding(20)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        // Purchases
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Purchases")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 4)
                            VStack(spacing: 12) {
                                ForEach(purchases) { item in
                                    HStack(spacing: 16) {
                                        Image(systemName: item.icon)
                                            .font(.title3)
                                            .foregroundColor(item.color)
                                            .frame(width: 36, height: 36)
                                            .background(item.color.opacity(0.2))
                                            .clipShape(Circle())
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.title)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(item.subtitle)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        Spacer()
                                        Text(item.amount)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                    }
                                    .padding(16)
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Open Accounts Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Invoice accounts")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 4)
                            VStack(spacing: 12) {
                                ForEach(partPayments, id: \.title) { payment in
                                    if payment.title == "Bauhaus - October" && payment.totalAmount == "4 356 kr" {
                                        NavigationLink {
                                            PaintProjectSplitDetailView(plan: payment, invoices: paintProjectInvoices)
                                        } label: {
                                            PartPaymentRow(payment: payment, showsDisclosure: true)
                                        }
                                        .buttonStyle(.plain)
                                    } else if payment.title == "Bauhaus - September" && payment.totalAmount == "1 500 kr" {
                                        NavigationLink {
                                            PaintProjectSplitDetailView(plan: payment, invoices: gardenSuppliesInvoices)
                                        } label: {
                                            PartPaymentRow(payment: payment, showsDisclosure: true)
                                        }
                                        .buttonStyle(.plain)
                                    } else {
                                        PartPaymentRow(payment: payment, showsDisclosure: false)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        
                        // Benefits
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Benefits and services")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 4)
                            VStack(spacing: 12) {
                                ForEach(benefits, id: \.title) { benefit in
                                    HStack(spacing: 16) {
                                        Image(systemName: benefit.icon)
                                            .font(.title3)
                                            .foregroundColor(.red)
                                            .frame(width: 36, height: 36)
                                            .background(Color.red.opacity(0.15))
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
                                    .background(.ultraThinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                        .padding(.horizontal)
                        Spacer(minLength: 40)
                    }
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
            
            // Sticky Header (overlays the content)
            VStack(spacing: 0) {
                ZStack {
                    // Back button (always visible) - on the left
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
                    
                    // Minimized title - centered in view
                    if scrollProgress > 0.5 {
                        Text("Bauhaus")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
                
                // Title and subtitle - only shown when not minimized
                if scrollProgress <= 0.5 {
                    VStack(alignment: .leading, spacing: 4) {
                        // Subtitle
                        Text("Store Credit and Invoice available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(1.0 - scrollProgress * 2)
                        
                        // Title
                        Text("Bauhaus")
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
}

private struct PartPaymentRow: View {
    let payment: PartPaymentItem
    let showsDisclosure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(payment.subtitle)
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
                    Text("left to pay")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                }
            } else if payment.title.contains("Bauhaus") {
                HStack(spacing: 4) {
                    Text("Debt:")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(payment.totalAmount.isEmpty ? payment.amount : payment.totalAmount)
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
                .tint(.orange)
            
            HStack {
                Text("Part payment ongoing")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(payment.nextDueDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct PaintProjectSplitDetailView: View {
    let plan: PartPaymentItem
    let invoices: [PartPaymentInvoice]
    
    private var progressPercentage: String {
        let percent = plan.progress * 100
        return String(format: "%.0f%%", percent)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Next Payment Card
                nextPaymentCard
                
                // Account Info Section
                accountInfoSection
                
                // Transactions Section
                transactionsSection
                
                // Invoice History
                InvoiceHistorySection()
            }
            .padding()
        }
        .navigationTitle(plan.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(plan.totalAmount)
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("\(plan.installmentAmount) per month")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ProgressView(value: plan.progress)
                .tint(.red)
            
            HStack {
                Text("\(plan.completedPayments) of \(plan.totalPayments) payments completed")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Text(progressPercentage)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var nextPaymentCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("Next payment")
                    .font(.headline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.orange)
            }
            
            Divider()
            
            HStack {
                Text("Amount")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(plan.installmentAmount.isEmpty ? plan.amount : plan.installmentAmount)
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
                Text(plan.nextDueDate)
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
                    .foregroundColor(.orange)
                
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
                    Text(plan.title == "Bauhaus - October" ? "Account" : "Invoice")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Credit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(plan.title == "Bauhaus - October" ? "Store Credit" : "Onetime Credit")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Divider()
                
                HStack {
                    Text("Current debt")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(plan.totalAmount.isEmpty ? plan.amount : plan.totalAmount)
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
        .background(Color.orange.opacity(0.1))
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
    
    // MARK: - Helper Methods
    private func generateOCR() -> String {
        // Generate a simple OCR number based on plan title
        let hash = abs(plan.title.hashValue) % 10000000
        return String(format: "%07d", hash)
    }
    
    private var sampleTransactions: [TransactionItem] {
        [
            TransactionItem(
                id: UUID(),
                date: "Nov 15, 2025",
                description: "Payment received",
                amount: plan.installmentAmount.isEmpty ? "726 kr" : plan.installmentAmount,
                amountColor: .green
            ),
            TransactionItem(
                id: UUID(),
                date: "Oct 15, 2025",
                description: "Payment received",
                amount: plan.installmentAmount.isEmpty ? "726 kr" : plan.installmentAmount,
                amountColor: .green
            ),
            TransactionItem(
                id: UUID(),
                date: "Sep 15, 2025",
                description: "Payment received",
                amount: plan.installmentAmount.isEmpty ? "726 kr" : plan.installmentAmount,
                amountColor: .green
            )
        ]
    }
    
}

// Note: PartPaymentItem is defined in InvoiceAccountExtensions.swift

struct PartPaymentInvoice: Identifiable {
    enum Status {
        case paid
        case upcoming
        
        var label: String {
            switch self {
            case .paid:
                return "Paid"
            case .upcoming:
                return "Upcoming"
            }
        }
        
        var color: Color {
            switch self {
            case .paid:
                return .green
            case .upcoming:
                return .red
            }
        }
    }
    
    let id = UUID()
    let installment: Int
    let dueDate: String
    let amount: String
    let reference: String
    let status: Status
}


#Preview {
    BauhausDetailView()
        .preferredColorScheme(.light)
}
