//
//  ChatView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct ChatView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Support",
                subtitle: "Get help anytime",
                trailingButton: "person.fill",
                trailingButtonTint: .black,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showProfile = true
                }
            ) {
                VStack(spacing: 16) {
                    // Support Options
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(spacing: 12) {
                            ContactMethodRow(
                                title: "Report issue",
                                subtitle: "Zendesk",
                                icon: "exclamationmark.triangle.fill",
                                color: .red
                            )
                            
                            ContactMethodRow(
                                title: "Messages from the bank",
                                subtitle: "View bank notifications",
                                icon: "envelope.fill",
                                color: .blue
                            )
                            
                            ContactMethodRow(
                                title: "Live chat",
                                subtitle: "Zendesk",
                                icon: "message.fill",
                                color: .green
                            )
                            
                            ContactMethodRow(
                                title: "FAQ",
                                subtitle: "Zendesk",
                                icon: "questionmark.circle.fill",
                                color: .orange
                            )
                            
                            ContactMethodRow(
                                title: "Aktiv låneansökan?",
                                subtitle: "Check loan application status",
                                icon: "doc.text.fill",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 24)
                }
            }
            .navigationBarHidden(true)
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

#Preview {
    ChatView()
        .preferredColorScheme(.dark)
}
