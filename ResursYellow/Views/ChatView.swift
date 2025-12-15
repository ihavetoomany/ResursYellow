//
//  ChatView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct ChatView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showCallSupport = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Support",
                subtitle: "Get help anytime",
                trailingButton: "phone.fill",
                trailingButtonTint: .blue,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showCallSupport = true
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
    ChatView()
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

