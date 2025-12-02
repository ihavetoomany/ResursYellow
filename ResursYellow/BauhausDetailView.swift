//  BauhausDetailView.swift
//  ResursYellow
//
//  Details and benefits for Bauhaus integration

import SwiftUI

struct BauhausDetailView: View {
    // Example credit info
    let availableCredit: String = "14 500 kr"
    let creditLimit: String = "25 000 kr"
    
    // Define a local struct to avoid collision with global PurchaseItem
    struct BauhausPurchase: Identifiable {
        let id = UUID()
        var title: String
        var subtitle: String
        var amount: String
        var icon: String
        var color: Color
        var category: Category
        var transaction: String?
        
        enum Category {
            case large, recent
        }
    }
    
    // Example purchases list using BauhausPurchase
    let purchases: [BauhausPurchase] = [
        BauhausPurchase(title: "Paint Roller Set", subtitle: "Nov 2, 2025", amount: "298 kr", icon: "paintbrush.pointed.fill", color: .orange, category: .large, transaction: nil),
        BauhausPurchase(title: "Interior Paint", subtitle: "Nov 2, 2025", amount: "800 kr", icon: "paintpalette.fill", color: .orange, category: .large, transaction: nil),
        BauhausPurchase(title: "Drop Cloth", subtitle: "Oct 5, 2025", amount: "200 kr", icon: "drop.fill", color: .orange, category: .recent, transaction: nil)
    ]
    
    let benefits: [(icon: String, title: String, desc: String)] = [
        ("calendar.badge.clock", "Part Payment", "Choose flexible part payment plans for large purchases."),
        ("tag.fill", "Exclusive Deals", "Get access to member prices and special offers."),
        ("giftcard.fill", "Kickback", "Earn kickback on every purchase at Bauhaus."),
        ("shield.checkerboard", "Payment Insurance", "Protect your purchases with optional payment insurance.")
    ]
    
    // Example part payments for the new section
    let partPayments: [PartPaymentItem] = [
        PartPaymentItem(title: "Paint Project Split", subtitle: "2 of 6 payments completed", amount: "726 kr / 4 356 kr", progress: 2.0/6.0),
        PartPaymentItem(title: "Kitchen Remodel", subtitle: "1 of 4 payments completed", amount: "1 200 kr / 4 800 kr", progress: 1.0/4.0),
        PartPaymentItem(title: "Garden Supplies", subtitle: "3 of 5 payments completed", amount: "900 kr / 1 500 kr", progress: 3.0/5.0)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                VStack {
                    Image(systemName: "house.lodge.fill")
                        .font(.system(size: 54))
                        .foregroundColor(.orange)
                        .background(
                            Circle()
                                .fill(Color.orange.opacity(0.12))
                                .frame(width: 82, height: 82)
                        )
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 12)
                
                // Top info box
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Easy flexible payments")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Text("Bauhaus offers Purchase Now, Pay Later (PNPL) with several part payment options.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("You can also open a credit account for easy checkout and part payment at Bauhaus stores and online.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    Divider()
                    HStack(spacing: 32) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Available Credit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(availableCredit)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Credit Limit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(creditLimit)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        Spacer()
                    }
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal)
                
                // Purchases
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Bauhaus Purchases")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    VStack(spacing: 12) {
                        ForEach(purchases) { item in
                            HStack(spacing: 16) {
                                Image(systemName: item.icon)
                                    .font(.title3)
                                    .foregroundColor(item.color)
                                    .frame(width: 36, height: 36)
                                    .background(item.color.opacity(0.2))
                                    .clipShape(Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Text(item.amount)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Part Payments Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Part Payments")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    VStack(spacing: 12) {
                        ForEach(partPayments, id: \.title) { payment in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(payment.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                Text(payment.subtitle)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(payment.amount)
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                GeometryReader { geo in
                                    Rectangle()
                                        .fill(Color.orange)
                                        .frame(width: geo.size.width * CGFloat(payment.progress), height: 8)
                                        .cornerRadius(4)
                                        .animation(.easeInOut, value: payment.progress)
                                }
                                .frame(height: 8)
                            }
                            .padding(16)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
                .padding(.horizontal)
                
                // Benefits
                VStack(alignment: .leading, spacing: 16) {
                    Text("Bauhaus Benefits")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 4)
                    VStack(spacing: 12) {
                        ForEach(benefits, id: \.title) { benefit in
                            HStack(spacing: 16) {
                                Image(systemName: benefit.icon)
                                    .font(.title3)
                                    .foregroundColor(.orange)
                                    .frame(width: 36, height: 36)
                                    .background(Color.orange.opacity(0.15))
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
                Spacer(minLength: 40)
            }
            .padding(.top, 16)
        }
        .navigationTitle("Bauhaus")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Supporting structs for example data models to avoid errors
struct PartPaymentItem {
    var title: String
    var subtitle: String
    var amount: String
    var progress: Double
}

#Preview {
    BauhausDetailView()
        .preferredColorScheme(.light)
}
