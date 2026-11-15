import SwiftUI
import UIKit

/// Vollbild-Konzertmodus im Bühnen-Look: dunkel, goldener Abspielknopf,
/// drei große Bedienelemente, keine Wischgesten.
struct ConcertPlayerView: View {
    let concert: Concert

    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(TonePlayer.self) private var tonePlayer

    @State private var currentIndex = 0
    @State private var routeMonitor = AudioRouteMonitor()
    @State private var showJumpList = false
    @State private var confirmExit = false

    var body: some View {
        // Live gelesen, kein Schnappschuss.
        let entries = concert.orderedEntries
        let index = min(currentIndex, max(entries.count - 1, 0))
        let current = entries.indices.contains(index) ? entries[index].song : nil
        let next = entries.indices.contains(index + 1) ? entries[index + 1].song : nil

        GeometryReader { geometry in
            VStack(spacing: 18) {
                header(index: index, count: entries.count)

                if routeMonitor.isVolumeLow {
                    Label("Lautstärke niedrig", systemImage: "speaker.wave.1.fill")
                        .font(.headline)
                        .foregroundStyle(Theme.stage)
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Theme.stageGold, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                VStack(spacing: 12) {
                    Text(current?.title ?? "")
                        .font(Theme.serif(.largeTitle, weight: .bold))
                        .foregroundStyle(Theme.stageText)
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.6)
                        .lineLimit(3)
                        .id(index)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                    ToneChips(pitches: current?.pitches ?? [], style: .stage)
                    if let memo = current?.memo, !memo.isEmpty {
                        Text(memo)
                            .font(Theme.serif(.body))
                            .italic()
                            .foregroundStyle(Theme.stageSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .animation(.easeInOut(duration: 0.25), value: index)

                Spacer(minLength: 0)

                PlayButton(pitches: current?.pitches ?? [], sourceID: "concert-\(index)", size: .stage)
                    .frame(maxHeight: geometry.size.height * 0.42)

                HStack(spacing: 14) {
                    navigationButton("Zurück", systemImage: "chevron.left", target: index - 1, count: entries.count)
                    navigationButton("Weiter", systemImage: "chevron.right", target: index + 1, count: entries.count)
                }

                Text(next.map { "Als Nächstes: \($0.title)" } ?? "Letztes Lied")
                    .font(Theme.serif(.footnote))
                    .foregroundStyle(Theme.stageSecondary)
            }
            .padding()
        }
        .background {
            ZStack {
                Theme.stage
                StaffLines()
                    .stroke(Theme.stageGold.opacity(0.08), lineWidth: 1)
                    .frame(height: 120)
                    .offset(y: -140)
            }
            .ignoresSafeArea()
        }
        .preferredColorScheme(.dark)
        .tint(Theme.stageGold)
        .audioErrorBanner()
        .confirmationDialog("Konzertmodus beenden?", isPresented: $confirmExit, titleVisibility: .visible) {
            Button("Beenden", role: .destructive) { dismiss() }
        }
        .sheet(isPresented: $showJumpList) {
            jumpList(entries: entries, currentIndex: index)
        }
        // Die einzige Stelle, die die Bildschirmsperre steuert.
        .onChange(of: scenePhase, initial: true) { _, phase in
            UIApplication.shared.isIdleTimerDisabled = (phase == .active)
        }
        .onAppear { routeMonitor.start() }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            routeMonitor.stop()
            tonePlayer.stop()
        }
    }

    private func header(index: Int, count: Int) -> some View {
        HStack {
            Button("Beenden") { confirmExit = true }
                .foregroundStyle(Theme.stageSecondary)
            Spacer()
            Button {
                showJumpList = true
            } label: {
                HStack(spacing: 4) {
                    Text("Lied \(index + 1) von \(count)")
                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                }
                .font(Theme.serif(.headline, weight: .semibold))
                .foregroundStyle(Theme.stageGold)
            }
            Spacer()
            Label(routeMonitor.outputName, systemImage: "speaker.wave.2.fill")
                .font(.caption)
                .foregroundStyle(Theme.stageSecondary)
                .labelStyle(.iconOnly)
                .accessibilityLabel("Ausgabe: \(routeMonitor.outputName)")
        }
    }

    private func navigationButton(_ title: String, systemImage: String, target: Int, count: Int) -> some View {
        let enabled = target >= 0 && target < count
        return Button {
            go(to: target, count: count)
        } label: {
            Label(title, systemImage: systemImage)
                .font(Theme.serif(.title3, weight: .semibold))
                .foregroundStyle(Theme.stageText)
                .frame(maxWidth: .infinity, minHeight: 80)
                .background(Theme.stageCard, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Theme.stageGold.opacity(0.25), lineWidth: 1)
                )
        }
        .buttonStyle(PressableStyle())
        .disabled(!enabled)
        .opacity(enabled ? 1 : 0.35)
    }

    private func jumpList(entries: [ConcertEntry], currentIndex: Int) -> some View {
        NavigationStack {
            List(Array(entries.enumerated()), id: \.element.id) { index, entry in
                Button {
                    go(to: index, count: entries.count)
                    showJumpList = false
                } label: {
                    HStack(spacing: 12) {
                        Text("\(index + 1)")
                            .font(Theme.serif(.headline, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(Theme.stageGold)
                            .frame(width: 28)
                        Text(entry.song?.title ?? "")
                            .font(Theme.serif(.body))
                            .foregroundStyle(Theme.stageText)
                        Spacer()
                        if index == currentIndex {
                            Image(systemName: "speaker.wave.2.fill")
                                .foregroundStyle(Theme.stageGold)
                        }
                    }
                }
                .listRowBackground(Theme.stageCard)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.stage)
            .navigationTitle("Zu Lied springen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { showJumpList = false }
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private func go(to target: Int, count: Int) {
        guard target >= 0, target < count else { return }
        tonePlayer.stop()
        withAnimation {
            currentIndex = target
        }
    }
}
