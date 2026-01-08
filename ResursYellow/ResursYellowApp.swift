//
//  ResursYellowApp.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI

@main
struct ResursYellowApp: App {
    @AppStorage("selectedTheme") private var selectedTheme = "Auto"
    
    init() {
        configureTabBarAppearance()
    }
    
    private var colorScheme: ColorScheme? {
        switch selectedTheme {
        case "Light":
            return .light
        case "Dark":
            return .dark
        default: // "Auto"
            return nil // nil means use system setting
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme)
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
