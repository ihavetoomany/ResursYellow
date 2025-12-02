//
//  AccountsView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct AccountsView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Accounts",
                subtitle: "Your engagements",
                trailingButton: "person.fill",
                trailingButtonTint: .black,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showProfile = true
                }
            ) {
                VStack(spacing: 16) {
                    // Account Cards
                    VStack(spacing: 16) {
                        // My Accounts Section Header
                        HStack {
                            Text("My Accounts")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.secondary)
                                .textCase(.uppercase)
                                .tracking(0.5)
                            Spacer()
                        }
                        .padding(.horizontal, 4)

                        // My Accounts Items
                        Button {
                            navigationPath.append("ResursFamily")
                        } label: {
                            AccountCard(
                                title: "Resurs Family",
                                accountType: "Joint Credit Account",
                                accountNumber: "**** 1234",
                                balance: "56 005 SEK",
                                icon: "heart.fill",
                                color: .blue,
                                balanceLabel: "Available Balance"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())

                        // Discover Section Header
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

                        // Discover Items
                        Button(action: {
                            // TODO: Navigate to loan info/calculator/apply flow
                        }) {
                            CompactDiscoverRow(
                                title: "Apply for a Loan",
                                subtitle: "Read more, calculate and apply",
                                icon: "car.fill",
                                color: .blue,
                                trailingIcon: "plus"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        Button(action: {
                            // TODO: Navigate to savings goal creation flow
                        }) {
                            CompactDiscoverRow(
                                title: "Start Saving for a Goal",
                                subtitle: "Open an account in 2 min",
                                icon: "piggy.bank.fill",
                                color: .green,
                                trailingIcon: "plus"
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { value in
                if value == "ResursFamily" {
                    ResursFamilyAccountView()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                // If not at root level, pop to root
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
                // If at root, the StickyHeaderView will handle scrolling to top
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
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
        VStack(alignment: .leading, spacing: 10) {
            // Icon with account type
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                if let accountType = accountType {
                    Text(accountType)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Title
            Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
            
            Spacer()
                .frame(height: 2)
            
            // Available amount at bottom
            VStack(alignment: .leading, spacing: 3) {
                Text(balanceLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(balance)
                    .font(.system(size: 22, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

struct CompactDiscoverRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var trailingIcon: String? = nil

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.2))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if let trailingIcon {
                Image(systemName: trailingIcon)
                    .foregroundColor(.blue)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    AccountsView()
        .preferredColorScheme(.dark)
}

