import SwiftUI

// Wallet list, ported from the Onlinebank prototype: product cards with card
// artwork bleeding out bottom-right.

enum WalletBadge {
    /// Resurs "Rə" mark on a tinted square.
    case monogram(background: Color, foreground: Color)
    /// Asset image, e.g. a merchant logo. Falls back to a store icon if missing.
    case image(String)
    /// Font Awesome glyph on a tinted square.
    case icon(FAIcon, tint: Color, background: Color)
    /// Any custom 40×40 view (e.g. a drawn merchant mark).
    case view(AnyView)
}

struct WalletCard: View {
    let badge: WalletBadge
    let title: String
    let typeLabel: String
    let valueLabel: String
    let value: String
    var unit: String = "kr"
    let footnote: String
    /// Asset name of the physical card artwork; omitted for non-card products.
    var artwork: String? = nil
    /// Rendered width of the artwork. PNGs differ in transparent margin, so this is
    /// tuned per card to make them look the same size (values from the prototype).
    var artworkWidth: CGFloat = 108

    @Environment(\.colorScheme) private var colorScheme

    private var hasArtwork: Bool { artwork.map { UIImage(named: $0) != nil } ?? false }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 12) {
                badgeView
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    Text(typeLabel)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .textCase(.uppercase)
                        .tracking(0.5)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(valueLabel)
                    .font(.caption)
                    .foregroundColor(.secondary)
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(unit)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundColor(.primary)
                Text(footnote)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4) // a little more air between the amount and the footnote
            }
            // Keep text clear of the artwork
            .padding(.trailing, hasArtwork ? 110 : 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        // Artwork is a background so it never affects the card's height
        .background(alignment: .bottomTrailing) {
            if hasArtwork, let artwork {
                // Matches the prototype: -18°, poking in from the bottom-right corner
                Image(artwork)
                    .resizable()
                    .scaledToFit()
                    .frame(width: artworkWidth)
                    .rotationEffect(.degrees(-18))
                    .offset(x: 16 * artworkWidth / 108, y: 70 * artworkWidth / 108)
                    .shadow(color: Color(red: 40/255, green: 50/255, blue: 46/255).opacity(0.16), radius: 7, y: 6)
            }
        }
        // Same surface as the invoice rows: white in light, material over black in dark
        .background {
            if colorScheme == .light {
                Color.white
            } else {
                Color.clear.background(.regularMaterial)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(RyColor.borderSubtle, lineWidth: 1))
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var badgeView: some View {
        let shape = RoundedRectangle(cornerRadius: 12, style: .continuous)
        switch badge {
        case .monogram(let background, let foreground):
            Text("Rə")
                .font(.system(size: 18, weight: .heavy, design: .rounded))
                .foregroundColor(foreground)
                .frame(width: 40, height: 40)
                .background(background)
                .clipShape(shape)
        case .image(let name):
            Group {
                if UIImage(named: name) != nil {
                    Image(name).resizable().scaledToFit().padding(6)
                } else {
                    FAIconView(.store, style: .solid, size: 16).foregroundColor(.secondary)
                }
            }
            .frame(width: 40, height: 40)
            .background(Color.white) // logos are drawn on white; keep the tile white in dark mode too
            .clipShape(shape)
            .overlay(shape.stroke(RyColor.borderSubtle, lineWidth: 1))
        case .icon(let icon, let tint, let background):
            FAIconView(icon, style: .solid, size: 16)
                .foregroundColor(tint)
                .frame(width: 40, height: 40)
                .background(background)
                .clipShape(shape)
        case .view(let view):
            view
                .frame(width: 40, height: 40)
                .clipShape(shape)
        }
    }
}

/// The Ekonomi wallet list: data mirrors the Onlinebank prototype exactly.
struct WalletList: View {
    @Binding var navigationPath: NavigationPath

    private let beige = Color(ryHex: "#EBE3D6")
    private let ink = Color(ryHex: "#2C2C2B")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button { navigationPath.append("ResursFamily") } label: {
                WalletCard(
                    badge: .monogram(background: beige, foreground: ink),
                    title: "The Bergströms",
                    typeLabel: "Resurs Family",
                    valueLabel: "Available".localized,
                    value: "37 841",
                    footnote: String(format: "%lld purchases this month · %@".localized, 11, "16 952 kr"),
                    artwork: "CardResursFamily"
                )
            }
            .buttonStyle(.plain)

            Button { navigationPath.append("ResursGold") } label: {
                WalletCard(
                    badge: .monogram(background: RyColor.green50, foreground: RyColor.green700),
                    title: "Resurs Gold",
                    typeLabel: "Credit card".localized,
                    valueLabel: "Available".localized,
                    value: "31 500",
                    footnote: String(format: "%lld purchases this month · %@".localized, 6, "6 401 kr"),
                    artwork: "CardResursGold",
                    artworkWidth: 100
                )
            }
            .buttonStyle(.plain)

            Button { navigationPath.append("SavingsAccount") } label: {
                WalletCard(
                    badge: .icon(.piggyBank, tint: RyColor.primaryMain, background: RyColor.primaryBackground),
                    title: "Segelbåten",
                    typeLabel: "Savings account".localized,
                    valueLabel: "Total balance".localized,
                    value: "100 000",
                    footnote: "Make a deposit today!".localized
                )
            }
            .buttonStyle(.plain)

            Button { navigationPath.append("HouseRenovationLoan") } label: {
                WalletCard(
                    badge: .icon(.coins, tint: RyColor.primaryMain, background: RyColor.primaryBackground),
                    title: "Billån",
                    typeLabel: "Loan".localized,
                    valueLabel: "Remaining debt".localized,
                    value: "86 200",
                    footnote: String(format: "Original loan %@".localized, "120 000 kr")
                )
            }
            .buttonStyle(.plain)
        }
    }
}
