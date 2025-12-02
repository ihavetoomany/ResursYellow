//
//  ContentView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

// Notification for scroll to top
extension Notification.Name {
    static let scrollToTop = Notification.Name("scrollToTop")
}

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var paymentPlansManager = PaymentPlansManager()
    @State private var hasAppeared = false
    @State private var isReady = false // defer heavy UI one frame
    
    var body: some View {
        Group {
            if !isReady {
                // Lightweight launch scaffold for the very first frame
                ZStack {
                    Color(UIColor.systemBackground).ignoresSafeArea()
                    VStack(spacing: 12) {
                        // Simple header placeholder to match Wallet look
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Good day")
                                    .foregroundColor(.secondary)
                                    .redacted(reason: .placeholder)
                                Text("John")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .redacted(reason: .placeholder)
                            }
                            Spacer()
                            Circle()
                                .fill(Color.secondary.opacity(0.2))
                                .frame(width: 44, height: 44)
                                .redacted(reason: .placeholder)
                        }
                        .padding(.horizontal)
                        .padding(.top, 24)
                        
                        Spacer()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.blue)
                        
                        Spacer()
                    }
                }
            } else {
                TabView(selection: $selectedTab) {
                    // Wallet Tab
                    NavigationStack {
                        WalletView()
                    }
                    .tabItem {
                        Label("Wallet", systemImage: selectedTab == 0 ? "creditcard.fill" : "creditcard")
                    }
                    .tag(0)
                    
                    // Accounts Tab (lazy loaded)
                    NavigationStack {
                        Group {
                            if hasAppeared || selectedTab == 1 {
                                AccountsView()
                            } else {
                                Color.clear
                            }
                        }
                    }
                    .tabItem {
                        Label("Accounts", systemImage: selectedTab == 1 ? "building.columns.fill" : "building.columns")
                    }
                    .tag(1)
                    
                    // Merchants Tab (lazy loaded)
                    NavigationStack {
                        Group {
                            if hasAppeared || selectedTab == 2 {
                                MerchantsView()
                            } else {
                                Color.clear
                            }
                        }
                    }
                    .tabItem {
                        Label("Merchants", systemImage: selectedTab == 2 ? "bag.fill" : "bag")
                    }
                    .tag(2)
                    
                    // Support Tab (lazy loaded)
                    NavigationStack {
                        Group {
                            if hasAppeared || selectedTab == 3 {
                                ChatView()
                            } else {
                                Color.clear
                            }
                        }
                    }
                    .tabItem {
                        Label("Support", systemImage: selectedTab == 3 ? "message.fill" : "message")
                    }
                    .tag(3)
                }
                .tint(.blue) // Native iOS blue tint for selected items
                .environmentObject(paymentPlansManager)
            }
        }
        .task {
            // Ensure first frame is rendered before constructing the heavy TabView tree
            await Task.yield()
            isReady = true
            
            // Defer loading of other tabs to improve startup performance
            // (no artificial delay; just yield once)
            await Task.yield()
            hasAppeared = true
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            // Haptic feedback on tab change
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            
            // If same tab tapped, post notification to scroll to top
            if oldValue == newValue {
                NotificationCenter.default.post(name: .scrollToTop, object: nil)
            }
        }
    }
}

#Preview("Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
