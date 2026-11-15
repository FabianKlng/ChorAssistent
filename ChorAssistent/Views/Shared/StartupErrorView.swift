import SwiftUI

/// Wird statt der App gezeigt, wenn sich die Datenbank nicht öffnen lässt.
struct StartupErrorView: View {
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label("Datenbank konnte nicht geöffnet werden", systemImage: "exclamationmark.triangle")
        } description: {
            Text(message)
        }
    }
}
