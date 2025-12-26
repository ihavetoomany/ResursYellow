import SwiftUI

struct NetOnNetDetailView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
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
                        infoCard
                            .padding(.top, 20)
                        purchasesSection
                        partPaymentsSection
                        benefitsSection
                    }
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
                        Text("Netonnet")
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
                        Text("Store Credit available")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(1.0 - scrollProgress * 2)
                        
                        // Title
                        Text("Netonnet")
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
    
    private var heroIcon: some View {
        Image(systemName: "shippingbox.fill")
            .font(.system(size: 54))
            .foregroundColor(.green)
            .padding(28)
            .background(Circle().fill(Color.green.opacity(0.12)))
            .frame(maxWidth: .infinity)
    }
    
    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            Text("Purchases")
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
        .padding(.horizontal)
    }
    
    private var benefitsSection: some View {
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
        .padding(.horizontal)
        .padding(.bottom, 32)
    }
}

#Preview {
    NavigationStack {
        NetOnNetDetailView()
    }
}

