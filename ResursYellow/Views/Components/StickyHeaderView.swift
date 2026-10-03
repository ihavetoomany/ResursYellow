//
//  StickyHeaderView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-10-04.
//

import SwiftUI
import Combine

// Helper to track scroll offset
class ScrollOffsetObserver: ObservableObject {
    @Published var offset: CGFloat = 0
}

struct StickyHeaderView<Content: View, StickyContent: View>: View {
    let title: String
    let subtitle: String
    let minimizedTitle: String?
    let trailingButton: String
    let trailingButtonTint: Color
    let trailingButtonSize: CGFloat
    let trailingButtonIconScale: CGFloat
    let trailingButtonAction: (() -> Void)?
    let showBellIcon: Bool
    let bellIconAction: (() -> Void)?
    let bellBadgeCount: Int
    let content: Content
    let stickyContent: StickyContent?
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @Environment(\.colorScheme) private var colorScheme
    
    /// Matches the ZStack base fill used on Payments, Services, Merchants, and Manage tabs so the header tint aligns with the screen while material blur keeps translucency.
    private var screenBaseBackground: Color {
        RyColor.bgDefault
    }
    
    init(
        title: String,
        subtitle: String,
        minimizedTitle: String? = nil,
        trailingButton: String = "person.circle.fill",
        trailingButtonTint: Color = RyColor.primaryMain,
        trailingButtonSize: CGFloat = 44,
        trailingButtonIconScale: CGFloat = 0.45,
        trailingButtonAction: (() -> Void)? = nil,
        showBellIcon: Bool = false,
        bellIconAction: (() -> Void)? = nil,
        bellBadgeCount: Int = 0,
        @ViewBuilder content: () -> Content
    ) where StickyContent == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.minimizedTitle = minimizedTitle
        self.trailingButton = trailingButton
        self.trailingButtonTint = trailingButtonTint
        self.trailingButtonSize = trailingButtonSize
        self.trailingButtonIconScale = trailingButtonIconScale
        self.trailingButtonAction = trailingButtonAction
        self.showBellIcon = showBellIcon
        self.bellIconAction = bellIconAction
        self.bellBadgeCount = bellBadgeCount
        self.content = content()
        self.stickyContent = nil
    }
    
    init(
        title: String,
        subtitle: String,
        minimizedTitle: String? = nil,
        trailingButton: String = "person.circle.fill",
        trailingButtonTint: Color = RyColor.primaryMain,
        trailingButtonSize: CGFloat = 44,
        trailingButtonIconScale: CGFloat = 0.45,
        trailingButtonAction: (() -> Void)? = nil,
        showBellIcon: Bool = false,
        bellIconAction: (() -> Void)? = nil,
        bellBadgeCount: Int = 0,
        @ViewBuilder stickyContent: () -> StickyContent,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.minimizedTitle = minimizedTitle
        self.trailingButton = trailingButton
        self.trailingButtonTint = trailingButtonTint
        self.trailingButtonSize = trailingButtonSize
        self.trailingButtonIconScale = trailingButtonIconScale
        self.trailingButtonAction = trailingButtonAction
        self.showBellIcon = showBellIcon
        self.bellIconAction = bellIconAction
        self.bellBadgeCount = bellBadgeCount
        self.stickyContent = stickyContent()
        self.content = content()
    }
    
    /// Bell and/or trailing toolbar control (HIG: persistent affordances in navigation chrome).
    @ViewBuilder
    private func trailingHeaderAccessory() -> some View {
        if showBellIcon && !trailingButton.isEmpty {
            HStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                        bellIconAction?()
                    }) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: trailingButtonSize, height: trailingButtonSize)
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Notifications".localized)
                    .accessibilityHint("View notifications".localized)
                    
                    if bellBadgeCount > 0 {
                        Text("\(bellBadgeCount)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 16, height: 16)
                            .background(RyColor.errorMain)
                            .clipShape(Circle())
                            .offset(x: 0, y: 0)
                    }
                }
                
                Button(action: {
                    trailingButtonAction?()
                }) {
                    Image(systemName: trailingButton)
                        .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                        .foregroundStyle(trailingButtonTint)
                        .frame(width: trailingButtonSize, height: trailingButtonSize)
                        .contentShape(Circle())
                }
                .accessibilityLabel("Chat Support".localized)
                .accessibilityHint("Open chat with support".localized)
            }
            .background(.ultraThinMaterial, in: Capsule())
            .overlay(
                Capsule()
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
        } else if showBellIcon {
            ZStack(alignment: .topTrailing) {
                GlassIconButton(size: trailingButtonSize, action: {
                    bellIconAction?()
                }) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Notifications".localized)
                .accessibilityHint("View notifications".localized)
                
                if bellBadgeCount > 0 {
                    Text("\(bellBadgeCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 16, height: 16)
                        .background(RyColor.errorMain)
                        .clipShape(Circle())
                        .offset(x: 0, y: 0)
                }
            }
        } else if !trailingButton.isEmpty {
            GlassIconButton(size: trailingButtonSize, action: {
                trailingButtonAction?()
            }) {
                Image(systemName: trailingButton)
                    .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                    .foregroundStyle(trailingButtonTint)
            }
            .accessibilityLabel("Action button".localized)
            .accessibilityHint("Tap to perform action".localized)
        }
    }
    
    var body: some View {
        let scrollProgress = min(scrollObserver.offset / 100, 1.0) // Normalize scroll progress
        
        ZStack(alignment: .top) {
            // Scrollable Content
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        // Tracking element
                        GeometryReader { geometry in
                            Color.clear
                                .onChange(of: geometry.frame(in: .named("scroll")).minY) { oldValue, newValue in
                                    scrollObserver.offset = max(0, -newValue)
                                }
                        }
                        .frame(height: 0)
                        .id("scrollTop") // ID for scroll to top
                        
                        // Account for header + sticky section if present
                        Color.clear.frame(height: stickyContent != nil ? 160 : 90)
                        
                        VStack(spacing: 20) {
                            content
                        }
                        .padding(.bottom, 16) // Small padding for visual spacing
                    }
                    .padding(.top)
                }
                .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        proxy.scrollTo("scrollTop", anchor: .top)
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            
            // Sticky Header (overlays the content)
            VStack(alignment: .leading, spacing: 0) {
                // Header content
                VStack(alignment: scrollProgress >= 0.5 ? .center : .leading, spacing: 12) {
                    if scrollProgress >= 0.5 {
                        // Collapsed: centered title (HIG inline navigation) + trailing bell stays visible
                        ZStack {
                            Text((minimizedTitle ?? title).localized)
                                .font(.ry(20, 700))
                                .foregroundStyle(RyColor.fgPrimary)
                                .frame(maxWidth: .infinity)
                            
                            if showBellIcon || !trailingButton.isEmpty {
                                HStack {
                                    Spacer()
                                    trailingHeaderAccessory()
                                }
                            }
                        }
                        .frame(minHeight: trailingButtonSize)
                    } else {
                        HStack(alignment: .top, spacing: 0) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(subtitle.localized)
                                    .font(.ryBody2)
                                    .foregroundStyle(RyColor.fgSecondary)
                                    .opacity(1.0 - scrollProgress)

                                Text(title.localized)
                                    .font(.ry(34, 800))
                                    .foregroundStyle(RyColor.fgPrimary)
                            }
                            
                            if showBellIcon || !trailingButton.isEmpty {
                                Spacer(minLength: 8)
                                trailingHeaderAccessory()
                                    .opacity(1.0 - scrollProgress * 2)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20 - (scrollProgress * 10)) // Shrink vertical padding
                
                // Optional sticky content section (pills, etc)
                if let stickyContent = stickyContent {
                    AnyView(stickyContent)
                }
            }
            .background(screenBaseBackground.opacity(scrollProgress * 0.5))
            .background(.ultraThinMaterial.opacity(scrollProgress * 0.8))
            .animation(.easeInOut(duration: 0.2), value: scrollProgress)
        }
    }
}

#Preview {
    StickyHeaderView(title: "Preview", subtitle: "Testing sticky header") {
        VStack(spacing: 20) {
            ForEach(0..<20) { index in
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .frame(height: 100)
                    .overlay(
                        Text("Content Item \(index + 1)")
                            .font(.headline)
                    )
            }
        }
        .padding(.horizontal)
    }
    .preferredColorScheme(.dark)
}
