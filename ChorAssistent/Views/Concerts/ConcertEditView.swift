import SwiftData
import SwiftUI

struct ConcertEditView: View {
    @Bindable var concert: Concert

    @Environment(\.modelContext) private var context
    @State private var showSongPicker = false
    @State private var showPlayer = false

    var body: some View {
        List {
            Section("Name") {
                TextField("Name", text: $concert.name)
            }
            Section("Lieder") {
                ForEach(Array(concert.orderedEntries.enumerated()), id: \.element.id) { index, entry in
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text("\(index + 1).")
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entry.song?.title ?? "")
                            Text(NoteName.names(entry.song?.pitches ?? []))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onMove { source, destination in
                    concert.move(fromOffsets: source, toOffset: destination)
                    try? context.save()
                }
                .onDelete { offsets in
                    concert.remove(atOffsets: offsets, in: context)
                    try? context.save()
                }

                Button {
                    showSongPicker = true
                } label: {
                    Label("Lied hinzufügen", systemImage: "plus")
                }
            }
        }
        .navigationTitle(concert.name)
        .toolbar { EditButton() }
        .safeAreaInset(edge: .bottom) {
            Button {
                showPlayer = true
            } label: {
                Label("Konzert starten", systemImage: "play.circle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .disabled(concert.orderedEntries.isEmpty)
        }
        .sheet(isPresented: $showSongPicker) {
            SongPickerSheet(concert: concert)
        }
        .fullScreenCover(isPresented: $showPlayer) {
            ConcertPlayerView(concert: concert)
        }
    }
}
