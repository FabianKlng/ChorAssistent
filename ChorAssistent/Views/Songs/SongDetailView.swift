import SwiftData
import SwiftUI

/// Detailseite eines Lieds: Töne, großer Abspielknopf, Notiz und gescannte Noten.
struct SongDetailView: View {
    let song: Song

    @Environment(TonePlayer.self) private var tonePlayer
    @State private var showEdit = false
    @State private var viewerTarget: ViewerTarget?

    private var concertNames: [String] {
        var seen = Set<PersistentIdentifier>()
        var names: [String] = []
        for entry in song.entries where !entry.isDeleted {
            if let concert = entry.concert, seen.insert(concert.persistentModelID).inserted {
                names.append(concert.name)
            }
        }
        return names.sorted()
    }

    var body: some View {
        let pages = song.sortedScorePages
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(song.title)
                        .font(Theme.serif(.largeTitle, weight: .bold))
                        .foregroundStyle(Theme.ink)
                    if !song.memo.isEmpty {
                        Text(song.memo)
                            .font(Theme.serif(.body))
                            .italic()
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }

                ToneChips(pitches: song.pitches, style: .large)

                PlayButton(pitches: song.pitches, sourceID: "detail-\(song.id.uuidString)", size: .large)
                    .frame(height: 130)

                SectionHeader("Noten")
                if pages.isEmpty {
                    HintCard(
                        systemImage: "doc.viewfinder",
                        title: "Noch keine Noten",
                        message: "Über „Bearbeiten“ kannst du die Noten mit der Kamera einscannen."
                    )
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 12)], spacing: 12) {
                        ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                            Button {
                                viewerTarget = ViewerTarget(index: index)
                            } label: {
                                ScoreThumbnail(data: page.imageData)
                                    .overlay(alignment: .bottomTrailing) {
                                        Text("\(index + 1)")
                                            .font(.caption2.bold())
                                            .padding(6)
                                            .background(.ultraThinMaterial, in: Circle())
                                            .padding(6)
                                    }
                            }
                            .buttonStyle(PressableStyle())
                            .accessibilityLabel("Notenseite \(index + 1) öffnen")
                        }
                    }
                }

                if !concertNames.isEmpty {
                    SectionHeader("In Konzerten")
                    Text(concertNames.joined(separator: " · "))
                        .font(Theme.serif(.body))
                        .foregroundStyle(Theme.ink)
                }
            }
            .padding()
        }
        .background(Theme.paper)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button("Bearbeiten") { showEdit = true }
        }
        .sheet(isPresented: $showEdit) {
            NavigationStack {
                SongEditView(song: song)
            }
        }
        .fullScreenCover(item: $viewerTarget) { target in
            ScoreViewer(pages: pages, startIndex: target.index)
        }
        .onDisappear { tonePlayer.stop() }
    }
}

private struct ViewerTarget: Identifiable {
    let index: Int
    var id: Int { index }
}
