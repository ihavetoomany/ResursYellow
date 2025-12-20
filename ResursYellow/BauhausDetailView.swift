//  BauhausDetailView.swift
//  ResursYellow
//
//  Details and benefits for Bauhaus integration

import SwiftUI

struct BauhausDetailView: View {
    // Example credit info
    let availableCredit: String = "14 500 kr"
    let creditLimit: String = "25 000 kr"
    
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
        BauhausPurchase(title: "Paint Roller Set", subtitle: "Nov 2, 2025", amount: "298 kr", icon: "paintbrush.pointed.fill", color: .orange, category: .large, transaction: nil),
        BauhausPurchase(title: "Interior Paint", subtitle: "Nov 2, 2025", amount: "800 kr", icon: "paintpalette.fill", color: .orange, category: .large, transaction: nil),
        BauhausPurchase(title: "Drop Cloth", subtitle: "Oct 5, 2025", amount: "200 kr", icon: "drop.fill", color: .orange, category: .recent, transaction: nil)
    ]
    
    let benefits: [(icon: String, title: String, desc: String)] = [
        ("calendar.badge.clock", "Part Payment", "Choose flexible part payment plans for large purchases."),
        ("tag.fill", "Exclusive Deals", "Get access to member prices and special offers."),
        ("giftcard.fill", "Kickback", "Earn kickback on every purchase at Bauhaus."),
        ("shield.checkerboard", "Payment Insurance", "Protect your purchases with optional payment insurance.")
    ]
    
    // Example part payments for the new section
    let partPayments: [PartPaymentItem] = [
        PartPaymentItem(
            title: "Paint Project Split",
            subtitle: "2 of 6 payments completed",
            amount: "726 kr / 4 356 kr",
            progress: 2.0/6.0,
            installmentAmount: "726 kr",
            totalAmount: "4 356 kr",
            completedPayments: 2,
            totalPayments: 6,
            nextDueDate: "Dec 15, 2025",
            autopaySource: "Bauhaus Invoice"
        ),
        PartPaymentItem(
            title: "Kitchen Remodel",
            subtitle: "1 of 4 payments completed",
            amount: "1 200 kr / 4 800 kr",
            progress: 1.0/4.0,
            installmentAmount: "1 200 kr",
            totalAmount: "4 800 kr",
            completedPayments: 1,
            totalPayments: 4,
            nextDueDate: "Nov 28, 2025",
            autopaySource: "Resurs Family"
        ),
        PartPaymentItem(
            title: "Garden Supplies",
            subtitle: "3 of 5 payments completed",
            amount: "900 kr / 1 500 kr",
            progress: 3.0/5.0,
            installmentAmount: "300 kr",
            totalAmount: "1 500 kr",
            completedPayments: 3,
            totalPayments: 5,
            nextDueDate: "Nov 30, 2025",
            autopaySource: "Swish"
        )
    ]
    
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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack {
                    Image(systemName: "house.lodge.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.orange)
                        .background(
                            Circle()
                                .fill(Color.orange.opacity(0.12))
                                .frame(width: 82, height: 82)
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                
                // Top info box
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Easy flexible payments")
                                .font(.headline)
                                .fontWeight(.semibold)
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
                
                // Purchases
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Bauhaus Purchases")
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
                    Text("Open Accounts")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    VStack(spacing: 12) {
                        ForEach(partPayments, id: \.title) { payment in
                            if payment.title == "Paint Project Split" {
                                NavigationLink {
                                    PaintProjectSplitDetailView(plan: payment, invoices: paintProjectInvoices)
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
                    Text("Bauhaus Benefits")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    VStack(spacing: 12) {
                        ForEach(benefits, id: \.title) { benefit in
                            HStack(spacing: 16) {
                                Image(systemName: benefit.icon)
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                    .frame(width: 36, height: 36)
                                    .background(Color.orange.opacity(0.15))
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
            .padding(.top, 16)
        }
        .navigationTitle("Bauhaus")
        .navigationBarTitleDisplayMode(.inline)
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
            
            Text(payment.amount)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ProgressView(value: payment.progress)
                .tint(.orange)
            
            HStack {
                Text("\(payment.completedPayments) of \(payment.totalPayments) payments")
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
            VStack(spacing: 20) {
                summaryCard
                nextPaymentCard
                PartPaymentsExplanationCard()
                    .padding(.horizontal, 4)
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
                .tint(.orange)
            
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
                Text("Due date")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(plan.nextDueDate)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            HStack {
                Text("Payment method")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(plan.autopaySource)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
}

// Supporting structs for example data models to avoid errors
struct PartPaymentItem {
    var title: String
    var subtitle: String
    var amount: String
    var progress: Double
    var installmentAmount: String = ""
    var totalAmount: String = ""
    var completedPayments: Int = 0
    var totalPayments: Int = 0
    var nextDueDate: String = ""
    var autopaySource: String = ""
    
    var hasDetailedSchedule: Bool {
        !installmentAmount.isEmpty &&
        !totalAmount.isEmpty &&
        totalPayments > 0 &&
        !nextDueDate.isEmpty
    }
}

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
                return .orange
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
