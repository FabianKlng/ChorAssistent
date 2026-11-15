import SwiftUI
import UIKit

/// Vollbild-Konzertmodus: drei große Knöpfe, keine Wischgesten.
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
            VStack(spacing: 16) {
                header(index: index, count: entries.count)

                if routeMonitor.isVolumeLow {
                    Label("Lautstärke niedrig", systemImage: "speaker.wave.1.fill")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(8)
                        .background(.yellow, in: RoundedRectangle(cornerRadius: 8))
                }

                VStack(spacing: 8) {
                    Text(current?.title ?? "")
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                    Text(NoteName.names(current?.pitches ?? []))
                        .font(.title)
                    if let memo = current?.memo, !memo.isEmpty {
                        Text(memo)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer(minLength: 0)

                PlayButton(pitches: current?.pitches ?? [], sourceID: "concert-\(index)", size: .large)
                    .frame(maxHeight: geometry.size.height * 0.5)

                HStack(spacing: 16) {
                    navigationButton("Zurück", systemImage: "chevron.left", target: index - 1, count: entries.count)
                    navigationButton("Weiter", systemImage: "chevron.right", target: index + 1, count: entries.count)
                }

                Text(next.map { "Als Nächstes: \($0.title)" } ?? "Letztes Lied")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .audioErrorBanner()
        .confirmationDialog("Konzertmodus beenden?", isPresented: $confirmExit, titleVisibility: .visible) {
            Button("Beenden", role: .destructive) { dismiss() }
        }
        .sheet(isPresented: $showJumpList) {
            jumpList(entries: entries)
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
            Spacer()
            Button {
                showJumpList = true
            } label: {
                Text("Lied \(index + 1) von \(count)")
                    .font(.headline)
            }
            Spacer()
            Label(routeMonitor.outputName, systemImage: "speaker.wave.2")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func navigationButton(_ title: String, systemImage: String, target: Int, count: Int) -> some View {
        Button {
            go(to: target, count: count)
        } label: {
            Label(title, systemImage: systemImage)
                .font(.title2)
                .frame(maxWidth: .infinity, minHeight: 80)
        }
        .buttonStyle(.bordered)
        .disabled(target < 0 || target >= count)
    }

    private func jumpList(entries: [ConcertEntry]) -> some View {
        NavigationStack {
            List(Array(entries.enumerated()), id: \.element.id) { index, entry in
                Button {
                    go(to: index, count: entries.count)
                    showJumpList = false
                } label: {
                    HStack {
                        Text("\(index + 1).")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        Text(entry.song?.title ?? "")
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Zu Lied springen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") { showJumpList = false }
                }
            }
        }
    }

    private func go(to target: Int, count: Int) {
        guard target >= 0, target < count else { return }
        tonePlayer.stop()
        currentIndex = target
    }
}
