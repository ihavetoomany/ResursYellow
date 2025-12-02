//
//  ResursYellowApp.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

@main
struct ResursYellowApp: App {
    @AppStorage("hasSeenAboutDialog") private var hasSeenAboutDialog = false
    @State private var showAbout = false
    
    init() {
        configureTabBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Show about dialog only on first launch, after a short delay to let the UI settle
                    if !hasSeenAboutDialog {
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                        showAbout = true
                        hasSeenAboutDialog = true
                    }
                }
                .alert("About this app", isPresented: $showAbout) {
                    Button("OK", role: .cancel) {}
                } message: {
                    Text("This app is used to experiment and determine future solutions and information architecture. It does not represent the future app in terms of colors and design. You are welcome to provide any kind of feedback through the feedback functionality in TestFlight.")
                }
        }
    }
    
    private func configureTabBarAppearance() {
        // Create liquid glass appearance for tab bar
        let appearance = UITabBarAppearance()
        
        // Configure blur effect with ultra thin material for glassmorphism
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        
        // Add subtle shadow for depth (adapts to light/dark mode)
        appearance.shadowColor = UIColor.label.withAlphaComponent(0.1)
        
        // Configure selected item appearance
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor.systemBlue
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        
        // Configure normal (unselected) item appearance
        itemAppearance.normal.iconColor = UIColor.secondaryLabel
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]
        
        // Apply item appearance
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        
        // Apply appearance to all tab bars
        UITabBar.appearance().standardAppearance = appearance
        
        // Important: Apply same appearance for scroll edge to maintain consistency
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
