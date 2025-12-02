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
    let trailingButton: String
    let trailingButtonTint: Color
    let trailingButtonSize: CGFloat
    let trailingButtonIconScale: CGFloat
    let trailingButtonAction: (() -> Void)?
    let content: Content
    let stickyContent: StickyContent?
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    
    init(
        title: String,
        subtitle: String,
        trailingButton: String = "person.circle.fill",
        trailingButtonTint: Color = Color(UIColor.systemBlue),
        trailingButtonSize: CGFloat = 44,
        trailingButtonIconScale: CGFloat = 0.45,
        trailingButtonAction: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) where StickyContent == EmptyView {
        self.title = title
        self.subtitle = subtitle
        self.trailingButton = trailingButton
        self.trailingButtonTint = trailingButtonTint
        self.trailingButtonSize = trailingButtonSize
        self.trailingButtonIconScale = trailingButtonIconScale
        self.trailingButtonAction = trailingButtonAction
        self.content = content()
        self.stickyContent = nil
    }
    
    init(
        title: String,
        subtitle: String,
        trailingButton: String = "person.circle.fill",
        trailingButtonTint: Color = Color(UIColor.systemBlue),
        trailingButtonSize: CGFloat = 44,
        trailingButtonIconScale: CGFloat = 0.45,
        trailingButtonAction: (() -> Void)? = nil,
        @ViewBuilder stickyContent: () -> StickyContent,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.trailingButton = trailingButton
        self.trailingButtonTint = trailingButtonTint
        self.trailingButtonSize = trailingButtonSize
        self.trailingButtonIconScale = trailingButtonIconScale
        self.trailingButtonAction = trailingButtonAction
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
                        .padding(.bottom, 100) // Add bottom padding to clear custom tab bar
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
                            
                            // Title - shrinks and centers
                            Text(title)
                                .font(scrollProgress > 0.5 ? .title2 : .largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                        }
                        
                        // Icon - fades out
                        if !trailingButton.isEmpty {
                            if scrollProgress < 0.5 {
                                Spacer()
                                
                                GlassIconButton(size: trailingButtonSize, action: {
                                    trailingButtonAction?()
                                }) {
                                    Image(systemName: trailingButton)
                                        .font(.system(size: trailingButtonSize * trailingButtonIconScale, weight: .semibold))
                                        .foregroundColor(trailingButtonTint)
                                }
                                .opacity(1.0 - scrollProgress * 2)
                                .accessibilityLabel("Profile")
                                .accessibilityHint("Open profile settings")
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
            .background(Color(uiColor: .systemBackground).opacity(0.95))
            .background(.ultraThinMaterial)
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