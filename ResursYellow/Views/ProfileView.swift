//
//  ProfileView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var localizationService = LocalizationService.shared
    @State private var navigationPath = NavigationPath()
    @State private var showLogoutConfirmation = false
    @State private var showResetConfirmation = false
    @AppStorage("notificationsRead") private var notificationsRead = false
    
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
                            ProfileSection(title: "Account/Profile".localized) {
                                ProfileRow(
                                    title: "Customer ID".localized,
                                    subtitle: "12345678",
                                    icon: "person.fill",
                                    color: .blue
                                )
                                
                                NavigationLink(value: "ContactInformation") {
                                    ProfileRow(
                                        title: "Contact information".localized,
                                        subtitle: "Email, Phone".localized,
                                        icon: "envelope.fill",
                                        color: .green,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "KYC") {
                                    ProfileRow(
                                        title: "KYC".localized,
                                        subtitle: "Know Your Customer".localized,
                                        icon: "person.text.rectangle.fill",
                                        color: .purple,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "MyDocuments") {
                                    ProfileRow(
                                        title: "My documents".localized,
                                        subtitle: "Agreements, Contracts".localized,
                                        icon: "doc.fill",
                                        color: .orange,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Insights Section
                            ProfileSection(title: "Insights".localized) {
                                NavigationLink(value: "ChartOfExpenses") {
                                    ProfileRow(
                                        title: "Chart of expenses".localized,
                                        subtitle: "View spending breakdown".localized,
                                        icon: "chart.pie.fill",
                                        color: .red,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "ChartOfAvailableCredit") {
                                    ProfileRow(
                                        title: "Chart of available credit".localized,
                                        subtitle: "Credit utilization".localized,
                                        icon: "chart.bar.fill",
                                        color: .blue,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "SpendingTrends") {
                                    ProfileRow(
                                        title: "Spending trends".localized,
                                        subtitle: "Gamification".localized,
                                        icon: "chart.line.uptrend.xyaxis",
                                        color: .green,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Settings Section
                            ProfileSection(title: "Settings".localized) {
                                NavigationLink(value: "ConnectBankAccount") {
                                    ProfileRow(
                                        title: "Payment method".localized,
                                        subtitle: "Link external accounts".localized,
                                        icon: "building.columns.fill",
                                        color: .blue,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "NotificationSettings") {
                                    ProfileRow(
                                        title: "Notification settings".localized,
                                        subtitle: "Communication, Marketing".localized,
                                        icon: "bell.fill",
                                        color: .orange,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "Theme") {
                                    ProfileRow(
                                        title: "Theme".localized,
                                        subtitle: "Light, Dark, Auto".localized,
                                        icon: "paintbrush.fill",
                                        color: .purple,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "Language") {
                                    ProfileRow(
                                        title: "Language".localized,
                                        subtitle: localizationService.currentLanguage.displayName,
                                        icon: "globe",
                                        color: .cyan,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "Accessibility") {
                                    ProfileRow(
                                        title: "A11y".localized,
                                        subtitle: "Accessibility settings".localized,
                                        icon: "accessibility",
                                        color: .indigo,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "Autopay") {
                                    ProfileRow(
                                        title: "Autopay".localized,
                                        subtitle: "Automatic payments".localized,
                                        icon: "arrow.clockwise.circle.fill",
                                        color: .green,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                NavigationLink(value: "ChangeShortcuts") {
                                    ProfileRow(
                                        title: "Change shortcuts on homepage".localized,
                                        subtitle: "Customize homepage".localized,
                                        icon: "square.grid.2x2.fill",
                                        color: .pink,
                                        showChevron: true
                                    )
                                }
                                .buttonStyle(.plain)
                                
                                Button {
                                    showResetConfirmation = true
                                } label: {
                                    ProfileRow(
                                        title: "Reset Data".localized,
                                        subtitle: "Restore default data".localized,
                                        icon: "arrow.counterclockwise",
                                        color: .orange,
                                        showChevron: false
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            // Log out Section
                            Button {
                                showLogoutConfirmation = true
                            } label: {
                                ProfileRow(
                                    title: "Log out".localized,
                                    subtitle: "Sign out of your account".localized,
                                    icon: "rectangle.portrait.and.arrow.right",
                                    color: .red,
                                    showChevron: false
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 8)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 16)
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
                        .accessibilityLabel("Close profile".localized)
                        .accessibilityHint("Dismiss profile overlay".localized)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    
                    // Title and subtitle below close button
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Manage your account".localized)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Profile".localized)
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
            .confirmationDialog("Log out".localized, isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log out".localized, role: .destructive) {
                    // Handle logout
                }
                Button("Cancel".localized, role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?".localized)
            }
            .confirmationDialog("Reset Data".localized, isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset".localized, role: .destructive) {
                    dataManager.reset()
                    notificationsRead = false
                }
                Button("Cancel".localized, role: .cancel) {}
            } message: {
                Text("This will restore all data to default values. All your changes will be lost. Are you sure?".localized)
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
            Text("Coming soon".localized)
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
    
    @Environment(\.colorScheme) var colorScheme
    
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
                    .foregroundStyle(.primary)
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
        .background {
            if colorScheme == .light {
                Color.white
            } else {
                Color.clear.background(.regularMaterial)
            }
        }
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
                    Text("Email address".localized)
                        .font(.subheadline)
                    Spacer()
                    Text("john.doe@example.com")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Phone nr".localized)
                        .font(.subheadline)
                    Spacer()
                    Text("+46 70 123 45 67")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            } header: {
                Text("Contact Information".localized)
            }
        }
        .navigationTitle("Contact Information".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Payment Confirmation".localized) {
                    Text("Payment of 2,450 SEK received".localized)
                        .navigationTitle("Payment Confirmation".localized)
                }
                
                NavigationLink("Invoice Available".localized) {
                    Text("Your December invoice is ready".localized)
                        .navigationTitle("Invoice Available".localized)
                }
                
                NavigationLink("Account Update".localized) {
                    Text("Your credit limit has been increased".localized)
                        .navigationTitle("Account Update".localized)
                }
            } header: {
                Text("Messages".localized)
            }
            
            Section {
                NavigationLink("Payment reminder".localized) {
                    Text("Payment due in 3 days".localized)
                        .navigationTitle("Payment Reminder".localized)
                }
                
                NavigationLink("Spending alert".localized) {
                    Text("You've reached 80% of your monthly budget".localized)
                        .navigationTitle("Spending Alert".localized)
                }
                
                NavigationLink("New offer available".localized) {
                    Text("Special rate on savings account".localized)
                        .navigationTitle("New Offer".localized)
                }
            } header: {
                Text("Notifications".localized)
            }
        }
        .navigationTitle("Messages & Notifications".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KYCView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("View answers".localized) {
                    Text("KYC Answers".localized)
                        .navigationTitle("View Answers".localized)
                }
                
                NavigationLink("Edit answers".localized) {
                    Text("Edit KYC Answers".localized)
                        .navigationTitle("Edit Answers".localized)
                }
            } header: {
                Text("Know Your Customer".localized)
            }
        }
        .navigationTitle("KYC".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MyDocumentsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Agreements".localized) {
                    Text("Agreements".localized)
                        .navigationTitle("Agreements".localized)
                }
                
                NavigationLink("Contracts".localized) {
                    Text("Contracts".localized)
                        .navigationTitle("Contracts".localized)
                }
            } header: {
                Text("My Documents".localized)
            }
        }
        .navigationTitle("My Documents".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartOfExpensesView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Chart of Expenses".localized)
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
                            Text("Expense Chart".localized)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding()
            }
        }
        .navigationTitle("Chart of Expenses".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChartOfAvailableCreditView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Chart of Available Credit".localized)
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
                            Text("Credit Chart".localized)
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding()
            }
        }
        .navigationTitle("Chart of Available Credit".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SpendingTrendsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Gamification".localized) {
                    GamificationView()
                }
            } header: {
                Text("Spending Trends".localized)
            }
        }
        .navigationTitle("Spending Trends".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GamificationView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Milestones".localized) {
                    Text("Milestones".localized)
                        .navigationTitle("Milestones".localized)
                }
                
                NavigationLink("Badges or rewards".localized) {
                    Text("Badges or Rewards".localized)
                        .navigationTitle("Badges or Rewards".localized)
                }
            } header: {
                Text("Gamification".localized)
            }
        }
        .navigationTitle("Gamification".localized)
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
                
                Text("Connect Bank Account".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Link your external bank accounts to get a complete view of your finances.".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button {
                    // Handle connect bank account
                } label: {
                    Text("Connect Account".localized)
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
        .navigationTitle("Connect Bank Account".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NotificationSettingsView: View {
    @State private var communicationEnabled = true
    @State private var marketingEnabled = false
    
    var body: some View {
        List {
            Section {
                Toggle("Communication sendouts".localized, isOn: $communicationEnabled)
                Toggle("Marketing".localized, isOn: $marketingEnabled)
            } header: {
                Text("Notification Settings".localized)
            } footer: {
                Text("Control how you receive notifications from Resurs.".localized)
            }
        }
        .navigationTitle("Notification Settings".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ThemeSettingsView: View {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"
    
    var body: some View {
        List {
            Section {
                Picker("Theme".localized, selection: $selectedTheme) {
                    Text("Light".localized).tag("Light")
                    Text("Dark".localized).tag("Dark")
                    Text("Auto".localized).tag("Auto")
                }
            } header: {
                Text("Appearance".localized)
            } footer: {
                Text("Choose your preferred theme. Auto will match your system settings.".localized)
            }
        }
        .navigationTitle("Theme".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LanguageSettingsView: View {
    @StateObject private var localizationService = LocalizationService.shared
    
    var body: some View {
        List {
            Section {
                Picker("Language".localized, selection: Binding(
                    get: { localizationService.currentLanguage },
                    set: { localizationService.setLanguage($0) }
                )) {
                    ForEach(Language.allCases) { language in
                        Text(language.displayName).tag(language)
                    }
                }
            } header: {
                Text("App Language".localized)
            } footer: {
                Text("Choose your preferred language for the app interface.".localized)
            }
        }
        .navigationTitle("Language".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AccessibilitySettingsView: View {
    var body: some View {
        List {
            Section {
                NavigationLink("Display & Text Size".localized) {
                    Text("Display & Text Size Settings".localized)
                        .navigationTitle("Display & Text Size".localized)
                }
                
                NavigationLink("Motion".localized) {
                    Text("Motion Settings".localized)
                        .navigationTitle("Motion".localized)
                }
                
                NavigationLink("VoiceOver".localized) {
                    Text("VoiceOver Settings".localized)
                        .navigationTitle("VoiceOver".localized)
                }
            } header: {
                Text("Accessibility".localized)
            } footer: {
                Text("Customize accessibility features to improve your experience.".localized)
            }
        }
        .navigationTitle("Accessibility".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AutopaySettingsView: View {
    @State private var autopayEnabled = false
    
    var body: some View {
        List {
            Section {
                Toggle("Enable Autopay".localized, isOn: $autopayEnabled)
            } header: {
                Text("Automatic Payments".localized)
            } footer: {
                Text("When enabled, payments will be automatically processed on their due dates.".localized)
            }
        }
        .navigationTitle("Autopay".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChangeShortcutsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Change Shortcuts on Homepage".localized)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Customize which shortcuts appear on your homepage.".localized)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Placeholder for shortcut customization
                VStack(spacing: 12) {
                    ForEach(["Overview", "Accounts", "Merchants", "Support"], id: \.self) { shortcut in
                        HStack {
                            Text(shortcut.localized)
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
        .navigationTitle("Homepage Shortcuts".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .preferredColorScheme(.dark)
}

