//
//  ChatView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct ManageView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showCallSupport = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Manage",
                subtitle: "Support, profile & settings",
                trailingButton: "phone.fill",
                trailingButtonTint: .blue,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showCallSupport = true
                }
            ) {
                VStack(spacing: 24) {
                    // Support Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Support")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
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

                    // Profile Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Profile")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        VStack(spacing: 12) {
                            ProfileRow(
                                title: "Customer ID",
                                subtitle: "12345678",
                                icon: "person.fill",
                                color: .blue
                            )
                            ProfileRow(
                                title: "Contact information",
                                subtitle: "Email, Phone",
                                icon: "envelope.fill",
                                color: .green,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "KYC",
                                subtitle: "Know Your Customer",
                                icon: "person.text.rectangle.fill",
                                color: .purple,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "My documents",
                                subtitle: "Agreements, Contracts",
                                icon: "doc.fill",
                                color: .orange,
                                showChevron: true
                            )
                        }
                        .padding(.horizontal)
                    }

                    // Settings Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Settings")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                        VStack(spacing: 12) {
                            ProfileRow(
                                title: "Connect bank account",
                                subtitle: "Link external accounts",
                                icon: "building.columns.fill",
                                color: .blue,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "Notification settings",
                                subtitle: "Communication, Marketing",
                                icon: "bell.fill",
                                color: .orange,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "Theme",
                                subtitle: "Light, Dark, Auto",
                                icon: "paintbrush.fill",
                                color: .purple,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "Language",
                                subtitle: "App language",
                                icon: "globe",
                                color: .cyan,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "A11y",
                                subtitle: "Accessibility settings",
                                icon: "accessibility",
                                color: .indigo,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "Autopay",
                                subtitle: "Automatic payments",
                                icon: "arrow.clockwise.circle.fill",
                                color: .green,
                                showChevron: true
                            )
                            ProfileRow(
                                title: "Change shortcuts on homepage",
                                subtitle: "Customize homepage",
                                icon: "square.grid.2x2.fill",
                                color: .pink,
                                showChevron: true
                            )
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top, 24)
            }
            .navigationBarHidden(true)
            .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                // If not at root level, pop to root
                if !navigationPath.isEmpty {
                    navigationPath.removeLast(navigationPath.count)
                }
                // If at root, the StickyHeaderView will handle scrolling to top
            }
            .sheet(isPresented: $showCallSupport) {
                CallSupportView()
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
    ManageView()
        .preferredColorScheme(.dark)
}

struct CallSupportView: View {
    @Environment(\.dismiss) private var dismiss
    private let supportNumber = "+46 771 11 22 33" // Example number
    private let telURL = URL(string: "tel://+46771112233")

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "phone.fill")
                    .font(.system(size: 56))
                    .foregroundColor(.green)
                    .padding(.top, 24)

                VStack(spacing: 6) {
                    Text("Customer Support")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("We’re here to help")
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

                Spacer()

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
                .padding(.bottom)
            }
            .navigationTitle("Call Support")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CallSupportView()
}

