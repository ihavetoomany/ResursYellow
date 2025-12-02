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
    @EnvironmentObject var paymentPlansManager: PaymentPlansManager
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var showPaymentPlanOptions = false
    
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
                            Text("Family Cards")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                // Action for card options
                            }) {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
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
                    
                    // Payment Plans Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active Payment Plans")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Spacer()
                            Button(action: {
                                showPaymentPlanOptions = true
                            }) {
                                Image(systemName: "ellipsis.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            ForEach(paymentPlansManager.paymentPlans) { paymentPlan in
                                PaymentPlanCard(
                                    title: paymentPlan.name,
                                    totalAmount: paymentPlan.totalAmount,
                                    paidAmount: paymentPlan.paidAmount,
                                    progress: paymentPlan.progress,
                                    dueDate: paymentPlan.dueDate,
                                    monthlyAmount: paymentPlan.monthlyAmount,
                                    icon: paymentPlan.icon,
                                    color: paymentPlan.color
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
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
                        Text("Resurs Family")
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
                        Text("Joint Credit Account")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .opacity(1.0 - scrollProgress * 2)
                        
                        // Title
                        Text("Resurs Family")
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
        .sheet(isPresented: $showPaymentPlanOptions) {
            PaymentPlanOptionsSheet()
                .presentationDetents([.height(220)])
                .presentationDragIndicator(.visible)
        }
    }
}

struct PaymentPlanOptionsSheet: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                dismiss()
                // Action to create new payment plan
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text("Create New Payment Plan")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
            
            Divider()
            
            Button(action: {
                dismiss()
                // Action to view payment plan history
            }) {
                HStack {
                    Image(systemName: "clock.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                    Text("Payment Plan History")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
            }
        }
        .background(Color(UIColor.systemBackground))
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
                    Text("Shared Limit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("80 000 SEK")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("In Payment Plans")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("15 050 SEK")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
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

struct PaymentPlanCard: View {
    let title: String
    let totalAmount: String
    let paidAmount: String
    let progress: Double
    let dueDate: String
    let monthlyAmount: String?
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 40, height: 40)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                    if let monthly = monthlyAmount {
                        Text("\(dueDate) (\(monthly))")
                            .font(.caption)
                            .foregroundColor(progress == 1.0 ? .green : .secondary)
                    } else {
                        Text(dueDate)
                            .font(.caption)
                            .foregroundColor(progress == 1.0 ? .green : .secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(paidAmount)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(totalAmount)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(progress == 1.0 ? Color.green : color)
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    ResursFamilyAccountView()
        .environmentObject(PaymentPlansManager())
        .preferredColorScheme(.dark)
}

