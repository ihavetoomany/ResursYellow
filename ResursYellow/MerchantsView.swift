import SwiftUI

// Styled like AccountCard from AccountsView
struct MerchantCard: View {
    let title: String
    let subtitle: String?
    let amount: String?
    let icon: String
    let color: Color
    var titleColor: Color = .primary
    var iconFont: Font = .title

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(iconFont)
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
    @State private var showAddMerchant = false
    @StateObject private var dataManager = DataManager.shared
    
    @State private var connected: [String] = ["Bauhaus", "Netonnet"]
    
    private var hasMerchants: Bool {
        !dataManager.creditAccounts.isEmpty // Use credit accounts as proxy for having products
    }
    
    private var connectedMerchants: [String] {
        hasMerchants ? connected : []
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Merchants",
                subtitle: hasMerchants ? "Connect stores you shop at" : "Get started",
                trailingButton: "plus",
                trailingButtonTint: .blue,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showAddMerchant = true
                }
            ) {
                VStack(spacing: 16) {
                    if connectedMerchants.isEmpty {
                        // Empty state
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 40)
                            
                            Image(systemName: "storefront")
                                .font(.system(size: 56))
                                .foregroundColor(.secondary.opacity(0.4))
                            
                            Text("No merchants connected")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            Text("Connect your favorite stores to access payment options and exclusive offers.")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button {
                                showAddMerchant = true
                            } label: {
                                Text("Explore")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 10)
                                    .background(Color.secondary.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 4)
                            
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                    } else {
                        // Connected section
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(spacing: 10) {
                                ForEach(connectedMerchants, id: \.self) { merchant in
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
                                            titleColor: card.titleColor,
                                            iconFont: card.iconFont
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
            .fullScreenCover(isPresented: $showAddMerchant) {
                AddMerchantView()
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
        let iconFont: Font
    }
    
    func cardConfig(for merchant: String) -> MerchantCardConfig {
        switch merchant {
        case "Bauhaus":
            return MerchantCardConfig(
                subtitle: "Store Credit and Invoice available",
                amount: "Available credit: 14 500 kr",
                icon: "hammer.fill",
                color: .red,
                titleColor: .primary,
                iconFont: .title2
            )
        case "Netonnet":
            return MerchantCardConfig(
                subtitle: "Store Credit available",
                amount: "Available credit: 20 000 kr",
                icon: "shippingbox.fill",
                color: .green,
                titleColor: .primary,
                iconFont: .title
            )
        case "Jula":
            return MerchantCardConfig(
                subtitle: "Pay later active in-store",
                amount: "Available credit: 9 200 kr",
                icon: "hammer.circle.fill",
                color: .red,
                titleColor: .primary,
                iconFont: .title
            )
        default:
            return MerchantCardConfig(
                subtitle: "Payment options and offers enabled",
                amount: nil,
                icon: "link.circle.fill",
                color: .green,
                titleColor: .primary,
                iconFont: .title
            )
        }
    }
    
    @ViewBuilder
    func merchantDetailView(for merchant: String) -> some View {
        switch merchant {
        case "Bauhaus":
            BauhausDetailView()
        case "Netonnet":
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

struct MerchantOption: Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let color: Color
}

struct AddMerchantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    
    private let merchants: [MerchantOption] = [
        MerchantOption(name: "Bauhaus", category: "Home Improvement", icon: "hammer.fill", color: .red),
        MerchantOption(name: "NetOnNet", category: "Electronics", icon: "shippingbox.fill", color: .green),
        MerchantOption(name: "Elgiganten", category: "Electronics", icon: "desktopcomputer", color: .blue),
        MerchantOption(name: "MediaMarkt", category: "Electronics", icon: "tv.fill", color: .red),
        MerchantOption(name: "Jula", category: "Home Improvement", icon: "wrench.and.screwdriver.fill", color: .orange),
        MerchantOption(name: "Clas Ohlson", category: "Home & Living", icon: "lightbulb.fill", color: .blue),
        MerchantOption(name: "IKEA", category: "Furniture", icon: "bed.double.fill", color: .yellow),
        MerchantOption(name: "Stadium", category: "Sports", icon: "figure.run", color: .green),
        MerchantOption(name: "XXL", category: "Sports", icon: "sportscourt.fill", color: .orange),
        MerchantOption(name: "Intersport", category: "Sports", icon: "basketball.fill", color: .red),
        MerchantOption(name: "Kjell & Company", category: "Electronics", icon: "cable.connector", color: .green),
        MerchantOption(name: "Webhallen", category: "Electronics", icon: "gamecontroller.fill", color: .purple),
        MerchantOption(name: "Cervera", category: "Home & Living", icon: "cup.and.saucer.fill", color: .pink),
        MerchantOption(name: "Åhléns", category: "Department Store", icon: "bag.fill", color: .purple),
        MerchantOption(name: "Lagerhaus", category: "Home & Living", icon: "house.fill", color: .mint),
        MerchantOption(name: "Granit", category: "Home & Living", icon: "square.grid.2x2.fill", color: .gray),
        MerchantOption(name: "Biltema", category: "Auto & Home", icon: "car.fill", color: .blue),
        MerchantOption(name: "Rusta", category: "Home & Garden", icon: "leaf.fill", color: .green),
        MerchantOption(name: "ÖoB", category: "Discount", icon: "tag.fill", color: .red),
        MerchantOption(name: "Dollarstore", category: "Discount", icon: "dollarsign.circle.fill", color: .green)
    ]
    
    private var filteredMerchants: [MerchantOption] {
        if searchText.isEmpty {
            return merchants
        }
        return merchants.filter { merchant in
            merchant.name.localizedCaseInsensitiveContains(searchText) ||
            merchant.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    // Search bar
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search merchants", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 8)
                    
                    if filteredMerchants.isEmpty {
                        VStack(spacing: 12) {
                            Spacer().frame(height: 40)
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary.opacity(0.4))
                            Text("No merchants found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Try a different search term")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 20)
                    } else {
                        ForEach(filteredMerchants) { merchant in
                            Button {
                                // TODO: Connect merchant
                                dismiss()
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: merchant.icon)
                                        .font(.title3)
                                        .foregroundColor(merchant.color)
                                        .frame(width: 40, height: 40)
                                        .background(merchant.color.opacity(0.15))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(merchant.name)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                        Text(merchant.category)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                .padding(12)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Add Merchant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundColor(.gray)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    AddMerchantView()
}

