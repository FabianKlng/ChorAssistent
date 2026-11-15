import SwiftUI

/// Rotes Banner oben, solange der Ton nicht verfügbar ist.
/// Wird in RootTabView und im Konzertmodus benutzt, weil die Vollbild-Ansicht
/// ein Banner der RootTabView verdecken würde.
struct AudioErrorBanner: ViewModifier {
    @Environment(TonePlayer.self) private var tonePlayer

    func body(content: Content) -> some View {
        content.safeAreaInset(edge: .top) {
            if let error = tonePlayer.lastError {
                Label(error.message, systemImage: "speaker.slash.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(.red)
            }
        }
    }
}

extension View {
    func audioErrorBanner() -> some View {
        modifier(AudioErrorBanner())
    }
}
