import SwiftUI
import CoreText

// Inter typography for the Resurs design system. The fonts are bundled under
// Resources/Fonts and registered at runtime (no Info.plist / project edits),
// mirroring the design's ryFont(weight) mapping: weight >= 800 -> ExtraBold,
// >= 600 -> Bold, else Regular.

enum RyFont {
    static let regular = "Inter-Regular"
    static let bold = "Inter-Bold"
    static let extraBold = "Inter-ExtraBold"

    static func face(_ weight: Int) -> String {
        if weight >= 800 { return extraBold }
        if weight >= 600 { return bold }
        return regular
    }

    private static var didRegister = false

    /// Register the bundled Inter fonts once at launch.
    static func registerFonts() {
        guard !didRegister else { return }
        didRegister = true
        for name in ["Inter-Regular", "Inter-Bold", "Inter-ExtraBold"] {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else { continue }
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

extension Font {
    /// Inter at an explicit size + design weight (400/500/700/900).
    static func ry(_ size: CGFloat, _ weight: Int = 400) -> Font {
        .custom(RyFont.face(weight), size: size)
    }
}

// Type scale — from the design tokens.
extension Font {
    static let ryH1 = Font.ry(36, 700)
    static let ryH2 = Font.ry(32, 700)
    static let ryH3 = Font.ry(28, 700)
    static let ryH4 = Font.ry(24, 700)
    static let ryH6 = Font.ry(20, 700)
    static let rySubtitle1 = Font.ry(16, 700)
    static let rySubtitle2 = Font.ry(14, 700)
    static let ryBody1 = Font.ry(16, 400)
    static let ryBody2 = Font.ry(14, 400)
    static let ryButton = Font.ry(14, 700)
    static let ryCaption = Font.ry(12, 400)
    static let ryOverline = Font.ry(11, 400)
}
