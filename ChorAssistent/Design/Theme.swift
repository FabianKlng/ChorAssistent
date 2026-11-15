import SwiftUI
import UIKit

/// Farbpalette „warm & klassisch": Notenpapier, Bordeaux, Gold.
/// Quelle der Wahrheit sind dynamische UIColors (hell/dunkel).
/// Berechnete Eigenschaften statt `static let`, damit kein globaler,
/// nicht-Sendable-Zustand entsteht.
enum Palette {
    static var paper: UIColor { .dynamic(light: 0xF6EFE2, dark: 0x1C1613) }
    static var card: UIColor { .dynamic(light: 0xFFFBF3, dark: 0x2A211C) }
    static var ink: UIColor { .dynamic(light: 0x2B1D16, dark: 0xF3E9D8) }
    static var inkSecondary: UIColor { .dynamic(light: 0x7A6656, dark: 0xB8A794) }
    static var bordeaux: UIColor { .dynamic(light: 0x7B1E2C, dark: 0xD0657A) }
    static var gold: UIColor { .dynamic(light: 0xA9823A, dark: 0xD9B467) }
    static var staffLine: UIColor { .dynamic(light: 0xDCCDB5, dark: 0x4A3C33) }
    static var onAccent: UIColor { .dynamic(light: 0xFFF8EC, dark: 0x1C1613) }
}

enum Theme {
    static let paper = Color(uiColor: Palette.paper)
    static let card = Color(uiColor: Palette.card)
    static let ink = Color(uiColor: Palette.ink)
    static let inkSecondary = Color(uiColor: Palette.inkSecondary)
    static let bordeaux = Color(uiColor: Palette.bordeaux)
    static let gold = Color(uiColor: Palette.gold)
    static let staffLine = Color(uiColor: Palette.staffLine)
    static let onAccent = Color(uiColor: Palette.onAccent)

    // Bühne (Konzertmodus): immer dunkel, blendet im Saal nicht.
    static let stage = Color(uiColor: UIColor(hex: 0x15100E))
    static let stageCard = Color(uiColor: UIColor(hex: 0x261C18))
    static let stageText = Color(uiColor: UIColor(hex: 0xF3E9D8))
    static let stageSecondary = Color(uiColor: UIColor(hex: 0xA8977F))
    static let stageGold = Color(uiColor: UIColor(hex: 0xD9B467))

    static func serif(_ style: Font.TextStyle, weight: Font.Weight = .regular) -> Font {
        .system(style, design: .serif, weight: weight)
    }

    private static let germanLocale = Locale(identifier: "de_DE")

    /// z. B. „Samstag, 20. Dezember 2026"
    static func longDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.wide).day().month(.wide).year().locale(germanLocale))
    }

    /// z. B. „Sa., 20. Dez. 2026"
    static func shortDate(_ date: Date) -> String {
        date.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).year().locale(germanLocale))
    }

    /// Serifenschrift und Papierfarbe für die UIKit-Leisten.
    @MainActor
    static func applyAppearance() {
        let navigation = UINavigationBarAppearance()
        navigation.configureWithOpaqueBackground()
        navigation.backgroundColor = Palette.paper
        navigation.shadowColor = .clear
        navigation.largeTitleTextAttributes = [
            .font: serifFont(.largeTitle, weight: .bold), .foregroundColor: Palette.ink,
        ]
        navigation.titleTextAttributes = [
            .font: serifFont(.headline, weight: .semibold), .foregroundColor: Palette.ink,
        ]
        UINavigationBar.appearance().standardAppearance = navigation
        UINavigationBar.appearance().scrollEdgeAppearance = navigation
        UINavigationBar.appearance().compactAppearance = navigation

        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundColor = Palette.card
        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
    }

    private static func serifFont(_ style: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        let base = UIFont.preferredFont(forTextStyle: style)
        guard let serif = base.fontDescriptor.withDesign(.serif) else { return base }
        let weighted = serif.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight.rawValue]])
        return UIFont(descriptor: weighted, size: base.pointSize)
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }

    static func dynamic(light: UInt32, dark: UInt32) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        }
    }
}
