//
//  ManageView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI
import UIKit

private func availableSymbol(_ preferred: String, fallback: String) -> String {
    if UIImage(systemName: preferred) != nil {
        return preferred
    }
    return fallback
}

struct ManageView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var localizationService = LocalizationService.shared
    @State private var navigationPath = NavigationPath()
    @State private var showAISupport = false
    @State private var showLogoutConfirmation = false
    @State private var showResetConfirmation = false
    @State private var selectedPersonaId: String = DataManager.shared.currentPersona.id
    
    // Helper to ensure views update when language changes
    private var currentLanguage: Language {
        localizationService.currentLanguage
    }
    
    private func localized(_ key: String) -> String {
        _ = currentLanguage // Reference to trigger updates
        return localizationService.localizedString(key, fallback: key)
    }
    
    var body: some View {
        let _ = currentLanguage // Ensure view updates when language changes
        return NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: localized("My Resurs"),
                subtitle: localized("Profile & settings"),
                trailingButton: "message.fill",
                trailingButtonTint: .secondary,
                trailingButtonSize: 44,
                trailingButtonIconScale: 0.5,
                trailingButtonAction: {
                    showAISupport = true
                }
            ) {
                VStack(spacing: 24) {
                    // Profile Section
                    ProfileSection(title: localized("Profile")) {
                        NavigationLink(value: "Notifications") {
                            ProfileRow(
                                title: localized("Notifications"),
                                subtitle: localized("Messages from Resurs"),
                                icon: "bell.fill",
                                color: .orange,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "KYC") {
                            ProfileRow(
                                title: "KYC",
                                subtitle: localized("Know Your Customer"),
                                icon: "person.text.rectangle.fill",
                                color: .purple,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "MyDocuments") {
                            ProfileRow(
                                title: localized("My documents"),
                                subtitle: localized("Agreements, Contracts"),
                                icon: "doc.fill",
                                color: .orange,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "SpendingTrends") {
                            ProfileRow(
                                title: localized("Spending trends"),
                                subtitle: localized("Gamification"),
                                icon: "chart.line.uptrend.xyaxis",
                                color: .green,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Settings Section
                    ProfileSection(title: localized("Settings")) {
                        ProfileRow(
                            title: localized("Customer ID"),
                            subtitle: "12345678",
                            icon: "person.fill",
                            color: .blue
                        )
                        
                        NavigationLink(value: "ContactInformation") {
                            ProfileRow(
                                title: localized("Contact information"),
                                subtitle: localized("Email, Phone"),
                                icon: "envelope.fill",
                                color: .green,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "ConnectBankAccount") {
                            ProfileRow(
                                title: localized("Payment method"),
                                subtitle: localized("Link external accounts"),
                                icon: "building.columns.fill",
                                color: .blue,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "NotificationSettings") {
                            ProfileRow(
                                title: localized("Notification settings"),
                                subtitle: localized("Communication, Marketing"),
                                icon: "bell.fill",
                                color: .orange,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "Theme") {
                            ProfileRow(
                                title: localized("Theme"),
                                subtitle: localized("Light, Dark, Auto"),
                                icon: "paintbrush.fill",
                                color: .purple,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "Language") {
                            ProfileRow(
                                title: localized("Language"),
                                subtitle: localizationService.currentLanguage.displayName,
                                icon: "globe",
                                color: .cyan,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "Accessibility") {
                            ProfileRow(
                                title: "A11y",
                                subtitle: localized("Accessibility settings"),
                                icon: "accessibility",
                                color: .indigo,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(value: "Autopay") {
                            ProfileRow(
                                title: localized("Autopay"),
                                subtitle: localized("Automatic payments"),
                                icon: "arrow.clockwise.circle.fill",
                                color: .green,
                                showChevron: true
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Log out Section
                    Button {
                        showLogoutConfirmation = true
                    } label: {
                        ProfileRow(
                            title: localized("Log out"),
                            subtitle: localized("Sign out of your account"),
                            icon: "rectangle.portrait.and.arrow.right",
                            color: .red,
                            showChevron: false
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 8)
                    
                    // Prototype Section
                    ProfileSection(title: localized("Prototype")) {
                        // Persona Picker
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(.purple)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localized("Switch Persona"))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                Text(localized("Change user"))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Picker("", selection: $selectedPersonaId) {
                                ForEach(Persona.allPersonas) { persona in
                                    Text(persona.displayName).tag(persona.id)
                                }
                            }
                            .pickerStyle(.menu)
                            .onChange(of: selectedPersonaId) { oldValue, newValue in
                                if let persona = Persona.persona(withId: newValue) {
                                    dataManager.switchPersona(persona)
                                }
                            }
                        }
                        .padding(16)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            showResetConfirmation = true
                        } label: {
                            ProfileRow(
                                title: localized("Reset Data"),
                                subtitle: localized("Restore default data"),
                                icon: "arrow.counterclockwise",
                                color: .orange,
                                showChevron: false
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top, 40)
                }
                .padding(.horizontal)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { destination in
                destinationView(for: destination)
            }
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                // If not at root level, pop to root
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
                // If at root, the StickyHeaderView will handle scrolling to top
            }
            .sheet(isPresented: $showAISupport) {
                AISupportChatView()
                    .presentationBackground {
                        AdaptiveSheetBackground()
                    }
            }
            .confirmationDialog("Log out", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("Log out", role: .destructive) {
                    // Handle logout
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
            .confirmationDialog("Reset Data", isPresented: $showResetConfirmation, titleVisibility: .visible) {
                Button("Reset", role: .destructive) {
                    dataManager.reset()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will restore all data to default values. All your changes will be lost. Are you sure?")
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
        case "Notifications":
            NotificationsView()
        case "KYC":
            KYCView()
        case "MyDocuments":
            MyDocumentsView()
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
        default:
            Text("Coming soon")
                .navigationTitle(destination)
        }
    }
}

// MARK: - Contact Method Row Component
struct ContactMethodRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
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
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Call Support View
struct CallSupportView: View {
    @Environment(\.dismiss) private var dismiss
    private let supportNumber = "+46 771 11 22 33" // Example number
    private let telURL = URL(string: "tel://+46771112233")

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "phone.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.green)
                        .padding(.top, 8)

                    VStack(spacing: 6) {
                        Text("Customer Support")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("We're here to help")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    VStack(spacing: 8) {
                        HStack {
                            Text("Phone")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            Text(supportNumber)
                                .font(.headline)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack(alignment: .top) {
                            Text("Hours")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("Mon–Fri: 08:00–18:00")
                                Text("Sat: 10:00–14:00")
                                Text("Sun: Closed")
                            }
                            .font(.subheadline)
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)

                    Button {
                        if let telURL, UIApplication.shared.canOpenURL(telURL) {
                            UIApplication.shared.open(telURL)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "phone.fill")
                            Text("Call Now")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Call Support")
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
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .presentationBackground {
            AdaptiveSheetBackground()
        }
    }
}

#Preview {
    ManageView()
        .preferredColorScheme(.dark)
}

