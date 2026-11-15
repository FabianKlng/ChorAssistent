import SwiftData
import SwiftUI

struct ConcertEditView: View {
    @Bindable var concert: Concert

    @Environment(\.modelContext) private var context
    @State private var showSongPicker = false
    @State private var showPlayer = false

    private var hasDate: Binding<Bool> {
        Binding(
            get: { concert.date != nil },
            set: { concert.date = $0 ? (concert.date ?? Calendar.current.startOfDay(for: .now)) : nil }
        )
    }

    private var dateBinding: Binding<Date> {
        Binding(get: { concert.date ?? .now }, set: { concert.date = $0 })
    }

    var body: some View {
        List {
            Section("Name") {
                TextField("Name", text: $concert.name)
                    .font(Theme.serif(.title3, weight: .semibold))
            }
            .listRowBackground(Theme.card)

            Section("Datum") {
                Toggle("Datum festlegen", isOn: hasDate)
                if concert.date != nil {
                    DatePicker("Datum", selection: dateBinding, displayedComponents: .date)
                        .environment(\.locale, Locale(identifier: "de_DE"))
                }
            }
            .listRowBackground(Theme.card)

            Section {
                ForEach(Array(concert.orderedEntries.enumerated()), id: \.element.id) { index, entry in
                    HStack(alignment: .center, spacing: 12) {
                        Text("\(index + 1)")
                            .font(Theme.serif(.headline, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(Theme.gold)
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.song?.title ?? "")
                                .font(Theme.serif(.body, weight: .semibold))
                                .foregroundStyle(Theme.ink)
                            ToneChips(pitches: entry.song?.pitches ?? [])
                        }
                    }
                    .padding(.vertical, 2)
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
                    Label("Lied hinzufügen", systemImage: "plus.circle.fill")
                }
            } header: {
                Text("Liedfolge")
            } footer: {
                Text("Halten und ziehen zum Umsortieren, Wischen zum Entfernen.")
            }
            .listRowBackground(Theme.card)
        }
        .paperBackground()
        .navigationTitle(concert.name)
        .navigationBarTitleDisplayMode(.inline)
        .safeAreaInset(edge: .bottom) {
            Button {
                showPlayer = true
            } label: {
                Label("Konzert starten", systemImage: "play.fill")
                    .font(Theme.serif(.headline, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 6)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .background(Theme.paper.opacity(0.95))
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
