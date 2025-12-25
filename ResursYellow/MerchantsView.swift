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
    
    @State private var connected: [String] = ["Bauhaus", "Netonnet"]

    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Merchants",
                subtitle: "Connect stores you shop at",
                trailingButton: "plus",
                trailingButtonTint: .blue,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showAddMerchant = true
                }
            ) {
                VStack(spacing: 16) {
                    // Connected section
                    VStack(alignment: .leading, spacing: 12) {
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
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
            }
            .sheet(isPresented: $showAddMerchant) {
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

struct AddMerchantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var merchantName: String = ""
    @State private var category: String = "Retail"
    @State private var notes: String = ""

    private let categories = ["Retail", "Electronics", "Home Improvement", "Groceries", "Online", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Merchant Details")) {
                    TextField("Merchant name", text: $merchantName)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    TextField("Notes (optional)", text: $notes)
                }

                Section(footer: Text("You can manage connected merchants from the Merchants list.")) {
                    Button {
                        // TODO: Persist new merchant and update list
                        dismiss()
                    } label: {
                        Text("Add Merchant")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(merchantName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Add Merchant")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddMerchantView()
}

