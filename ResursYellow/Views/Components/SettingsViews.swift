//
//  SettingsViews.swift
//  ResursYellow
//
//  Settings views for merchants and services.
//  Follows Apple's HIG with liquid glass design language.
//

import SwiftUI

// MARK: - Merchant Settings View
/// Settings overlay for merchant detail pages (Bauhaus, Netonnet, Jula, etc.)
struct MerchantSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let merchantName: String
    let merchantColor: Color
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Account Management Section
                    SettingsSection(title: "Account Management") {
                        SettingsRow(
                            icon: "creditcard.fill",
                            iconColor: merchantColor,
                            title: "View Credit Details",
                            subtitle: "Check your credit limit and usage"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .blue,
                            title: "Notifications",
                            subtitle: "Manage alerts for purchases and payments"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "calendar.badge.clock",
                            iconColor: .orange,
                            title: "Payment Reminders",
                            subtitle: "Set up payment due date reminders"
                        ) {
                            // Handle tap
                        }
                    }
                    
                    // Preferences Section
                    SettingsSection(title: "Preferences") {
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .purple,
                            title: "Statement Preferences",
                            subtitle: "Choose how you receive statements"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "lock.fill",
                            iconColor: .green,
                            title: "Security Settings",
                            subtitle: "Manage PIN and security options"
                        ) {
                            // Handle tap
                        }
                    }
                    
                    // Account Actions Section
                    SettingsSection(title: "Account Actions") {
                        SettingsRow(
                            icon: "pause.circle.fill",
                            iconColor: .yellow,
                            title: "Freeze Account",
                            subtitle: "Temporarily disable purchases"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "xmark.circle.fill",
                            iconColor: .red,
                            title: "Close Account",
                            subtitle: "Permanently close this credit account"
                        ) {
                            // Handle tap
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("\(merchantName) Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

// MARK: - Service Settings View
/// Settings overlay for service detail pages (House Renovation, Resurs Family, Senior Savings)
struct ServiceSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    let serviceName: String
    let serviceColor: Color
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Account Management Section
                    SettingsSection(title: "Account Management") {
                        SettingsRow(
                            icon: "creditcard.fill",
                            iconColor: serviceColor,
                            title: "Account Details",
                            subtitle: "View complete account information"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "bell.fill",
                            iconColor: .blue,
                            title: "Notifications",
                            subtitle: "Manage alerts and notifications"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "calendar.badge.clock",
                            iconColor: .orange,
                            title: "Payment Schedule",
                            subtitle: "View and manage payment dates"
                        ) {
                            // Handle tap
                        }
                    }
                    
                    // Preferences Section
                    SettingsSection(title: "Preferences") {
                        SettingsRow(
                            icon: "doc.text.fill",
                            iconColor: .purple,
                            title: "Statement Preferences",
                            subtitle: "Choose how you receive statements"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "arrow.triangle.2.circlepath",
                            iconColor: .cyan,
                            title: "Auto-Pay Settings",
                            subtitle: "Configure automatic payments"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "lock.fill",
                            iconColor: .green,
                            title: "Security Settings",
                            subtitle: "Manage security and privacy"
                        ) {
                            // Handle tap
                        }
                    }
                    
                    // Account Actions Section
                    SettingsSection(title: "Account Actions") {
                        SettingsRow(
                            icon: "pause.circle.fill",
                            iconColor: .yellow,
                            title: "Pause Service",
                            subtitle: "Temporarily suspend this service"
                        ) {
                            // Handle tap
                        }
                        
                        SettingsRow(
                            icon: "xmark.circle.fill",
                            iconColor: .red,
                            title: "Close Account",
                            subtitle: "Permanently close this account"
                        ) {
                            // Handle tap
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 24)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("\(serviceName) Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// A section container for settings groups
struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

/// A single settings row with icon, title, subtitle, and action
struct SettingsRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(iconColor)
                    .frame(width: 36, height: 36)
                    .background(iconColor.opacity(0.15))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Merchant Settings") {
    MerchantSettingsView(merchantName: "Bauhaus", merchantColor: .red)
}

#Preview("Service Settings") {
    ServiceSettingsView(serviceName: "House Renovation", serviceColor: .orange)
}
