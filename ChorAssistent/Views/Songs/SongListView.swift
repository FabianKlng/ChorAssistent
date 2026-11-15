import SwiftData
import SwiftUI

struct SongListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Song.title) private var songs: [Song]

    @State private var searchText = ""
    @State private var showNewSong = false
    @State private var songToDelete: Song?
    @State private var errorMessage: String?

    private var filteredSongs: [Song] {
        guard !searchText.isEmpty else { return songs }
        return songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        List {
            ForEach(filteredSongs) { song in
                NavigationLink {
                    SongDetailView(song: song)
                } label: {
                    SongRowContent(song: song)
                        .padding(.vertical, 4)
                }
                .listRowBackground(Theme.card)
            }
            .onDelete { offsets in
                songToDelete = offsets.first.map { filteredSongs[$0] }
            }
        }
        .paperBackground()
        .overlay {
            if songs.isEmpty {
                ContentUnavailableView(
                    "Noch keine Lieder",
                    systemImage: "music.note",
                    description: Text("Tippe auf +, um ein Lied mit seinen Anfangstönen anzulegen.")
                )
            }
        }
        .navigationTitle("Lieder")
        .searchable(text: $searchText, prompt: "Titel suchen")
        .toolbar {
            Button {
                showNewSong = true
            } label: {
                Label("Neues Lied", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showNewSong) {
            NavigationStack {
                SongEditView(song: nil)
            }
        }
        .confirmationDialog(
            "„\(songToDelete?.title ?? "")“ löschen?",
            isPresented: Binding(get: { songToDelete != nil }, set: { if !$0 { songToDelete = nil } }),
            titleVisibility: .visible,
            presenting: songToDelete
        ) { song in
            Button("Löschen", role: .destructive) {
                do {
                    try LibraryActions.delete(song: song, in: context)
                } catch {
                    errorMessage = "Löschen fehlgeschlagen: \(error.localizedDescription)"
                }
            }
        } message: { song in
            let count = LibraryActions.concertCount(for: song)
            Text("Es kommt in \(count) Konzerten vor. Auch die Noten werden gelöscht.")
        }
        .alert(
            "Fehler",
            isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

/// Inhalt einer Liederzeile: Titel, Ton-Chips, Notiz, Hinweis auf Noten, Abspielknopf.
struct SongRowContent: View {
    let song: Song

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(song.title)
                        .font(Theme.serif(.headline, weight: .semibold))
                        .foregroundStyle(Theme.ink)
                    if !song.scorePages.isEmpty {
                        Image(systemName: "doc.richtext")
                            .font(.caption)
                            .foregroundStyle(Theme.gold)
                            .accessibilityLabel("Mit Noten")
                    }
                }
                ToneChips(pitches: song.pitches)
                if !song.memo.isEmpty {
                    Text(song.memo)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(Theme.inkSecondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 0)
            PlayButton(pitches: song.pitches, sourceID: song.id.uuidString)
        }
    }
}
