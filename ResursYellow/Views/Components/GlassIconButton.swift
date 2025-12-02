//
//  GlassIconButton.swift
//  ResursYellow
//
//  Created by AI on 2025-11-18.
//

import SwiftUI

/// Standard liquid-glass icon button used across the app to keep Apple HIG compliance.
private struct GlassIconButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(.ultraThinMaterial, in: Circle())
            .overlay(
                Circle()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct GlassIconButton: View {
    private let action: () -> Void
    private let content: AnyView
    private let size: CGFloat
    
    init(
        size: CGFloat = 44,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> some View
    ) {
        self.size = size
        self.action = action
        self.content = AnyView(content())
    }
    
    init(
        systemName: String,
        tint: Color = .primary,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.init(size: size, action: action) {
            Image(systemName: systemName)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundColor(tint)
        }
    }
    
    var body: some View {
        Button(action: action) {
            content
                .frame(width: size, height: size)
                .contentShape(Circle())
        }
        .buttonStyle(GlassIconButtonStyle())
        .accessibilityAddTraits(.isButton)
    }
}

