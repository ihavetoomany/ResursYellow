//
//  ResursFamilyAccountView.swift
//  ResursYellow
//
//  Created by Bjarne Werner on 2025-11-02.
//

import SwiftUI
import Combine

struct ResursFamilyAccountView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    
    // Invoice Accounts - Resurs Gold's own payment plans
    private let invoiceAccounts: [PartPaymentItem] = [
        PartPaymentItem(
            title: "Resurs Gold Main",
            subtitle: "5 of 10 payments completed",
            amount: "3 200 kr / 32 000 kr",
            progress: 5.0/10.0,
            installmentAmount: "3 200 kr",
            totalAmount: "32 000 kr",
            completedPayments: 5,
            totalPayments: 10,
            nextDueDate: "Dec 20, 2025",
            autopaySource: "Resurs Gold"
        ),
        PartPaymentItem(
            title: "Resurs Flex October",
            subtitle: "3 of 12 payments completed",
            amount: "2 500 kr / 30 000 kr",
            progress: 3.0/12.0,
            installmentAmount: "2 500 kr",
            totalAmount: "30 000 kr",
            completedPayments: 3,
            totalPayments: 12,
            nextDueDate: "Dec 15, 2025",
            autopaySource: "Resurs Gold"
        )
    ]
    
    // Benefits for Resurs Gold
    private let benefits: [(icon: String, title: String, desc: String)] = [
        ("calendar.badge.clock", "Flexible Payments", "Choose flexible part payment plans for large purchases."),
        ("creditcard.fill", "Easy Checkout", "Use your Resurs Gold card for quick and secure payments."),
        ("heart.fill", "Family Sharing", "Share your credit account with family members."),
        ("shield.checkerboard", "Payment Protection", "Protect your purchases with optional payment insurance.")
    ]
    
    var body: some View {
        let scrollProgress = min(scrollObserver.offset / 100, 1.0)
        
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
                        
                        // Account for header height
                        Color.clear.frame(height: 80)
                    
                    VStack(spacing: 16) {
                    // Account Overview Card
                    AccountOverviewCard()
                        .padding(.horizontal)
                        .padding(.top, 36)
                        .padding(.bottom, 16)
                    
                    // Credit Cards Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Cards")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            CreditCardMini(
                                holder: "Jane Doe",
                                lastFour: "1234",
                                used: "5 500 SEK",
                                color: .green
                            )
                            
                            CreditCardMini(
                                holder: "John Doe",
                                lastFour: "5678",
                                used: "3 445 SEK",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                    // Invoice Accounts Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Invoice accounts")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(invoiceAccounts, id: \.title) { payment in
                                ResursGoldPartPaymentRow(payment: payment, showsDisclosure: false)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 16)
                    
                    // Benefits Section
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Resurs Gold Benefits")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 4)
                        VStack(spacing: 12) {
                            ForEach(benefits, id: \.title) { benefit in
                                HStack(spacing: 16) {
                                    Image(systemName: benefit.icon)
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.15))
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(benefit.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text(benefit.desc)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
                .padding(.bottom, 120) // Add bottom padding to clear custom tab bar
                }
                }
                .onReceive(NotificationCenter.default.publisher(for: .scrollToTop)) { _ in
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        proxy.scrollTo("scrollTop", anchor: .top)
                    }
                }
            }
            .coordinateSpace(name: "scroll")
            
            // Sticky Header (overlays the content)
            VStack(spacing: 0) {
                ZStack {
                    // Back button (always visible) - on the left
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .frame(width: 32, height: 32)
                                .background(.ultraThinMaterial) // Liquid glass style
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    
                    // Minimized title - centered in view
                    if scrollProgress > 0.5 {
                        Text("Resurs Gold")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, scrollProgress > 0.5 ? 8 : 12)
                
                // Title and subtitle - only shown when not minimized
                if scrollProgress <= 0.5 {
                    VStack(alignment: .leading, spacing: 4) {
                        // Subtitle
                        Text("Credit Account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(1.0 - scrollProgress * 2)
                        
                        // Title
                        Text("Resurs Gold")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
            }
            .background(Color(uiColor: .systemBackground).opacity(0.95))
            .background(.ultraThinMaterial)
            .animation(.easeInOut(duration: 0.2), value: scrollProgress)
        }
        .navigationBarHidden(true)
    }
}

struct ResursGoldPartPaymentRow: View {
    let payment: PartPaymentItem
    let showsDisclosure: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(payment.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(payment.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                if showsDisclosure {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.secondary)
                }
            }
            
            Text(payment.amount)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            ProgressView(value: payment.progress)
                .tint(.blue)
            
            HStack {
                Text("\(payment.completedPayments) of \(payment.totalPayments) payments")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(payment.nextDueDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct AccountOverviewCard: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Available Credit")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("56 005 SEK")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
                    .background(Color.blue.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Limit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("80 000 SEK")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 30)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Used Credit")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("62 000 SEK")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CreditCardMini: View {
    let holder: String
    let lastFour: String
    let used: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "creditcard.fill")
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 36, height: 36)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(holder)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("•••• \(lastFour)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(used)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("Used")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    ResursFamilyAccountView()
        .preferredColorScheme(.dark)
}

