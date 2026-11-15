import Foundation

/// Globale Wiedergabe-Einstellungen in UserDefaults.
/// Die Oberfläche nutzt `@AppStorage` mit denselben Schlüsseln.
enum PlaybackSettings {
    static let toneDurationKey = "toneDuration"
    static let gapKey = "gap"

    static let defaultToneDuration = 1.0
    static let defaultGap = 0.15

    static let toneDurationRange: ClosedRange<Double> = 0.5...3.0
    static let toneDurationStep = 0.1
    static let gapRange: ClosedRange<Double> = 0.0...1.0
    static let gapStep = 0.05

    /// Muss beim App-Start laufen. Ohne Registrierung liefert
    /// `double(forKey:)` vor der ersten Änderung 0 statt des Standardwerts.
    static func registerDefaults(_ defaults: UserDefaults = .standard) {
        defaults.register(defaults: [
            toneDurationKey: defaultToneDuration,
            gapKey: defaultGap,
        ])
    }

    static func clamp(_ value: Double, to range: ClosedRange<Double>) -> Double {
        min(max(value, range.lowerBound), range.upperBound)
    }

    static func toneDuration(_ defaults: UserDefaults = .standard) -> Double {
        clamp(value(defaults, toneDurationKey, fallback: defaultToneDuration), to: toneDurationRange)
    }

    static func gap(_ defaults: UserDefaults = .standard) -> Double {
        clamp(value(defaults, gapKey, fallback: defaultGap), to: gapRange)
    }

    static var toneDurationMs: Int { Int((toneDuration() * 1000).rounded()) }
    static var gapMs: Int { Int((gap() * 1000).rounded()) }

    static func current(_ defaults: UserDefaults = .standard) -> SettingsDTO {
        SettingsDTO(toneDuration: toneDuration(defaults), gap: gap(defaults))
    }

    /// Übernimmt Werte aus einer Sicherung, auf die zulässigen Bereiche gesetzt.
    /// Fehlt der Block (`nil`), bleiben die aktuellen Werte unverändert.
    static func apply(_ settings: SettingsDTO?, to defaults: UserDefaults = .standard) {
        guard let settings else { return }
        defaults.set(clamp(settings.toneDuration, to: toneDurationRange), forKey: toneDurationKey)
        defaults.set(clamp(settings.gap, to: gapRange), forKey: gapKey)
    }

    private static func value(_ defaults: UserDefaults, _ key: String, fallback: Double) -> Double {
        (defaults.object(forKey: key) as? Double) ?? fallback
    }
}
