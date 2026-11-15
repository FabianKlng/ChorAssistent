import SwiftUI

/// Spielt eine Tonfolge. Zeigt „Neu starten" nur für die Folge, die gerade läuft.
struct PlayButton: View {
    enum Size {
        case regular
        case large
    }

    let pitches: [Int]
    let sourceID: String
    var size: Size = .regular

    @Environment(TonePlayer.self) private var tonePlayer

    private var isActive: Bool {
        tonePlayer.isPlaying && tonePlayer.currentSourceID == sourceID
    }

    private var symbol: String { isActive ? "arrow.counterclockwise" : "play.fill" }

    var body: some View {
        switch size {
        case .regular:
            Button(action: play) {
                Image(systemName: symbol)
                    .font(.title3)
                    .frame(width: 44, height: 44)
            }
            // Eigener Tap-Bereich, auch innerhalb einer Listenzeile mit NavigationLink.
            .buttonStyle(.borderless)
            .disabled(pitches.isEmpty)
            .accessibilityLabel(isActive ? "Neu starten" : "Abspielen")
        case .large:
            Button(action: play) {
                Label(isActive ? "Neu starten" : "Abspielen", systemImage: symbol)
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(pitches.isEmpty)
        }
    }

    private func play() {
        tonePlayer.play(pitches, sourceID: sourceID)
    }
}
