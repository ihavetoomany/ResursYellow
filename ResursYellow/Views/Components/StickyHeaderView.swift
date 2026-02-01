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
    
    init(
        title: String,
        subtitle: String,
        minimizedTitle: String? = nil,
        trailingButton: String = "person.circle.fill",
        trailingButtonTint: Color = Color(UIColor.systemBlue),
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
        trailingButtonTint: Color = Color(UIColor.systemBlue),
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
                VStack(alignment: scrollProgress > 0.5 ? .center : .leading, spacing: 12) {
                    HStack {
                        // Spacer for centering when scrolled
                        if scrollProgress > 0.5 {
                            Spacer()
                        }
                        
                        VStack(alignment: scrollProgress > 0.5 ? .center : .leading, spacing: 4) {
                            // Subtitle - fades out
                            Text(subtitle)
                                .foregroundColor(.secondary)
                                .opacity(1.0 - scrollProgress)
                                .frame(height: scrollProgress > 0.5 ? 0 : nil)
                                .clipped()
                            
                            // Title - shrinks and centers with minimizedTitle support
                            if scrollProgress > 0.5 {
                                Text(minimizedTitle ?? title)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            } else {
                                Text(title)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                        
                        // Icons - fades out
                        if showBellIcon || !trailingButton.isEmpty {
                            if scrollProgress < 0.5 {
                                Spacer()
                                
                                if showBellIcon && !trailingButton.isEmpty {
                                    // Combined glass bubble with bell and chat icons
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
                                            .accessibilityLabel("Notifications")
                                            .accessibilityHint("View notifications")
                                            
                                            if bellBadgeCount > 0 {
                                                Text("\(bellBadgeCount)")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .frame(width: 16, height: 16)
                                                    .background(Color.red)
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
                                        .accessibilityLabel("Chat Support")
                                        .accessibilityHint("Open chat with support")
                                    }
                                    .background(.ultraThinMaterial, in: Capsule())
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.white.opacity(0.18), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.15), radius: 6, x: 0, y: 3)
                                    .opacity(1.0 - scrollProgress * 2)
                                } else if showBellIcon {
                                    // Bell icon only
                                    ZStack(alignment: .topTrailing) {
                                        GlassIconButton(size: trailingButtonSize, action: {
                                            bellIconAction?()
                                        }) {
                                            Image(systemName: "bell.fill")
                                                .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                                                .foregroundStyle(.secondary)
                                        }
                                        .accessibilityLabel("Notifications")
                                        .accessibilityHint("View notifications")
                                        
                                        if bellBadgeCount > 0 {
                                            Text("\(bellBadgeCount)")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                                .frame(width: 16, height: 16)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                                .offset(x: 0, y: 0)
                                        }
                                    }
                                    .opacity(1.0 - scrollProgress * 2)
                                } else {
                                    // Single icon button
                                    GlassIconButton(size: trailingButtonSize, action: {
                                        trailingButtonAction?()
                                    }) {
                                        Image(systemName: trailingButton)
                                            .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                                            .foregroundStyle(trailingButtonTint)
                                    }
                                    .opacity(1.0 - scrollProgress * 2)
                                    .accessibilityLabel("Action button")
                                    .accessibilityHint("Tap to perform action")
                                }
                            } else {
                                Spacer()
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
            .background(Color(uiColor: .systemBackground).opacity(scrollProgress * 0.5))
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
