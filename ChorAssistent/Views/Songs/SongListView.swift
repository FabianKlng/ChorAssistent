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
                    SongEditView(song: song)
                } label: {
                    SongRow(song: song)
                }
            }
            .onDelete { offsets in
                songToDelete = offsets.first.map { filteredSongs[$0] }
            }
        }
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
            Text("Es kommt in \(LibraryActions.concertCount(for: song)) Konzerten vor.")
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

private struct SongRow: View {
    let song: Song

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(song.title)
                Text(NoteName.names(song.pitches))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            PlayButton(pitches: song.pitches, sourceID: song.id.uuidString)
        }
    }
}
