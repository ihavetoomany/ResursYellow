import SwiftUI

struct JulaDetailView: View {
    private let availableCredit = "9 200 kr"
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
        MerchantPurchase(title: "Workshop Tool Kit", subtitle: "Nov 4, 2025", amount: "1 999 kr", icon: "wrench.adjustable.fill", color: .red),
        MerchantPurchase(title: "Outdoor Heater", subtitle: "Oct 22, 2025", amount: "3 499 kr", icon: "flame.fill", color: .orange),
        MerchantPurchase(title: "Bike Stand", subtitle: "Oct 9, 2025", amount: "699 kr", icon: "bicycle.circle.fill", color: .pink)
    ]
    
    private let benefits: [(icon: String, title: String, description: String)] = [
        ("hammer.fill", "DIY Financing", "Split larger renovation purchases into monthly payments with no surprises."),
        ("leaf.fill", "Seasonal Campaigns", "Automatic access to Julas rotating outdoor and garden offers."),
        ("tray.and.arrow.down.fill", "Service Booking", "Book assembly and service through the same connected account.")
    ]
    
    private let partPayments: [PartPaymentItem] = [
        PartPaymentItem(id: UUID(), title: "Garden Upgrade", subtitle: "2 of 5 payments done", amount: "720 kr / 3 600 kr", progress: 0.4),
        PartPaymentItem(id: UUID(), title: "Workshop Refresh", subtitle: "1 of 4 payments done", amount: "500 kr / 2 000 kr", progress: 0.25)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroIcon
                infoCard
                purchasesSection
                partPaymentsSection
                benefitsSection
            }
            .padding(.top, 16)
        }
        .navigationTitle("Jula")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var heroIcon: some View {
        Image(systemName: "hammer.circle.fill")
            .font(.system(size: 54))
            .foregroundColor(.red)
            .padding(28)
            .background(Circle().fill(Color.red.opacity(0.15)))
            .frame(maxWidth: .infinity)
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Keep every project moving")
                .font(.headline)
                .fontWeight(.semibold)
            Text("Connect Jula to track purchases, manage seasonal offers and unlock pay-later options that fit your renovation timeline.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
            
            HStack(spacing: 32) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Available Credit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(availableCredit)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                VStack(alignment: .leading, spacing: 4) {
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
    }
    
    private var purchasesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Jula Purchases")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
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
        .padding(.horizontal)
    }
    
    private var partPaymentsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Invoice accounts")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            VStack(spacing: 12) {
                ForEach(partPayments, id: \.title) { plan in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(plan.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text(plan.subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(plan.amount)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        GeometryReader { geo in
                            Capsule()
                                .fill(Color.red)
                                .frame(width: geo.size.width * CGFloat(plan.progress), height: 8)
                                .animation(.easeInOut, value: plan.progress)
                        }
                        .frame(height: 8)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why connect Jula")
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
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}

#Preview {
    NavigationStack {
        JulaDetailView()
    }
}

