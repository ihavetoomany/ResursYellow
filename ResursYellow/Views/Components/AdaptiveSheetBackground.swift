//
//  AdaptiveSheetBackground.swift
//  ResursYellow
//
//  Created by AI on 2025-12-07.
//

import SwiftUI

/// Adaptive sheet background that matches the carousel cards (SummaryBox) in WalletView.
/// Uses solid color (no transparency) matching the shade of `.thinMaterial` used in SummaryBox cards.
struct AdaptiveSheetBackground: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        // Match the visual appearance of .thinMaterial used in SummaryBox carousel cards
        // SummaryBox uses .thinMaterial which appears darker than .ultraThinMaterial
        // We use a solid color that matches this appearance
        ZStack {
            // Base solid color matching thinMaterial appearance
            if colorScheme == .dark {
                // In dark mode, thinMaterial is darker - use a darker gray
                Color(red: 0.11, green: 0.11, blue: 0.12)
            } else {
                // In light mode, thinMaterial is lighter - use a lighter gray
                Color(uiColor: .secondarySystemBackground)
            }
        }
        .ignoresSafeArea(.all)
    }
}

