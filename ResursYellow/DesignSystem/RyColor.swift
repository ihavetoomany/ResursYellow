import SwiftUI
import UIKit

// Resurs UI 2.0 colour tokens — ported from the Resurs design system
// (ds/colors_and_type.css / tokens.ts). Tokens are dynamic: they resolve to the
// light or dark value automatically from the active trait collection, so they
// work with the app's existing light/dark theme handling with no plumbing.

extension UIColor {
    convenience init(ryHex hex: String) {
        let s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("rgb") {
            let inner = s.replacingOccurrences(of: "rgba(", with: "")
                .replacingOccurrences(of: "rgb(", with: "")
                .replacingOccurrences(of: ")", with: "")
            let p = inner.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
            let r = CGFloat(Double(p[safe: 0] ?? "0") ?? 0) / 255
            let g = CGFloat(Double(p[safe: 1] ?? "0") ?? 0) / 255
            let b = CGFloat(Double(p[safe: 2] ?? "0") ?? 0) / 255
            let a = CGFloat(Double(p[safe: 3] ?? "1") ?? 1)
            self.init(red: r, green: g, blue: b, alpha: a)
            return
        }
        var hs = s
        if hs.hasPrefix("#") { hs.removeFirst() }
        var int: UInt64 = 0
        Scanner(string: hs).scanHexInt64(&int)
        let r, g, b, a: UInt64
        if hs.count == 8 {
            (r, g, b, a) = (int >> 24 & 0xFF, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        } else {
            (r, g, b, a) = (int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF, 255)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension Color {
    init(ryHex hex: String) { self.init(uiColor: UIColor(ryHex: hex)) }
}

enum RyColor {
    /// Build an adaptive colour from a light + dark hex.
    private static func dyn(_ light: String, _ dark: String) -> Color {
        Color(uiColor: UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(ryHex: dark) : UIColor(ryHex: light)
        })
    }

    // Surfaces
    static let bgDefault        = dyn("#F5F5F5", "#2C2C2B")
    static let bgPaper          = dyn("#FFFFFF", "#393838")
    static let bgSubtle         = dyn("#F1F3F5", "#343A40")
    static let primaryBackground = dyn("#E3ECEB", "#151A19")
    static let bandHighlight    = dyn("#E3ECEB", "#3F4D46")

    // Primary (Resurs green)
    static let primaryLight     = dyn("#3B817A", "#C0DED4")
    static let primaryMain      = dyn("#117069", "#ABD3C6")
    static let primaryDark      = dyn("#0C5D57", "#93B6AF")
    static let primaryContrast  = dyn("#FFFFFF", "#000000")

    static let secondaryMain    = dyn("#2C2C2B", "#F7F0EB")

    // Status
    static let successMain      = dyn("#1D664D", "#80D0AA")
    static let successBackground = dyn("#B0E2C7", "#082720")
    static let infoMain         = dyn("#0069A8", "#74D4FF")
    static let infoBackground   = dyn("#B8E6FE", "#052F4A")
    static let warningMain      = dyn("#BB4D00", "#FFD230")
    static let warningBackground = dyn("#FEE685", "#461901")
    // Flex (amber) — built like info/success: deep low-saturation background, pale accent
    static let flexMain         = dyn("#B45309", "#FFC47A")
    static let flexBackground   = dyn("#FDD1A3", "#4D2E00")
    static let errorMain        = dyn("#C10007", "#FFA2A2")
    static let errorBackground  = dyn("#FFE2E2", "#460809")

    // Foreground
    static let fgPrimary        = dyn("#0A0A0A", "#FFFFFF")
    static let fgSecondary      = dyn("#525252", "#D4D4D4")
    static let fgDisabled       = dyn("#737373", "#A1A1A1")

    // Borders
    static let borderSubtle     = dyn("rgba(212, 212, 212, 0.6)", "rgba(115, 115, 115, 0.3)")
    static let borderDefault    = dyn("#A1A1A1", "#D4D4D4")

    // Accents
    static let cashbackBg       = dyn("#FEE685", "#FFB900")
    static let chipGreenBg      = Color(ryHex: "#E3ECEB")
    static let chipGreenText    = Color(ryHex: "#0C5D57")

    // Brand scale (mode-independent)
    static let green50  = Color(ryHex: "#E3ECEB")
    static let green100 = Color(ryHex: "#C7DAD7")
    static let green700 = Color(ryHex: "#117069")
    static let mint300  = Color(ryHex: "#ABD3C6")
    static let yellow   = Color(ryHex: "#FFEC89")

    /// The header gradient's top colour (green100 in light; deeper green in dark).
    static let headerWashTop = dyn("#C7DAD7", "#3F4D46")
}

private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

enum RyRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 10
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let pill: CGFloat = 999
}

enum RySpace {
    static let s1: CGFloat = 4
    static let s2: CGFloat = 8
    static let s3: CGFloat = 12
    static let s4: CGFloat = 16
    static let s5: CGFloat = 20
    static let s6: CGFloat = 24
    static let s8: CGFloat = 32
}
