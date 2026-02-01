import SwiftUI

struct JulaDetailView: View {
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var showSettings = false
    @Environment(\.colorScheme) var colorScheme
    
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
    
    private let documents: [(icon: String, titleKey: String, descKey: String)] = [
        ("doc.text.fill", "Credit Agreement", "View your Jula credit account terms and conditions"),
        ("doc.text", "Terms and Conditions", "Read the terms and conditions for Jula"),
        ("hand.raised.fill", "Privacy Policy", "Review how we handle your personal information"),
        ("doc.on.doc.fill", "Payment Plan Agreement", "View your active payment plan agreements")
    ]
    
    private let partPayments: [PartPaymentItem] = [
        PartPaymentItem(id: UUID(), title: "Garden Upgrade", subtitle: "2 of 5 payments done", amount: "720 kr / 3 600 kr", progress: 0.4),
        PartPaymentItem(id: UUID(), title: "Workshop Refresh", subtitle: "1 of 4 payments done", amount: "500 kr / 2 000 kr", progress: 0.25)
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Extended background for navigation bar area
            if colorScheme == .light {
                Color(red: 0.93, green: 0.92, blue: 0.90)
                    .ignoresSafeArea()
            } else {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Scroll offset tracker
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.frame(in: .named("scroll")).minY) { _, newValue in
                                scrollObserver.offset = max(0, -newValue)
                            }
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: 24) {
                summaryCard
                purchasesSection
                partPaymentsSection
                benefitsSection
                documentsSection
                
                // Help and Support Section - HIG: Consistent support access
                HelpAndSupportSection()
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
            }
            .coordinateSpace(name: "scroll")
        }
        .navigationTitle("Jula")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(scrollObserver.offset > 10 ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .shadow(color: scrollObserver.offset > 10 ? .black.opacity(0.1) : .clear, radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSettings) {
            MerchantSettingsView(merchantName: "Jula", merchantColor: .red)
                .presentationBackground {
                    AdaptiveSheetBackground()
                }
        }
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
                
                Image(systemName: "hammer.circle.fill")
                    .font(.title2)
                    .foregroundColor(.red)
                    .frame(width: 56, height: 56)
                    .background(Color.red.opacity(0.2))
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
                    Text("10 800 kr")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background {
            if colorScheme == .light {
                ZStack {
                    Color.white.opacity(0.7)
                    Color.clear.background(.regularMaterial)
                }
            } else {
                Color.clear.background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Jula available credit \(availableCredit). Credit limit \(creditLimit). Used credit 10 800 kronor.")
    }
    
    private var purchasesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Jula Purchases")
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
                    .background {
                        if colorScheme == .light {
                            ZStack {
                                Color.white.opacity(0.7)
                                Color.clear.background(.regularMaterial)
                            }
                        } else {
                            Color.clear.background(.regularMaterial)
                        }
                    }
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
                    .background {
                        if colorScheme == .light {
                            ZStack {
                                Color.white.opacity(0.7)
                                Color.clear.background(.regularMaterial)
                            }
                        } else {
                            Color.clear.background(.regularMaterial)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .padding(.bottom, 16)
    }
    
    private var benefitsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Why connect Jula")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 12)
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
                    .background {
                        if colorScheme == .light {
                            ZStack {
                                Color.white.opacity(0.7)
                                Color.clear.background(.regularMaterial)
                            }
                        } else {
                            Color.clear.background(.regularMaterial)
                        }
                    }
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
                                .foregroundColor(.red)
                                .frame(width: 36, height: 36)
                                .background(Color.red.opacity(0.15))
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
                        .background {
                            if colorScheme == .light {
                                ZStack {
                                    Color.white.opacity(0.7)
                                    Color.clear.background(.regularMaterial)
                                }
                            } else {
                                Color.clear.background(.regularMaterial)
                            }
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        JulaDetailView()
    }
}

