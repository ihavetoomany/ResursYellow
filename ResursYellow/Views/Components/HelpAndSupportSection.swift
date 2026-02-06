//
//  HelpAndSupportSection.swift
//  ResursYellow
//
//  Reusable Help and Support section component
//  Follows Apple HIG: uses system icons, dynamic type, and accessible design
//

import SwiftUI

// MARK: - Adaptive Card Background for Help Section
private struct HelpCardBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        if colorScheme == .light {
            Color.white
        } else {
            Color.clear.background(.regularMaterial)
        }
    }
}

/// A reusable section that provides help and support options
/// Displays contact methods and self-service resources in a consistent, accessible format
struct HelpAndSupportSection: View {
    /// Optional title override. Defaults to "Help and support"
    var title: String = "Help and support"
    
    /// Support options with SF Symbols icons
    private let supportOptions: [(icon: String, title: String, subtitle: String, action: SupportAction)] = [
        ("message.fill", "Chat with us", "Get instant help from our support team", .chat),
        ("questionmark.circle.fill", "FAQ", "Find answers to common questions", .faq)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title - HIG: Use semantic font styles
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 4)
                .padding(.top, 12)
                .accessibilityAddTraits(.isHeader)
            
            VStack(spacing: 12) {
                ForEach(supportOptions.indices, id: \.self) { index in
                    let option = supportOptions[index]
                    Button(action: {
                        handleAction(option.action)
                    }) {
                        HStack(spacing: 16) {
                            // Icon - HIG: Use SF Symbols for consistency
                            Image(systemName: option.icon)
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 36, height: 36)
                                .background(Color.blue.opacity(0.15))
                                .clipShape(Circle())
                                .accessibilityHidden(true)
                            
                            // Content - HIG: Use semantic labels for VoiceOver
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                Text(option.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            // Disclosure indicator - HIG: Standard navigation hint
                            Image(systemName: "chevron.right")
                                .font(.footnote.weight(.semibold))
                                .foregroundColor(.secondary)
                                .accessibilityHidden(true)
                        }
                        .padding(16)
                        .background(HelpCardBackground())
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(option.title), \(option.subtitle)")
                    .accessibilityHint("Double tap to open")
                }
            }
        }
    }
    
    /// Support action types
    private enum SupportAction {
        case chat
        case faq
    }
    
    /// Handle support action
    /// HIG: Provide immediate feedback and appropriate navigation
    private func handleAction(_ action: SupportAction) {
        // Haptic feedback - HIG: Provide tactile confirmation
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        
        switch action {
        case .chat:
            // TODO: Open chat interface
            print("Opening chat support")
        case .faq:
            // TODO: Navigate to FAQ view
            print("Opening FAQ")
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            HelpAndSupportSection()
                .padding(.horizontal)
        }
        .padding(.vertical, 24)
    }
    .background(Color(uiColor: .systemGroupedBackground))
}
