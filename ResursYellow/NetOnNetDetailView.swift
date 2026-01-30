import SwiftUI

struct NetOnNetDetailView: View {
    @StateObject private var dataManager = DataManager.shared
    
    private let availableCredit = "20 000 kr"
    private let creditLimit = "20 000 kr"
    
    struct MerchantPurchase: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let amount: String
        let icon: String
        let color: Color
    }
    
    private let purchases: [MerchantPurchase] = [
        MerchantPurchase(title: "Smart TV 65\"", subtitle: "Nov 6, 2023", amount: "12 499 kr", icon: "display.2", color: .blue),
        MerchantPurchase(title: "Soundbar Bundle", subtitle: "Oct 28, 2023", amount: "4 299 kr", icon: "speaker.wave.3.fill", color: .purple)
    ]
    
    private let benefits: [(icon: String, title: String, description: String)] = [
        ("shippingbox.fill", "Warehouse Pick-up", "Reserve online, collect your tech within hours at your nearest warehouse."),
        ("sparkles", "Extended Warranty", "Add product protection that mirrors NetOnNet’s in-store offer."),
        ("creditcard.and.123", "Flexible PNPL", "Split large electronics into monthly payments with instant approval.")
    ]
    
    private let documents: [(icon: String, titleKey: String, descKey: String)] = [
        ("doc.text.fill", "Credit Agreement", "View your NetOnNet credit account terms and conditions"),
        ("doc.text", "Terms and Conditions", "Read the terms and conditions for NetOnNet"),
        ("hand.raised.fill", "Privacy Policy", "Review how we handle your personal information"),
        ("doc.on.doc.fill", "Payment Plan Agreement", "View your active payment plan agreements")
    ]
    
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                summaryCard
                purchasesSection
                partPaymentsSection
                benefitsSection
                documentsSection
                helpAndSupportSection
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Netonnet")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Available Credit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(availableCredit)
                        .font(.system(size: 34, weight: .bold))
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                Image(systemName: "shippingbox.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 56, height: 56)
                    .background(Color.green.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            
            Divider()
                .background(Color.primary.opacity(0.1))
            
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Credit Limit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(creditLimit)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Used Credit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("0 kr")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Netonnet available credit \(availableCredit). Credit limit \(creditLimit). No credit used.")
    }
    
    private var purchasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Purchases")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                ForEach(purchases) { purchase in
                    HStack(spacing: 16) {
                        Image(systemName: purchase.icon)
                            .font(.title3)
                            .foregroundColor(purchase.color)
                            .frame(width: 36, height: 36)
                            .background(purchase.color.opacity(0.2))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(purchase.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(purchase.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(purchase.amount)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.bottom, 16)
    }
    
    private var partPaymentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active accounts")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                // Get Main Account for Netonnet from DataManager
                if let mainAccount = dataManager.invoiceAccounts.first(where: { account in
                    account.title.lowercased().contains("main account") &&
                    (account.autopaySource.lowercased().contains("netonnet") ||
                     account.autopaySource.lowercased().contains("netonnet"))
                }) {
                    ResursGoldPartPaymentRow(
                        payment: mainAccount.toPartPaymentItem(),
                        showsDisclosure: false
                    )
                } else {
                    // Fallback if not found
                    ResursGoldPartPaymentRow(
                        payment: PartPaymentItem(
                            id: UUID(),
                            title: "Main Account",
                            subtitle: "No invoice until you make a purchase",
                            amount: "0 kr",
                            progress: 0.0,
                            installmentAmount: "",
                            totalAmount: "0 kr",
                            completedPayments: 0,
                            totalPayments: 0,
                            nextDueDate: "",
                            autopaySource: "Netonnet Account"
                        ),
                        showsDisclosure: false
                    )
                }
            }
        }
        .padding(.bottom, 16)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Benefits and services")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 12)
            VStack(spacing: 12) {
                ForEach(benefits, id: \.title) { benefit in
                    HStack(spacing: 16) {
                        Image(systemName: benefit.icon)
                            .font(.title3)
                            .foregroundColor(.green)
                            .frame(width: 36, height: 36)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(benefit.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(benefit.description)
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
        .padding(.bottom, 16)
    }
    
    private var documentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Documents".localized)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 12)
            VStack(spacing: 12) {
                ForEach(Array(documents.enumerated()), id: \.offset) { index, document in
                    Button(action: {
                        // Handle document tap - could navigate to document detail view
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: document.icon)
                                .font(.title3)
                                .foregroundColor(.green)
                                .frame(width: 36, height: 36)
                                .background(Color.green.opacity(0.15))
                                .clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(document.titleKey.localized)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text(document.descKey.localized)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var helpAndSupportSection: some View {
        HelpAndSupportSection()
    }
}

#Preview {
    NavigationStack {
        NetOnNetDetailView()
    }
}

