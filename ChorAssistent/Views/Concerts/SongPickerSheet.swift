import SwiftData
import SwiftUI

/// Lieder zu einem Konzert hinzufügen. Bleibt offen, damit man mehrere wählen kann.
struct SongPickerSheet: View {
    let concert: Concert

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Song.title) private var songs: [Song]
    @State private var searchText = ""

    private var filteredSongs: [Song] {
        guard !searchText.isEmpty else { return songs }
        return songs.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List(filteredSongs) { song in
                Button {
                    concert.append(song: song, in: context)
                    try? context.save()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(song.title)
                                .foregroundStyle(.primary)
                            Text(NoteName.names(song.pitches))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        let count = occurrences(of: song)
                        if count > 0 {
                            Text("×\(count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Titel suchen")
            .navigationTitle("Lied hinzufügen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") { dismiss() }
                }
            }
        }
    }

    private func occurrences(of song: Song) -> Int {
        concert.orderedEntries.filter { $0.song?.persistentModelID == song.persistentModelID }.count
    }
}
