import SwiftUI

// Styled like AccountCard from AccountsView
struct MerchantCard: View {
    let title: String
    let subtitle: String?
    let amount: String?
    let icon: String
    let color: Color
    var titleColor: Color = .primary

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(titleColor)
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                if let amount {
                    Text(amount)
                        .font(.footnote)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }

            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct MerchantsView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    @State private var connected: [String] = ["Bauhaus", "NetOnNet", "Jula"]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Merchants",
                subtitle: "Connect stores you shop at",
                trailingButton: "person.fill",
                trailingButtonTint: .black,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showProfile = true
                }
            ) {
                VStack(spacing: 16) {
                    // Connected section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Connected")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        VStack(spacing: 10) {
                            ForEach(connected, id: \.self) { merchant in
                                let card = cardConfig(for: merchant)
                                
                                NavigationLink {
                                    merchantDetailView(for: merchant)
                                } label: {
                                    MerchantCard(
                                        title: merchant,
                                        subtitle: card.subtitle,
                                        amount: card.amount,
                                        icon: card.icon,
                                        color: card.color,
                                        titleColor: card.titleColor
                                    )
                                }
                                .buttonStyle(.plain)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        remove(merchant)
                                    } label: {
                                        Label("Remove", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 24)
                    
                    // Discover section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Discover")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        
                        Button {
                            // TODO: Add merchant action
                        } label: {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.8))
                                        .frame(width: 36, height: 36)
                                    Image(systemName: "plus")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Add Merchant")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    Text("Look for stores you shop at, enable quick checkout, part payment options and offers")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
        }
    }

    private func remove(_ merchant: String) {
        if let idx = connected.firstIndex(of: merchant) {
            connected.remove(at: idx)
        }
    }
}

private extension MerchantsView {
    struct MerchantCardConfig {
        let subtitle: String
        let amount: String?
        let icon: String
        let color: Color
        let titleColor: Color
    }
    
    func cardConfig(for merchant: String) -> MerchantCardConfig {
        switch merchant {
        case "Bauhaus":
            return MerchantCardConfig(
                subtitle: "Easy checkout enabled",
                amount: "Available amount: 14 500 kr",
                icon: "house.lodge.fill",
                color: .orange,
                titleColor: .primary
            )
        case "NetOnNet":
            return MerchantCardConfig(
                subtitle: "Linked to NetOnNet Warehouse",
                amount: "Available amount: 18 300 kr",
                icon: "shippingbox.fill",
                color: .blue,
                titleColor: .primary
            )
        case "Jula":
            return MerchantCardConfig(
                subtitle: "Pay later active in-store",
                amount: "Available amount: 9 200 kr",
                icon: "hammer.circle.fill",
                color: .red,
                titleColor: .primary
            )
        default:
            return MerchantCardConfig(
                subtitle: "Payment options and offers enabled",
                amount: nil,
                icon: "link.circle.fill",
                color: .green,
                titleColor: .primary
            )
        }
    }
    
    @ViewBuilder
    func merchantDetailView(for merchant: String) -> some View {
        switch merchant {
        case "Bauhaus":
            BauhausDetailView()
        case "NetOnNet":
            NetOnNetDetailView()
        case "Jula":
            JulaDetailView()
        default:
            Text("Details for \(merchant)")
                .padding()
        }
    }
}

#Preview {
    MerchantsView()
        .preferredColorScheme(.dark)
}

