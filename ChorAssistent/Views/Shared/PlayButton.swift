import SwiftUI

/// Spielt eine Tonfolge. Zeigt „Neu starten" nur für die Folge, die gerade läuft.
struct PlayButton: View {
    enum Size {
        /// Runder Knopf in Listen.
        case regular
        /// Großer Knopf auf der Detailseite.
        case large
        /// Großer goldener Knopf im Konzertmodus.
        case stage
    }

    let pitches: [Int]
    let sourceID: String
    var size: Size = .regular

    @Environment(TonePlayer.self) private var tonePlayer
    @State private var tapCount = 0

    private var isActive: Bool {
        tonePlayer.isPlaying && tonePlayer.currentSourceID == sourceID
    }

    private var symbol: String { isActive ? "arrow.counterclockwise" : "play.fill" }
    private var title: String { isActive ? "Neu starten" : "Abspielen" }

    var body: some View {
        Group {
            switch size {
            case .regular:
                Button(action: play) {
                    Image(systemName: symbol)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Theme.onAccent)
                        .frame(width: 40, height: 40)
                        .background(isActive ? Theme.gold : Theme.bordeaux, in: Circle())
                        .contentTransition(.symbolEffect(.replace))
                }
                // Eigener Tap-Bereich, auch innerhalb einer Listenzeile mit NavigationLink.
                .buttonStyle(.borderless)
            case .large:
                bigButton(fill: isActive ? Theme.gold : Theme.bordeaux, foreground: Theme.onAccent)
            case .stage:
                bigButton(fill: Theme.stageGold, foreground: Theme.stage)
            }
        }
        .disabled(pitches.isEmpty)
        .opacity(pitches.isEmpty ? 0.4 : 1)
        .accessibilityLabel(title)
        .sensoryFeedback(.impact(weight: .medium), trigger: tapCount)
    }

    private func bigButton(fill: Color, foreground: Color) -> some View {
        Button(action: play) {
            VStack(spacing: 10) {
                Image(systemName: symbol)
                    .font(.system(size: 44, weight: .bold))
                    .contentTransition(.symbolEffect(.replace))
                Text(title)
                    .font(Theme.serif(.title2, weight: .semibold))
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(fill, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
            .shadow(color: fill.opacity(0.35), radius: 14, y: 6)
        }
        .buttonStyle(PressableStyle())
    }

    private func play() {
        tapCount += 1
        tonePlayer.play(pitches, sourceID: sourceID)
    }
}
