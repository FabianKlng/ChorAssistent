import SwiftUI

enum SignatureStatus {
    static let warningThreshold = 2

    static func text(days: Int) -> String {
        switch days {
        case 0:
            return "Signatur läuft heute ab – vor dem nächsten Konzert neu installieren"
        case 1:
            return "Signatur läuft in 1 Tag ab – vor dem nächsten Konzert neu installieren"
        default:
            return "Signatur gültig: noch \(days) Tage"
        }
    }
}

/// Zeile oben im Reiter „Konzerte". Leer, wenn das Datum unbekannt ist.
struct SignatureStatusView: View {
    @Environment(\.signatureExpiry) private var signatureExpiry

    var body: some View {
        if let signatureExpiry {
            let days = ProvisioningInfo.daysRemaining(until: signatureExpiry, now: .now)
            let isWarning = days < SignatureStatus.warningThreshold
            Label(
                SignatureStatus.text(days: days),
                systemImage: isWarning ? "exclamationmark.triangle.fill" : "checkmark.seal"
            )
            .font(.subheadline)
            .foregroundStyle(isWarning ? .red : .secondary)
        }
    }
}

private struct SignatureExpiryKey: EnvironmentKey {
    static let defaultValue: Date? = nil
}

extension EnvironmentValues {
    /// Wird einmal beim App-Start gelesen und in die Umgebung gegeben.
    var signatureExpiry: Date? {
        get { self[SignatureExpiryKey.self] }
        set { self[SignatureExpiryKey.self] = newValue }
    }
}
