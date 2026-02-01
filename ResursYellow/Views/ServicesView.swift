//
//  ServicesView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI
import SafariServices

struct ServicesView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showAddAccount = false
    @StateObject private var dataManager = DataManager.shared
    
    private var hasAccounts: Bool {
        !dataManager.creditAccounts.isEmpty
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                // Light grey background for better card contrast (light mode)
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                // Animated blobs as background - cool blue/teal scheme for services
                AnimatedBlobBackground(isOverdue: false) // Use cool colors
                    .frame(height: 300)
                    .offset(y: -20)
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                
                StickyHeaderView(
                    title: "Services",
                    subtitle: hasAccounts ? "Your banking solutions" : "Get started",
                    trailingButton: "plus",
                    trailingButtonTint: .primary,
                    trailingButtonSize: 44,
                    trailingButtonIconScale: 0.5,
                    trailingButtonAction: {
                        showAddAccount = true
                    }
                ) {
                VStack(spacing: 16) {
                    if hasAccounts {
                        // Account Cards
                        VStack(spacing: 16) {
                            // My Accounts Items
                            Button {
                                navigationPath.append("ResursFamily")
                            } label: {
                                AccountCard(
                                    title: "Resurs Family",
                                    accountType: "Resurs Family",
                                    accountNumber: "**** 1234",
                                    balance: "\(dataManager.creditAccounts.first?.availableLabel ?? "0 SEK")",
                                    icon: "heart.fill",
                                    color: .blue,
                                    balanceLabel: "Available credit",
                                    hideTitle: true
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Resurs Family credit account. Available credit.")
                            .accessibilityHint("Opens detailed view.")
                            
                            Button {
                                navigationPath.append("SavingsAccount")
                            } label: {
                                AccountCard(
                                    title: "Senior Savings",
                                    accountType: "Senior Savings",
                                    accountNumber: "**** 5678",
                                    balance: "120 450 SEK",
                                    icon: "star.fill",
                                    color: .mint,
                                    balanceLabel: "Savings Balance",
                                    hideTitle: true
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Senior Savings savings account. 120 450 kronor saved.")
                            .accessibilityHint("Shows savings account activity.")
                            
                            Button {
                                navigationPath.append("HouseRenovationLoan")
                            } label: {
                                AccountCard(
                                    title: "House Renovation",
                                    accountType: "House Renovation",
                                    accountNumber: "**** 9012",
                                    balance: "255 000 SEK",
                                    icon: "house.fill",
                                    color: .orange,
                                    balanceLabel: "Remaining Balance",
                                    hideTitle: true
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("House Renovation loan. 255 000 kronor remaining balance.")
                            .accessibilityHint("Opens loan details and payment schedule.")
                        }
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    } else {
                        // Empty state
                        VStack(spacing: 20) {
                            Spacer()
                                .frame(height: 40)
                            
                            Image(systemName: "building.columns")
                                .font(.system(size: 56))
                                .foregroundColor(.secondary.opacity(0.4))
                            
                            Text("No products yet")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            Text("Apply for a credit card, savings account, or loan to get started.")
                                .font(.subheadline)
                                .foregroundColor(.secondary.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                            
                            Button {
                                showAddAccount = true
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
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    }
                }
            }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { value in
                switch value {
                case "ResursFamily":
                    ResursFamilyAccountView()
                case "SavingsAccount":
                    SavingsAccountDetailView()
                case "HouseRenovationLoan":
                    HouseRenovationLoanView()
                default:
                    EmptyView()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .switchToServices)) { notification in
                if let destination = notification.userInfo?["destination"] as? String,
                   destination == "ResursFamilyAccountView" {
                    // Ensure we are at root, then navigate to Resurs Family detail
                    if !navigationPath.isEmpty {
                        navigationPath.removeLast(navigationPath.count)
                    }
                    navigationPath.append("ResursFamily")
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                // If not at root level, pop to root
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
                // If at root, the StickyHeaderView will handle scrolling to top
            }
            .sheet(isPresented: $showAddAccount) {
                AddAccountView()
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground {
                        AdaptiveSheetBackground()
                    }
            }
        }
    }
}

struct AccountCard: View {
    let title: String
    let accountType: String?
    let accountNumber: String
    let balance: String
    let icon: String
    let color: Color
    let balanceLabel: String
    var hideTitle: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Keep hierarchy icon + account type on one row per HIG Typography
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundColor(color)
                        .frame(width: 40, height: 40)
                        .background(color.opacity(0.18))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    if let accountType {
                        Text(accountType)
                            .font(.title2.weight(.semibold))
                            .foregroundColor(.primary)
                    }
                    Spacer(minLength: 0)
                }
                
                if !hideTitle {
                    Text(title)
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
                .frame(height: 2)
            
            // Available amount at bottom
            VStack(alignment: .leading, spacing: 3) {
                Text(balanceLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(balance)
                    .font(.system(size: 20, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CrossSellCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundColor(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.18))
                .clipShape(RoundedRectangle(cornerRadius: 14))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground).opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SavingsAccountDetailView: View {
    @State private var showAISupport = false
    @State private var showSettings = false
    
    private struct Contribution: Identifiable {
        let id = UUID()
        let title: String
        let date: String
        let amount: String
        let icon: String
        let color: Color
    }
    
    private let contributions: [Contribution] = [
        .init(title: "Monthly deposit", date: "30 Nov · Automatic", amount: "+1 500 SEK", icon: "calendar.badge.clock", color: .mint),
        .init(title: "Rounding transfer", date: "28 Nov · Purchases", amount: "+225 SEK", icon: "arrow.up.arrow.down", color: .blue),
        .init(title: "Withdrawal", date: "22 Nov · Part Pay", amount: "-4 800 SEK", icon: "sofa.fill", color: .purple)
    ]
    
    // Benefits for Senior Savings
    private let benefits: [(icon: String, title: String, desc: String)] = [
        ("percent", "Competitive Interest Rate", "Earn 3.25% annual interest on your savings."),
        ("arrow.up.circle.fill", "Automatic Deposits", "Set up recurring monthly deposits to grow your savings."),
        ("chart.line.uptrend.xyaxis", "Goal Tracking", "Track your progress toward your savings goals."),
        ("shield.checkerboard", "Secure Savings", "Your savings are protected and secure.")
    ]
    
    // Documents for Senior Savings
    private let documents: [(icon: String, titleKey: String, descKey: String)] = [
        ("doc.text.fill", "Savings Agreement", "View your savings account terms and conditions"),
        ("doc.text", "Terms and Conditions", "Read the terms and conditions for Senior Savings"),
        ("hand.raised.fill", "Privacy Policy", "Review how we handle your personal information"),
        ("doc.on.doc.fill", "Interest Rate Information", "View current interest rates and calculations")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                summaryCard
                accountsSection
                recentActivitySection
                benefitsSection
                documentsSection
                helpAndSupportSection
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Senior Savings")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 16) {
                    Button(action: { showSettings = true }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                    
                    Button(action: { showAISupport = true }) {
                        Image(systemName: "questionmark.message.fill")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .sheet(isPresented: $showAISupport) {
            AISupportChatView()
                .presentationBackground {
                    AdaptiveSheetBackground()
                }
        }
        .sheet(isPresented: $showSettings) {
            ServiceSettingsView(serviceName: "Senior Savings", serviceColor: .mint)
                .presentationBackground {
                    AdaptiveSheetBackground()
                }
        }
    }
    
    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Savings Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("120 450 SEK")
                        .font(.system(size: 34, weight: .bold))
                        .minimumScaleFactor(0.8)
                }
                
                Spacer()
                
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundColor(.mint)
                    .frame(width: 56, height: 56)
                    .background(Color.mint.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
            
            Divider()
                .background(Color.primary.opacity(0.1))
            
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Interest rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("3.25%")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Next deposit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("15 Dec · 1 500 SEK")
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
        .accessibilityLabel("Senior Savings savings balance. 120 450 kronor saved. Interest rate 3.25 percent. Next deposit 1 500 kronor on 15 December.")
    }
    
    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Goal progress")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 8) {
                ProgressView(value: 0.8)
                    .tint(.mint)
                HStack {
                    Text("120 450 SEK saved")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("Goal 150 000 SEK")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            
            Text("Keep contributing 1 500 SEK per month to reach your sofa fund by February.")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    private var accountsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Accounts")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    // Handle "View all" tap
                }) {
                    Text("View all")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                SavingsAccountRow(
                    title: "Emergency Fund",
                    subtitle: "Savings account · •••• 5678",
                    amount: "45 230 SEK",
                    progress: 0.6,
                    monthlyAmount: "1 500 SEK monthly",
                    nextDueDate: "15 Jan"
                )
                
                SavingsAccountRow(
                    title: "Grandchildren Gift",
                    subtitle: "Savings account · •••• 9012",
                    amount: "75 220 SEK",
                    progress: 0.75,
                    monthlyAmount: "2 000 SEK monthly",
                    nextDueDate: "20 Jan"
                )
            }
        }
        .padding(.bottom, 16)
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent activity")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    // Handle "View all" tap
                }) {
                    Text("View all")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 12)
            
            VStack(spacing: 12) {
                ForEach(contributions) { contribution in
                    HStack(spacing: 16) {
                        Image(systemName: contribution.icon)
                            .font(.title3)
                            .foregroundColor(contribution.color)
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(contribution.color.opacity(0.2))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(contribution.title)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Text(contribution.date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text(contribution.amount)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(contribution.amount.contains("-") ? .red : .green)
                    }
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
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
                            .foregroundColor(.blue)
                            .frame(width: 36, height: 36)
                            .background(Color.blue.opacity(0.15))
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
                                .foregroundColor(.blue)
                                .frame(width: 36, height: 36)
                                .background(Color.blue.opacity(0.15))
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

struct SavingsAccountRow: View {
    let title: String
    let subtitle: String
    let amount: String
    let progress: Double
    let monthlyAmount: String
    let nextDueDate: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            
            Text(amount)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ProgressView(value: progress)
                .tint(.mint)
            
            HStack {
                Text(monthlyAmount)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(nextDueDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ServicesView()
        .preferredColorScheme(.dark)
}

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showSavingsWebView = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Text("Choose a product to apply for")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    
                    Button {
                        // Handle credit card tap
                    } label: {
                        CrossSellCard(
                            title: "Get a credit card",
                            subtitle: "Up to 80 000 SEK credit",
                            icon: "creditcard.fill",
                            color: .blue
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        showSavingsWebView = true
                    } label: {
                        CrossSellCard(
                            title: "Start saving",
                            subtitle: "Earn up to 3.25% interest",
                            icon: "banknote.fill",
                            color: .mint
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        // Handle loan tap
                    } label: {
                        CrossSellCard(
                            title: "Apply for a loan",
                            subtitle: "Borrow up to 500 000 SEK",
                            icon: "building.columns.fill",
                            color: .purple
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Add Product")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                    }
                    .tint(.primary)
                }
            }
            .fullScreenCover(isPresented: $showSavingsWebView) {
                if let url = URL(string: "https://deposit.resursbank.se/choose-account-type") {
                    SafariView(url: url)
                        .ignoresSafeArea()
                }
            }
        }
    }
}

#Preview {
    AddAccountView()
}

// MARK: - Safari View Wrapper
/// A SwiftUI wrapper for SFSafariViewController, following HIG for web content presentation.
/// This provides a native iOS browsing experience with toolbar, sharing, and reader mode.
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        let configuration = SFSafariViewController.Configuration()
        configuration.entersReaderIfAvailable = false // Keep original site experience
        configuration.barCollapsingEnabled = true // Allow toolbar to collapse on scroll per HIG
        
        let safariVC = SFSafariViewController(url: url, configuration: configuration)
        safariVC.preferredControlTintColor = .systemBlue // Native iOS blue for controls
        safariVC.dismissButtonStyle = .done // HIG-compliant dismiss button
        
        return safariVC
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // No update needed
    }
}

