//
//  HouseRenovationLoanView.swift
//  ResursYellow
//
//  House renovation loan product detail view.
//  Follows Apple's HIG with liquid glass design language.
//

import SwiftUI

struct HouseRenovationLoanView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var scrollObserver = ScrollOffsetObserver()
    @State private var showSettings = false
    @Environment(\.colorScheme) var colorScheme
    
    // Loan installments - simulated data
    private var loanInstallments: [LoanInstallment] {
        [
            LoanInstallment(
                title: "Monthly installment",
                amount: "4 250 SEK",
                dueDate: "15 Jan",
                isPaid: false,
                icon: "calendar",
                color: .orange
            ),
            LoanInstallment(
                title: "December payment",
                amount: "4 250 SEK",
                dueDate: "15 Dec",
                isPaid: true,
                icon: "checkmark.circle.fill",
                color: .green
            ),
            LoanInstallment(
                title: "November payment",
                amount: "4 250 SEK",
                dueDate: "15 Nov",
                isPaid: true,
                icon: "checkmark.circle.fill",
                color: .green
            )
        ]
    }
    
    // Benefits for House Renovation Loan
    private let benefits: [(icon: String, title: String, desc: String)] = [
        ("house.fill", "Home Improvement", "Finance your kitchen, bathroom, or full home renovation."),
        ("percent", "Competitive Rate", "Fixed interest rate of 4.95% for the entire loan period."),
        ("calendar.badge.clock", "Flexible Terms", "Choose repayment periods from 1 to 15 years."),
        ("shield.checkerboard", "Payment Protection", "Optional insurance to protect your payments.")
    ]
    
    // Documents for House Renovation Loan
    private let documents: [(icon: String, titleKey: String, descKey: String)] = [
        ("doc.text.fill", "Loan Agreement", "View your loan terms and repayment schedule"),
        ("doc.text", "Terms and Conditions", "Read the terms and conditions for your loan"),
        ("hand.raised.fill", "Privacy Policy", "Review how we handle your personal information"),
        ("doc.on.doc.fill", "Amortization Schedule", "View your complete payment schedule and balance")
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            // Extended background for navigation bar area
            if colorScheme == .light {
                Color(red: 0.93, green: 0.92, blue: 0.90)
                    .ignoresSafeArea()
            } else {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Scroll offset tracker
                    GeometryReader { geo in
                        Color.clear
                            .onChange(of: geo.frame(in: .named("scroll")).minY) { _, newValue in
                                scrollObserver.offset = max(0, -newValue)
                            }
                    }
                    .frame(height: 0)
                    
                    VStack(spacing: 16) {
                // Loan Overview Card
                LoanOverviewCard()
                    .padding(.horizontal)
                    .padding(.top, 4)
                    .padding(.bottom, 16)
                
                // Payment Schedule Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Payment schedule")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            // Handle "View all" tap
                        }) {
                            Text("View all")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    VStack(spacing: 12) {
                        ForEach(loanInstallments) { installment in
                            LoanInstallmentRow(installment: installment)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                
                // Accounts Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Accounts")
                            .font(.headline)
                            .fontWeight(.semibold)
                        Spacer()
                        Button(action: {
                            // Handle "View all" tap
                        }) {
                            Text("View all")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    
                    VStack(spacing: 12) {
                        LoanAccountRow(
                            title: "Kitchen Renovation",
                            subtitle: "Loan account · •••• 9012",
                            amount: "145 000 SEK",
                            progress: 0.52,
                            monthlyAmount: "2 450 SEK monthly",
                            nextDueDate: "15 Jan",
                            interestRate: "4.95%"
                        )
                        
                        LoanAccountRow(
                            title: "Bathroom Upgrade",
                            subtitle: "Loan account · •••• 9013",
                            amount: "110 000 SEK",
                            progress: 0.63,
                            monthlyAmount: "1 800 SEK monthly",
                            nextDueDate: "15 Jan",
                            interestRate: "4.95%"
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 16)
                
                // Benefits Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Benefits and services")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                        .padding(.top, 12)
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
                            .background {
                                if colorScheme == .light {
                                    ZStack {
                                        Color.white.opacity(0.7)
                                        Color.clear.background(.regularMaterial)
                                    }
                                } else {
                                    Color.clear.background(.regularMaterial)
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Documents Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Documents".localized)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                        .padding(.top, 12)
                    VStack(spacing: 12) {
                        ForEach(Array(documents.enumerated()), id: \.offset) { index, document in
                            Button(action: {
                                // Handle document tap - could navigate to document detail view
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: document.icon)
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                        .frame(width: 36, height: 36)
                                        .background(Color.blue.opacity(0.15))
                                        .clipShape(Circle())
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(document.titleKey.localized)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                        Text(document.descKey.localized)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background {
                                    if colorScheme == .light {
                                        ZStack {
                                            Color.white.opacity(0.7)
                                            Color.clear.background(.regularMaterial)
                                        }
                                    } else {
                                        Color.clear.background(.regularMaterial)
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Help and Support Section - HIG: Consistent support access
                HelpAndSupportSection()
                    .padding(.horizontal)
            }
            .padding(.vertical, 24)
        }
            }
            .coordinateSpace(name: "scroll")
        }
        .navigationTitle("House Renovation")
        .navigationBarTitleDisplayMode(.large)
        .toolbarBackground(scrollObserver.offset > 10 ? .visible : .hidden, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape.fill")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .shadow(color: scrollObserver.offset > 10 ? .black.opacity(0.1) : .clear, radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .sheet(isPresented: $showSettings) {
            ServiceSettingsView(serviceName: "House Renovation", serviceColor: .orange)
                .presentationBackground {
                    AdaptiveSheetBackground()
                }
        }
    }
}

// MARK: - Supporting Views

struct LoanOverviewCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Remaining Balance")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("255 000 SEK")
                        .font(.system(size: 32, weight: .bold))
                }
                
                Spacer()
                
                Image(systemName: "house.fill")
                    .font(.title)
                    .foregroundColor(.orange)
                    .frame(width: 56, height: 56)
                    .background(Color.orange.opacity(0.2))
                    .clipShape(Circle())
            }
            
            Divider()
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Original Loan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("300 000 SEK")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Divider()
                    .frame(height: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Monthly Payment")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("4 250 SEK")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
            }
        }
        .padding(20)
        .background {
            if colorScheme == .light {
                ZStack {
                    Color.white.opacity(0.7)
                    Color.clear.background(.regularMaterial)
                }
            } else {
                Color.clear.background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct LoanAccountRow: View {
    let title: String
    let subtitle: String
    let amount: String
    let progress: Double
    let monthlyAmount: String
    let nextDueDate: String
    let interestRate: String
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Text(amount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("remaining")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: progress)
                .tint(.orange)
            
            HStack {
                Text(monthlyAmount)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Due \(nextDueDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background {
            if colorScheme == .light {
                ZStack {
                    Color.white.opacity(0.7)
                    Color.clear.background(.regularMaterial)
                }
            } else {
                Color.clear.background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct LoanInstallment: Identifiable {
    let id = UUID()
    let title: String
    let amount: String
    let dueDate: String
    let isPaid: Bool
    let icon: String
    let color: Color
}

struct LoanInstallmentRow: View {
    let installment: LoanInstallment
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: installment.icon)
                .font(.title3)
                .foregroundColor(installment.color)
                .frame(width: 40, height: 40)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(installment.color.opacity(0.2))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(installment.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("Due \(installment.dueDate)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(installment.amount)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                if installment.isPaid {
                    Text("Paid")
                        .font(.caption)
                        .foregroundColor(.green)
                } else {
                    Text("Pending")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(16)
        .background {
            if colorScheme == .light {
                ZStack {
                    Color.white.opacity(0.7)
                    Color.clear.background(.regularMaterial)
                }
            } else {
                Color.clear.background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        HouseRenovationLoanView()
            .preferredColorScheme(.dark)
    }
}
