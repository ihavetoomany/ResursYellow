import SwiftUI

// Custom Bauhaus icon view matching the favicon design
struct BauhausIconView: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // Main square background (red)
            RoundedRectangle(cornerRadius: 3)
                .fill(color)
            
            // Three overlapping house shapes with shadows
            GeometryReader { geometry in
                let size = geometry.size
                let shadowOffset: CGFloat = 1.5
                
                // Top-left house (largest)
                ZStack {
                    // Shadow
                    Path { path in
                        let baseWidth: CGFloat = size.width * 0.5
                        let baseHeight: CGFloat = size.height * 0.35
                        let roofHeight: CGFloat = size.height * 0.25
                        let x: CGFloat = size.width * 0.05
                        let y: CGFloat = size.height * 0.15
                        
                        // Base rectangle
                        path.move(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + baseHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + baseHeight + shadowOffset))
                        path.closeSubpath()
                        
                        // Roof triangle
                        path.move(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth / 2 + shadowOffset, y: y + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.closeSubpath()
                    }
                    .fill(Color.black)
                    
                    // White house
                    Path { path in
                        let baseWidth: CGFloat = size.width * 0.5
                        let baseHeight: CGFloat = size.height * 0.35
                        let roofHeight: CGFloat = size.height * 0.25
                        let x: CGFloat = size.width * 0.05
                        let y: CGFloat = size.height * 0.15
                        
                        // Base rectangle
                        path.move(to: CGPoint(x: x, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight + baseHeight))
                        path.addLine(to: CGPoint(x: x, y: y + roofHeight + baseHeight))
                        path.closeSubpath()
                        
                        // Roof triangle
                        path.move(to: CGPoint(x: x, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth / 2, y: y))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight))
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                }
                
                // Middle-right house (medium)
                ZStack {
                    // Shadow
                    Path { path in
                        let baseWidth: CGFloat = size.width * 0.42
                        let baseHeight: CGFloat = size.height * 0.3
                        let roofHeight: CGFloat = size.height * 0.2
                        let x: CGFloat = size.width * 0.35
                        let y: CGFloat = size.height * 0.25
                        
                        // Base rectangle
                        path.move(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + baseHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + baseHeight + shadowOffset))
                        path.closeSubpath()
                        
                        // Roof triangle
                        path.move(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth / 2 + shadowOffset, y: y + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.closeSubpath()
                    }
                    .fill(Color.black)
                    
                    // White house
                    Path { path in
                        let baseWidth: CGFloat = size.width * 0.42
                        let baseHeight: CGFloat = size.height * 0.3
                        let roofHeight: CGFloat = size.height * 0.2
                        let x: CGFloat = size.width * 0.35
                        let y: CGFloat = size.height * 0.25
                        
                        // Base rectangle
                        path.move(to: CGPoint(x: x, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight + baseHeight))
                        path.addLine(to: CGPoint(x: x, y: y + roofHeight + baseHeight))
                        path.closeSubpath()
                        
                        // Roof triangle
                        path.move(to: CGPoint(x: x, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth / 2, y: y))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight))
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                }
                
                // Bottom-right house (smallest)
                ZStack {
                    // Shadow
                    Path { path in
                        let baseWidth: CGFloat = size.width * 0.35
                        let baseHeight: CGFloat = size.height * 0.25
                        let roofHeight: CGFloat = size.height * 0.18
                        let x: CGFloat = size.width * 0.55
                        let y: CGFloat = size.height * 0.45
                        
                        // Base rectangle
                        path.move(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + baseHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + baseHeight + shadowOffset))
                        path.closeSubpath()
                        
                        // Roof triangle
                        path.move(to: CGPoint(x: x + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth / 2 + shadowOffset, y: y + shadowOffset))
                        path.addLine(to: CGPoint(x: x + baseWidth + shadowOffset, y: y + roofHeight + shadowOffset))
                        path.closeSubpath()
                    }
                    .fill(Color.black)
                    
                    // White house
                    Path { path in
                        let baseWidth: CGFloat = size.width * 0.35
                        let baseHeight: CGFloat = size.height * 0.25
                        let roofHeight: CGFloat = size.height * 0.18
                        let x: CGFloat = size.width * 0.55
                        let y: CGFloat = size.height * 0.45
                        
                        // Base rectangle
                        path.move(to: CGPoint(x: x, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight + baseHeight))
                        path.addLine(to: CGPoint(x: x, y: y + roofHeight + baseHeight))
                        path.closeSubpath()
                        
                        // Roof triangle
                        path.move(to: CGPoint(x: x, y: y + roofHeight))
                        path.addLine(to: CGPoint(x: x + baseWidth / 2, y: y))
                        path.addLine(to: CGPoint(x: x + baseWidth, y: y + roofHeight))
                        path.closeSubpath()
                    }
                    .fill(Color.white)
                }
            }
        }
        .frame(width: 24, height: 24)
    }
}

// Custom Netonnet icon view matching the favicon design
struct NetonnetIconView: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // White background with rounded corners
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.white)
            
            // "netonnet" wordmark
            HStack(spacing: 2) {
                // First "net" in blue
                Text("net")
                    .font(.system(size: 7, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                
                // "on" in white inside red circle
                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 10, height: 10)
                    Text("on")
                        .font(.system(size: 5, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Second "net" in blue
                Text("net")
                    .font(.system(size: 7, weight: .semibold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
            }
        }
        .frame(width: 24, height: 24)
    }
}

// Styled like AccountCard from AccountsView
struct MerchantCard: View {
    let title: String
    let subtitle: String?
    let amount: String?
    let icon: String
    let color: Color
    var titleColor: Color = .primary
    var useCustomIcon: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Icon + merchant name on one row
            HStack(alignment: .center, spacing: 10) {
                Group {
                    if useCustomIcon {
                        if title == "Bauhaus" {
                            BauhausIconView(color: color)
                        } else if title == "Netonnet" {
                            NetonnetIconView(color: color)
                        } else {
                            Image(systemName: icon)
                                .font(.title3.weight(.semibold))
                                .foregroundColor(color)
                        }
                    } else {
                        Image(systemName: icon)
                            .font(.title3.weight(.semibold))
                            .foregroundColor(color)
                    }
                }
                .frame(width: 40, height: 40)
                .background(
                    useCustomIcon && title == "Bauhaus" ? color :
                    useCustomIcon && title == "Netonnet" ? Color.white :
                    color.opacity(0.18)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                Spacer(minLength: 0)
            }
            
            Spacer()
                .frame(height: 2)
            
            // Available credit at bottom
            if let amount {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Available credit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(amount.replacingOccurrences(of: "Available credit: ", with: ""))
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
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
                                            useCustomIcon: merchant == "Bauhaus" || merchant == "Netonnet"
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
    }
    
    func cardConfig(for merchant: String) -> MerchantCardConfig {
        switch merchant {
        case "Bauhaus":
            return MerchantCardConfig(
                subtitle: "Store Credit and Invoice available",
                amount: "14 500 kr",
                icon: "hammer.fill",
                color: .red,
                titleColor: .primary
            )
        case "Netonnet":
            return MerchantCardConfig(
                subtitle: "Store Credit available",
                amount: "20 000 kr",
                icon: "shippingbox.fill",
                color: .green,
                titleColor: .primary
            )
        case "Jula":
            return MerchantCardConfig(
                subtitle: "Pay later active in-store",
                amount: "9 200 kr",
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

