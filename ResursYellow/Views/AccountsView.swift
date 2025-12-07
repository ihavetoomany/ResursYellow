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
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Accounts",
                subtitle: "Your engagements",
                trailingButton: "plus",
                trailingButtonTint: .black,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showAddAccount = true
                }
            ) {
                VStack(spacing: 16) {
                    // Account Cards
                    VStack(spacing: 16) {
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
            .sheet(isPresented: $showAddAccount) {
                AddAccountView()
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
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .center, spacing: 10) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                        .frame(width: 44, height: 44)
                        .background(color.opacity(0.2))
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
                    .font(.title)
                    .fontWeight(.semibold)
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
                    .font(.system(size: 22, weight: .bold))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    AccountsView()
        .preferredColorScheme(.dark)
}

struct AddAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var accountName: String = ""
    @State private var accountType: String = "Credit"
    @State private var initialLimit: String = ""

    private let accountTypes = ["Credit", "Savings", "Loan", "Checking"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Account Details")) {
                    TextField("Account name", text: $accountName)
                    Picker("Type", selection: $accountType) {
                        ForEach(accountTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    TextField("Initial limit (optional)", text: $initialLimit)
                        .keyboardType(.numberPad)
                }

                Section(footer: Text("You can edit these details later in account settings.")) {
                    Button {
                        // TODO: Persist new account in data model
                        dismiss()
                    } label: {
                        Text("Create Account")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .disabled(accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Add Account")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    AddAccountView()
}
