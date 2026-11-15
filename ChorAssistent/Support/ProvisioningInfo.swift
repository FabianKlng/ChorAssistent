import Foundation

/// Liest das Ablaufdatum der Signatur aus `embedded.mobileprovision`.
/// Inoffiziell und nur für die Installation über Xcode; darf nie abstürzen.
enum ProvisioningInfo {
    /// Die Datei ist eine signierte Hülle (binär) mit eingebetteter XML-plist.
    static func expirationDate(fromProfileData data: Data) -> Date? {
        let text = String(decoding: data, as: UTF8.self)
        guard let start = text.range(of: "<?xml"),
            let end = text.range(of: "</plist>", range: start.upperBound..<text.endIndex)
        else {
            return nil
        }
        let plistData = Data(text[start.lowerBound..<end.upperBound].utf8)
        guard let object = try? PropertyListSerialization.propertyList(from: plistData, format: nil),
            let dictionary = object as? [String: Any]
        else {
            return nil
        }
        return dictionary["ExpirationDate"] as? Date
    }

    static func expirationDate(bundle: Bundle = .main) -> Date? {
        guard let url = bundle.url(forResource: "embedded", withExtension: "mobileprovision"),
            let data = try? Data(contentsOf: url)
        else {
            return nil
        }
        return expirationDate(fromProfileData: data)
    }

    static func daysRemaining(until expiry: Date, now: Date) -> Int {
        max(0, Int((expiry.timeIntervalSince(now) / 86_400).rounded(.down)))
    }
}
