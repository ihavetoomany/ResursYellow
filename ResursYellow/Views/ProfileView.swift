//
//  ProfileView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigationPath = NavigationPath()
    @State private var showLogoutConfirmation = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top) {
                // Scrollable Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Account for header (close button + title/subtitle + padding)
                        Color.clear.frame(height: 170)
                        
                        VStack(spacing: 24) {
                            // Account/Profile Section
                            ProfileSection(title: "Account/Profile") {
                                ProfileRow(
                                    title: "Customer ID",
                                    subtitle: "12345678",
                                    icon: "person.fill",
                                    color: .blue
                                )
                                
                                NavigationLink(value: "ContactInformation") {
                                    ProfileRow(
                                        title: "Contact information",
                                        subtitle: "Email, Phone",
                                        icon: "envelope.fill",
                                        color: .green,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "KYC") {
                                    ProfileRow(
                                        title: "KYC",
                                        subtitle: "Know Your Customer",
                                        icon: "person.text.rectangle.fill",
                                        color: .purple,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "MyDocuments") {
                                    ProfileRow(
                                        title: "My documents",
                                        subtitle: "Agreements, Contracts",
                                        icon: "doc.fill",
                                        color: .orange,
                                        showChevron: true
                                    )
                                }
                            }
                            
                            // Insights Section
                            ProfileSection(title: "Insights") {
                                NavigationLink(value: "ChartOfExpenses") {
                                    ProfileRow(
                                        title: "Chart of expenses",
                                        subtitle: "View spending breakdown",
                                        icon: "chart.pie.fill",
                                        color: .red,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "ChartOfAvailableCredit") {
                                    ProfileRow(
                                        title: "Chart of available credit",
                                        subtitle: "Credit utilization",
                                        icon: "chart.bar.fill",
                                        color: .blue,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "SpendingTrends") {
                                    ProfileRow(
                                        title: "Spending trends",
                                        subtitle: "Gamification",
                                        icon: "chart.line.uptrend.xyaxis",
                                        color: .green,
                                        showChevron: true
                                    )
                                }
                            }
                            
                            // Settings Section
                            ProfileSection(title: "Settings") {
                                NavigationLink(value: "ConnectBankAccount") {
                                    ProfileRow(
                                        title: "Connect bank account",
                                        subtitle: "Link external accounts",
                                        icon: "building.columns.fill",
                                        color: .blue,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "NotificationSettings") {
                                    ProfileRow(
                                        title: "Notification settings",
                                        subtitle: "Communication, Marketing",
                                        icon: "bell.fill",
                                        color: .orange,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "Theme") {
                                    ProfileRow(
                                        title: "Theme",
                                        subtitle: "Light, Dark, Auto",
                                        icon: "paintbrush.fill",
                                        color: .purple,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "Language") {
                                    ProfileRow(
                                        title: "Language",
                                        subtitle: "App language",
                                        icon: "globe",
                                        color: .cyan,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "Accessibility") {
                                    ProfileRow(
                                        title: "A11y",
                                        subtitle: "Accessibility settings",
                                        icon: "accessibility",
                                        color: .indigo,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "Autopay") {
                                    ProfileRow(
                                        title: "Autopay",
                                        subtitle: "Automatic payments",
                                        icon: "arrow.clockwise.circle.fill",
                                        color: .green,
                                        showChevron: true
                                    )
                                }
                                
                                NavigationLink(value: "ChangeShortcuts") {
                                    ProfileRow(
                                        title: "Change shortcuts on homepage",
                                        subtitle: "Customize homepage",
                                        icon: "square.grid.2x2.fill",
                                        color: .pink,
                                        showChevron: true
                                    )
                                }
                            }
                            
                            // Log out Section
                            Button {
                                showLogoutConfirmation = true
                            } label: {
                                ProfileRow(
                                    title: "Log out",
                                    subtitle: "Sign out of your account",
                                    icon: "rectangle.portrait.and.arrow.right",
                                    color: .red,
                                    showChevron: false
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                }
                
                // Sticky Header with close button, title/subtitle
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Spacer()
                        
                        // Close button at top right
                        GlassIconButton(systemName: "xmark") {
                            dismiss()
                        }
                        .accessibilityLabel("Close profile")
                        .accessibilityHint("Dismiss profile overlay")
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    
                    // Title and subtitle below close button
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manage your account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Profile")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .background(Color(uiColor: .systemBackground).opacity(0.95))
                .background(.ultraThinMaterial)
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.hidden, for: .navigationBar)
            .navigationDestination(for: String.self) { destination in
                destinationView(for: destination)
            }
            .confirmationDialog("Log out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log out", role: .destructive) {
                    // Handle logout
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: String) -> some View {
        destinationContent(for: destination)
            .toolbar(.visible, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(uiColor: .systemBackground), for: .navigationBar)
    }
    
    @ViewBuilder
    private func destinationContent(for destination: String) -> some View {
        switch destination {
        case "ContactInformation":
            ContactInformationView()
        case "KYC":
            KYCView()
        case "MyDocuments":
            MyDocumentsView()
        case "ChartOfExpenses":
            ChartOfExpensesView()
        case "ChartOfAvailableCredit":
            ChartOfAvailableCreditView()
        case "SpendingTrends":
            SpendingTrendsView()
        case "ConnectBankAccount":
            ConnectBankAccountView()
        case "NotificationSettings":
            NotificationSettingsView()
        case "Theme":
            ThemeSettingsView()
        case "Language":
            LanguageSettingsView()
        case "Accessibility":
            AccessibilitySettingsView()
        case "Autopay":
            AutopaySettingsView()
        case "ChangeShortcuts":
            ChangeShortcutsView()
        default:
            Text("Coming soon")
                .navigationTitle(destination)
        }
    }
}

// MARK: - Profile Section Component
struct ProfileSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .padding(.horizontal, 4)
            
            VStack(spacing: 8) {
                content
            }
        }
    }
}

// MARK: - Profile Row Component
struct ProfileRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var showChevron: Bool = false
    
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
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Detail Views

struct ContactInformationView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List {
            Section {
                HStack {
                    Text("Email address")
                        .font(.subheadline)
                    Spacer()
                    Text("john.doe@example.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Phone nr")
                        .font(.subheadline)
                    Spacer()
                    Text("+46 70 123 45 67")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Contact Information")
            }
        }
        .navigationTitle("Contact Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KYCView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("View answers") {
                    Text("KYC Answers")
                        .navigationTitle("View Answers")
                }
                
                NavigationLink("Edit answers") {
                    Text("Edit KYC Answers")
                        .navigationTitle("Edit Answers")
                }
            } header: {
                Text("Know Your Customer")
            }
        }
        .navigationTitle("KYC")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyDocumentsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Agreements") {
                    Text("Agreements")
                        .navigationTitle("Agreements")
                }
                
                NavigationLink("Contracts") {
                    Text("Contracts")
                        .navigationTitle("Contracts")
                }
            } header: {
                Text("My Documents")
            }
        }
        .navigationTitle("My Documents")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartOfExpensesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Chart of Expenses")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                // Placeholder for chart
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.pie.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("Expense Chart")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding()
            }
        }
        .navigationTitle("Chart of Expenses")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartOfAvailableCreditView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Chart of Available Credit")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                // Placeholder for chart
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .frame(height: 300)
                    .overlay(
                        VStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("Credit Chart")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding()
            }
        }
        .navigationTitle("Chart of Available Credit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SpendingTrendsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Gamification") {
                    GamificationView()
                }
            } header: {
                Text("Spending Trends")
            }
        }
        .navigationTitle("Spending Trends")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GamificationView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Milestones") {
                    Text("Milestones")
                        .navigationTitle("Milestones")
                }
                
                NavigationLink("Badges or rewards") {
                    Text("Badges or Rewards")
                        .navigationTitle("Badges or Rewards")
                }
            } header: {
                Text("Gamification")
            }
        }
        .navigationTitle("Gamification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ConnectBankAccountView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(systemName: "building.columns.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                Text("Connect Bank Account")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Link your external bank accounts to get a complete view of your finances.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    // Handle connect bank account
                } label: {
                    Text("Connect Account")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal)
                .padding(.top, 20)
            }
        }
        .navigationTitle("Connect Bank Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView: View {
    @State private var communicationEnabled = true
    @State private var marketingEnabled = false
    
    var body: some View {
        List {
            Section {
                Toggle("Communication sendouts", isOn: $communicationEnabled)
                Toggle("Marketing", isOn: $marketingEnabled)
            } header: {
                Text("Notification Settings")
            } footer: {
                Text("Control how you receive notifications from Resurs.")
            }
        }
        .navigationTitle("Notification Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemeSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"
    
    var body: some View {
        List {
            Section {
                Picker("Theme", selection: $selectedTheme) {
                    Text("Light").tag("Light")
                    Text("Dark").tag("Dark")
                    Text("Auto").tag("Auto")
                }
            } header: {
                Text("Appearance")
            } footer: {
                Text("Choose your preferred theme. Auto will match your system settings.")
            }
        }
        .navigationTitle("Theme")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSettingsView: View {
    @AppStorage("selectedLanguage") private var selectedLanguage = "English"
    
    var body: some View {
        List {
            Section {
                Picker("Language", selection: $selectedLanguage) {
                    Text("English").tag("English")
                    Text("Svenska").tag("Svenska")
                    Text("Norsk").tag("Norsk")
                    Text("Dansk").tag("Dansk")
                }
            } header: {
                Text("App Language")
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccessibilitySettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Display & Text Size") {
                    Text("Display & Text Size Settings")
                        .navigationTitle("Display & Text Size")
                }
                
                NavigationLink("Motion") {
                    Text("Motion Settings")
                        .navigationTitle("Motion")
                }
                
                NavigationLink("VoiceOver") {
                    Text("VoiceOver Settings")
                        .navigationTitle("VoiceOver")
                }
            } header: {
                Text("Accessibility")
            } footer: {
                Text("Customize accessibility features to improve your experience.")
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AutopaySettingsView: View {
    @State private var autopayEnabled = false
    
    var body: some View {
        List {
            Section {
                Toggle("Enable Autopay", isOn: $autopayEnabled)
            } header: {
                Text("Automatic Payments")
            } footer: {
                Text("When enabled, payments will be automatically processed on their due dates.")
            }
        }
        .navigationTitle("Autopay")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChangeShortcutsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Change Shortcuts on Homepage")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Customize which shortcuts appear on your homepage.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Placeholder for shortcut customization
                VStack(spacing: 12) {
                    ForEach(["Wallet", "Accounts", "Merchants", "Support"], id: \.self) { shortcut in
                        HStack {
                            Text(shortcut)
                                .font(.subheadline)
                            Spacer()
                            Image(systemName: "line.3.horizontal")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Homepage Shortcuts")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}

