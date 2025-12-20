import SwiftUI

struct NetOnNetDetailView: View {
    private let availableCredit = "18 300 kr"
    private let creditLimit = "35 000 kr"
    
    struct MerchantPurchase: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let amount: String
        let icon: String
        let color: Color
    }
    
    private let purchases: [MerchantPurchase] = [
        MerchantPurchase(title: "Smart TV 65”", subtitle: "Nov 6, 2025", amount: "12 499 kr", icon: "display.2", color: .blue),
        MerchantPurchase(title: "Soundbar Bundle", subtitle: "Oct 28, 2025", amount: "4 299 kr", icon: "speaker.wave.3.fill", color: .purple),
        MerchantPurchase(title: "Gaming Monitor", subtitle: "Oct 12, 2025", amount: "3 990 kr", icon: "gamecontroller.fill", color: .indigo)
    ]
    
    private let benefits: [(icon: String, title: String, description: String)] = [
        ("shippingbox.fill", "Warehouse Pick-up", "Reserve online, collect your tech within hours at your nearest warehouse."),
        ("sparkles", "Extended Warranty", "Add product protection that mirrors NetOnNet’s in-store offer."),
        ("creditcard.and.123", "Flexible PNPL", "Split large electronics into monthly payments with instant approval.")
    ]
    
    private let partPayments: [PartPaymentItem] = [
        PartPaymentItem(title: "Smart TV Upgrade", subtitle: "2 of 8 payments done", amount: "1 540 kr / 12 320 kr", progress: 0.25),
        PartPaymentItem(title: "Home Office Setup", subtitle: "3 of 6 payments done", amount: "1 250 kr / 7 500 kr", progress: 0.5)
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
        .background(Color.clear)
        .navigationTitle("NetOnNet")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var heroIcon: some View {
        Image(systemName: "shippingbox.fill")
            .font(.system(size: 54))
            .foregroundColor(.blue)
            .padding(28)
            .background(Circle().fill(Color.blue.opacity(0.12)))
            .frame(maxWidth: .infinity)
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Unlock faster tech upgrades")
                .font(.headline)
                .fontWeight(.semibold)
            Text("NetOnNet customers can link their Resurs credit to enjoy instant checkout, delivery tracking and flexible financing for every gadget.")
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
            Text("Recent NetOnNet Purchases")
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
            Text("Open Accounts")
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
                                .fill(Color.blue)
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
            Text("Why connect NetOnNet")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            VStack(spacing: 12) {
                ForEach(benefits, id: \.title) { benefit in
                    HStack(spacing: 16) {
                        Image(systemName: benefit.icon)
                            .font(.title3)
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.15))
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
        NetOnNetDetailView()
    }
}

