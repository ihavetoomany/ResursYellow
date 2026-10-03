import SwiftUI

struct CrossSellOffer: Identifiable {
    let id: String
    let icon: String
    let eyebrow: String
    let title: String
    let subtitle: String
    let cta: String
    let accent: Color
    let background: Color
}

/// Horizontally paging carousel with cross-sell cards for loans and savings.
struct CrossSellCarousel: View {
    var onSelect: (CrossSellOffer) -> Void

    @State private var selectedID: String?

    private let offers: [CrossSellOffer] = [
        CrossSellOffer(
            id: "loan",
            icon: "house.fill",
            eyebrow: "Loans".localized,
            title: "Borrow for your next project".localized,
            subtitle: "Renovation loan with a personal offer in minutes.".localized,
            cta: "See your offer".localized,
            accent: RyColor.infoMain,
            background: RyColor.infoBackground.opacity(0.55)
        ),
        CrossSellOffer(
            id: "savings",
            icon: "banknote.fill",
            eyebrow: "Savings".localized,
            title: "Let your money grow".localized,
            subtitle: "Open a savings account with no fixed term and no fees.".localized,
            cta: "Start saving".localized,
            accent: RyColor.successMain,
            background: RyColor.successBackground.opacity(0.55)
        ),
        CrossSellOffer(
            id: "flex",
            icon: "creditcard.fill",
            eyebrow: "Flex".localized,
            title: "Split your purchases with Flex".localized,
            subtitle: "Spread the cost of a purchase over monthly payments, after you have bought it.".localized,
            cta: "Choose a purchase".localized,
            accent: RyColor.flexMain,
            background: RyColor.flexBackground.opacity(0.55)
        )
    ]

    var body: some View {
        VStack(spacing: 10) {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(offers) { offer in
                        Button { onSelect(offer) } label: { card(offer) }
                            .buttonStyle(.plain)
                            .containerRelativeFrame(.horizontal) { w, _ in w - 56 }
                            // Off-centre cards sit back slightly so the snap reads visually
                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.94)
                                    .opacity(phase.isIdentity ? 1 : 0.8)
                            }
                            .id(offer.id)
                    }
                }
                .scrollTargetLayout()
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            // One card per swipe: a flick can't skip past the next card
            .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
            .scrollPosition(id: $selectedID)
            .sensoryFeedback(.selection, trigger: selectedID)

            HStack(spacing: 6) {
                ForEach(offers) { offer in
                    Capsule()
                        .fill((selectedID ?? offers[0].id) == offer.id ? Color.primary : Color.primary.opacity(0.25))
                        .frame(width: (selectedID ?? offers[0].id) == offer.id ? 16 : 6, height: 6)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: selectedID)
            .accessibilityHidden(true)
        }
    }

    private func card(_ offer: CrossSellOffer) -> some View {
        HStack(alignment: .top, spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text(offer.eyebrow.uppercased())
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.6)
                    .foregroundColor(offer.accent)
                Text(offer.title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(offer.subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 4)
                HStack(spacing: 4) {
                    Text(offer.cta)
                        .font(.system(size: 14, weight: .semibold))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                }
                .foregroundColor(offer.accent)
            }
            Spacer(minLength: 0)
            Image(systemName: offer.icon)
                .font(.system(size: 22))
                .foregroundColor(offer.accent)
                .frame(width: 44, height: 44)
                .background(Circle().fill(offer.accent.opacity(0.15)))
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 150, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20, style: .continuous).fill(offer.background))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(offer.accent.opacity(0.25), lineWidth: 1))
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
    }
}
