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
    static let switchToServices = Notification.Name("switchToServices")
    static let switchToMerchants = Notification.Name("switchToMerchants")
}

struct ContentView: View {
    @StateObject private var localizationService = LocalizationService.shared
    @State private var selectedTab = 0
    @StateObject private var paymentPlansManager = PaymentPlansManager.shared
    @State private var hasAppeared = false
    
    var body: some View {
        MainTabView(
            selectedTab: $selectedTab,
            hasAppeared: $hasAppeared,
            paymentPlansManager: paymentPlansManager,
            localizationService: localizationService,
            walletLabel: "Payments",
            bankingLabel: "Services",
            merchantsLabel: "Merchants",
            manageLabel: "My Resurs"
        )
        .onAppear {
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
        .onReceive(NotificationCenter.default.publisher(for: .switchToServices)) { notification in
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .switchToMerchants)) { _ in
            selectedTab = 2
        }
    }
}

// Separate view for TabView construction
struct MainTabView: View {
    @Binding var selectedTab: Int
    @Binding var hasAppeared: Bool
    @ObservedObject var paymentPlansManager: PaymentPlansManager
    @ObservedObject var localizationService: LocalizationService
    let walletLabel: String
    let bankingLabel: String
    let merchantsLabel: String
    let manageLabel: String
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Payments Tab
            PaymentsView()
                .tabItem {
                    Label(walletLabel, systemImage: selectedTab == 0 ? "wallet.bifold.fill" : "wallet.bifold")
                }
                .tag(0)
            
            // Services Tab (lazy loaded)
            Group {
                if hasAppeared || selectedTab == 1 {
                    ServicesView()
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label(bankingLabel, systemImage: selectedTab == 1 ? "building.columns.fill" : "building.columns")
            }
            .tag(1)
            
            // Merchants Tab (lazy loaded)
            Group {
                if hasAppeared || selectedTab == 2 {
                    MerchantsView()
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label(merchantsLabel, systemImage: selectedTab == 2 ? "cart.fill" : "cart")
            }
            .tag(2)
            
            // Manage Tab (lazy loaded)
            Group {
                if hasAppeared || selectedTab == 3 {
                    ManageView()
                } else {
                    Color.clear
                }
            }
            .tabItem {
                Label(manageLabel, systemImage: selectedTab == 3 ? "person.fill" : "person")
            }
            .tag(3)
        }
        .tint(.blue)
        .environmentObject(paymentPlansManager)
        .environmentObject(localizationService)
        .id(localizationService.currentLanguage)
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
