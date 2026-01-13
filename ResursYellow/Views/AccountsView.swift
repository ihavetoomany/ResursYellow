//
//  AccountsView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct AccountsView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showAddAccount = false
    @StateObject private var dataManager = DataManager.shared
    
    private var hasAccounts: Bool {
        !dataManager.creditAccounts.isEmpty
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Banking",
                subtitle: hasAccounts ? "Your engagements" : "Get started",
                trailingButton: "plus",
                trailingButtonTint: .blue,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
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
                                    title: "Resurs Gold",
                                    accountType: "Credit Account",
                                    accountNumber: "**** 1234",
                                    balance: "\(dataManager.creditAccounts.first?.availableLabel ?? "0 SEK")",
                                    icon: "heart.fill",
                                    color: .blue,
                                    balanceLabel: "Available credit"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Resurs Gold credit account. Available credit.")
                            .accessibilityHint("Opens detailed view.")
                            
                            Button {
                                navigationPath.append("SavingsAccount")
                            } label: {
                                AccountCard(
                                    title: "Goal Saver",
                                    accountType: "Savings Account",
                                    accountNumber: "**** 5678",
                                    balance: "120 450 SEK",
                                    icon: "banknote.fill",
                                    color: .mint,
                                    balanceLabel: "Savings Balance"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .accessibilityLabel("Goal Saver savings account. 120 450 kronor saved.")
                            .accessibilityHint("Shows savings account activity.")
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
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
                        .padding(.top, 24)
                        .padding(.bottom, 16)
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
                default:
                    EmptyView()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .switchToBanking)) { notification in
                if let destination = notification.userInfo?["destination"] as? String,
                   destination == "ResursFamilyAccountView" {
                    // Ensure we are at root, then navigate to Resurs Gold detail
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
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    Spacer(minLength: 0)
                }
                
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
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
        .background(.ultraThinMaterial)
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
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct SavingsAccountDetailView: View {
    private struct Contribution: Identifiable {
        let id = UUID()
        let title: String
        let date: String
        let amount: String
    }
    
    private let contributions: [Contribution] = [
        .init(title: "Monthly deposit", date: "30 Nov · Automatic", amount: "+1 500 SEK"),
        .init(title: "Rounding transfer", date: "28 Nov · Purchases", amount: "+225 SEK"),
        .init(title: "New sofa purchase", date: "22 Nov · Part Pay", amount: "-4 800 SEK")
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                summaryCard
                progressCard
                recentActivityCard
            }
            .padding(.horizontal)
            .padding(.vertical, 24)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("Goal Saver")
        .navigationBarTitleDisplayMode(.large)
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
                
                Image(systemName: "banknote.fill")
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
        .accessibilityLabel("Goal Saver savings balance. 120 450 kronor saved. Interest rate 3.25 percent. Next deposit 1 500 kronor on 15 December.")
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
    
    private var recentActivityCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent activity")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                ForEach(contributions) { contribution in
                    HStack(alignment: .center) {
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
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

#Preview {
    AccountsView()
        .preferredColorScheme(.dark)
}

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    Text("Choose a product to apply for")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                    
                    CrossSellCard(
                        title: "Get a credit card",
                        subtitle: "Up to 80 000 SEK credit",
                        icon: "creditcard.fill",
                        color: .blue
                    )
                    
                    CrossSellCard(
                        title: "Start saving",
                        subtitle: "Earn up to 3.25% interest",
                        icon: "banknote.fill",
                        color: .mint
                    )
                    
                    CrossSellCard(
                        title: "Apply for a loan",
                        subtitle: "Borrow up to 500 000 SEK",
                        icon: "building.columns.fill",
                        color: .purple
                    )
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
    AddAccountView()
}

