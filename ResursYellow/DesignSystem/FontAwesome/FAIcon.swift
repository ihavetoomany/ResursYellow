import SwiftUI
import UIKit
import CoreText

// Font Awesome Pro 7 (classic family + brands), bundled as TTFs under
// Resources/Fonts and registered at launch like the Inter fonts.
//
// Usage:
//   FAIconView(.piggyBank)                        // solid, inherits font size
//   FAIconView(.piggyBank, style: .light, size: 20)
//   Image(uiImage: FAIcon.piggyBank.uiImage(style: .solid, size: 24))  // tab bars / UIKit
//
// All 4 349 icons are listed in FAIcons.swift (generated). Brand icons pick the
// Brands font automatically regardless of the requested style.

struct FAIcon: Hashable {
    /// Font Awesome icon name, e.g. "piggy-bank".
    let name: String
    /// Private Use Area codepoint as hex, e.g. "f4d3".
    let unicode: String
    /// True for brand logos, which only exist in the Brands font.
    let isBrand: Bool

    init(_ name: String, _ unicode: String, brand: Bool = false) {
        self.name = name
        self.unicode = unicode
        self.isBrand = brand
    }

    /// The glyph as a one-character string, for use in Text / NSAttributedString.
    var glyph: String {
        guard let value = UInt32(unicode, radix: 16), let scalar = UnicodeScalar(value) else { return "" }
        return String(Character(scalar))
    }

    func font(style: FAStyle, size: CGFloat) -> Font {
        .custom(fontName(for: style), size: size)
    }

    func uiFont(style: FAStyle, size: CGFloat) -> UIFont {
        UIFont(name: fontName(for: style), size: size) ?? .systemFont(ofSize: size)
    }

    /// Renders the glyph into a template UIImage (tints like an SF Symbol).
    /// Use for tab bar items and other UIKit image slots.
    func uiImage(style: FAStyle, size: CGFloat) -> UIImage {
        let font = uiFont(style: style, size: size)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        let text = glyph as NSString
        let bounds = text.size(withAttributes: attrs)
        let canvas = CGSize(width: ceil(max(bounds.width, size)), height: ceil(max(bounds.height, size)))
        return UIGraphicsImageRenderer(size: canvas).image { _ in
            let origin = CGPoint(x: (canvas.width - bounds.width) / 2, y: (canvas.height - bounds.height) / 2)
            text.draw(at: origin, withAttributes: attrs)
        }.withRenderingMode(.alwaysTemplate)
    }

    private func fontName(for style: FAStyle) -> String {
        isBrand ? FAStyle.brandsPostScriptName : style.postScriptName
    }
}

/// Classic family weights. Brands is implied by the icon, not chosen here.
enum FAStyle {
    case thin, light, regular, solid

    /// PostScript names of the bundled faces.
    var postScriptName: String {
        switch self {
        case .thin: return "FontAwesome7Pro-Thin"
        case .light: return "FontAwesome7Pro-Light"
        case .regular: return "FontAwesome7Pro-Regular"
        case .solid: return "FontAwesome7Pro-Solid"
        }
    }
    static let brandsPostScriptName = "FontAwesome7Brands-Regular"

    /// Bundled font file names (Resources/Fonts), without extension.
    static let fontFiles = ["fa-thin-100", "fa-light-300", "fa-regular-400", "fa-solid-900", "fa-brands-400"]
}

/// A Font Awesome glyph as a SwiftUI view. Inherits the environment font size
/// when `size` is nil, so it sits naturally inline with text.
struct FAIconView: View {
    let icon: FAIcon
    var style: FAStyle = .solid
    var size: CGFloat? = nil

    init(_ icon: FAIcon, style: FAStyle = .solid, size: CGFloat? = nil) {
        self.icon = icon
        self.style = style
        self.size = size
    }

    var body: some View {
        Text(icon.glyph)
            .font(icon.font(style: style, size: size ?? UIFont.preferredFont(forTextStyle: .body).pointSize))
            .accessibilityLabel(icon.name.replacingOccurrences(of: "-", with: " "))
    }
}

enum FAFonts {
    private static var didRegister = false

    /// Register the bundled Font Awesome faces once at launch.
    static func registerFonts() {
        guard !didRegister else { return }
        didRegister = true
        for name in FAStyle.fontFiles {
            guard let url = Bundle.main.url(forResource: name, withExtension: "ttf") else {
                assertionFailure("Font Awesome file missing from bundle: \(name).ttf")
                continue
            }
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &error) {
                let message = (error?.takeRetainedValue()).map { CFErrorCopyDescription($0) as String } ?? "unknown"
                // Already-registered is fine (e.g. after a hot reload); anything else is worth seeing.
                if !message.contains("already") { print("FontAwesome: failed to register \(name): \(message)") }
            }
        }
    }
}
