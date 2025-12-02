//
//  ExploreView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

struct ExploreView: View {
    @State private var navigationPath = NavigationPath()
    @State private var showProfile = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            StickyHeaderView(
                title: "Discover",
                subtitle: "Explore more",
                trailingButton: "person.fill",
                trailingButtonTint: .black,
                trailingButtonSize: 52,
                trailingButtonIconScale: 0.6,
                trailingButtonAction: {
                    showProfile = true
                }
            ) {
                VStack(spacing: 16) {
                    // Highlights Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Highlights")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                FeaturedCard(
                                    title: "Special Offers",
                                    subtitle: "Exclusive deals for you",
                                    icon: "star.fill",
                                    color: .blue
                                )
                                
                                FeaturedCard(
                                    title: "New Features",
                                    subtitle: "Discover what's new",
                                    icon: "sparkles",
                                    color: .purple
                                )
                                
                                FeaturedCard(
                                    title: "Top Products",
                                    subtitle: "Most popular choices",
                                    icon: "chart.bar.fill",
                                    color: .green
                                )
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 24)
                    .padding(.bottom, 16)
                    
                    // Partner Offers Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Partner Offers")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                            ServiceCard(
                                title: "Partner Deal 1",
                                subtitle: "Exclusive offer",
                                icon: "handshake.fill",
                                color: .blue
                            )
                            
                            ServiceCard(
                                title: "Partner Deal 2",
                                subtitle: "Limited time",
                                icon: "gift.fill",
                                color: .orange
                            )
                            
                            ServiceCard(
                                title: "Partner Deal 3",
                                subtitle: "Special discount",
                                icon: "tag.fill",
                                color: .green
                            )
                            
                            ServiceCard(
                                title: "Partner Deal 4",
                                subtitle: "Best value",
                                icon: "percent",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                    // News Section with Marketing Campaigns
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("News")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button("See All") {
                                // Navigate to news
                            }
                            .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            NewsRow(
                                title: "Marketing Campaign: Summer Savings",
                                subtitle: "2 hours ago",
                                category: "Marketing"
                            )
                            
                            NewsRow(
                                title: "Marketing Campaign: New Year Special",
                                subtitle: "5 hours ago",
                                category: "Marketing"
                            )
                            
                            NewsRow(
                                title: "Latest Financial News",
                                subtitle: "1 day ago",
                                category: "News"
                            )
                            
                            NewsRow(
                                title: "Marketing Campaign: Spring Promotion",
                                subtitle: "2 days ago",
                                category: "Marketing"
                            )
                            
                            NewsRow(
                                title: "Industry Updates",
                                subtitle: "3 days ago",
                                category: "News"
                            )
                            
                            NewsRow(
                                title: "Marketing Campaign: Holiday Deals",
                                subtitle: "4 days ago",
                                category: "Marketing"
                            )
                        }
                        .padding(.horizontal)
                    }
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

struct FeaturedCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .frame(width: 200, height: 140)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct ServiceCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct NewsRow: View {
    let title: String
    let subtitle: String
    let category: String
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text(category.uppercased())
                    .font(.caption)
                    .fontWeight(.semibold)
                                .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.blue.opacity(0.2))
                    .clipShape(Capsule())
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                
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
    ExploreView()
        .preferredColorScheme(.dark)
}
