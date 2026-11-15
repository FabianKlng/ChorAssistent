import SwiftData
import SwiftUI

struct ConcertListView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.signatureExpiry) private var signatureExpiry
    @Query(sort: \Concert.createdAt, order: .reverse) private var concerts: [Concert]

    @State private var showNewConcert = false
    @State private var newName = ""
    @State private var concertToDelete: Concert?

    /// Mit Datum zuerst (chronologisch), danach ohne Datum (neueste zuerst).
    private var sortedConcerts: [Concert] {
        let dated = concerts.filter { $0.date != nil }.sorted { ($0.date ?? .distantPast) < ($1.date ?? .distantPast) }
        let undated = concerts.filter { $0.date == nil }
        return dated + undated
    }

    var body: some View {
        List {
            if signatureExpiry != nil {
                Section {
                    SignatureStatusView()
                }
                .listRowBackground(Theme.card)
            }

            Section {
                ForEach(sortedConcerts) { concert in
                    NavigationLink {
                        ConcertEditView(concert: concert)
                    } label: {
                        ConcertRow(concert: concert)
                    }
                }
                .onDelete { offsets in
                    let list = sortedConcerts
                    concertToDelete = offsets.first.map { list[$0] }
                }
            }
            .listRowBackground(Theme.card)
        }
        .paperBackground()
        .overlay {
            if concerts.isEmpty {
                ContentUnavailableView(
                    "Noch keine Konzerte",
                    systemImage: "music.mic",
                    description: Text("Tippe auf +, um eine Liedfolge für einen Auftritt anzulegen.")
                )
            }
        }
        .navigationTitle("Konzerte")
        .toolbar {
            Button {
                newName = ""
                showNewConcert = true
            } label: {
                Label("Neues Konzert", systemImage: "plus")
            }
        }
        .alert("Neues Konzert", isPresented: $showNewConcert) {
            TextField("Name", text: $newName)
            Button("Anlegen", action: createConcert)
            Button("Abbrechen", role: .cancel) {}
        }
        .confirmationDialog(
            "„\(concertToDelete?.name ?? "")“ löschen?",
            isPresented: Binding(get: { concertToDelete != nil }, set: { if !$0 { concertToDelete = nil } }),
            titleVisibility: .visible,
            presenting: concertToDelete
        ) { concert in
            Button("Löschen", role: .destructive) {
                context.delete(concert)
                try? context.save()
            }
        } message: { _ in
            Text("Die Lieder selbst bleiben in der Bibliothek.")
        }
    }

    private func createConcert() {
        let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        context.insert(Concert(name: name.isEmpty ? "Neues Konzert" : name))
        try? context.save()
    }
}

private struct ConcertRow: View {
    let concert: Concert

    var body: some View {
        HStack(spacing: 14) {
            VStack(spacing: 0) {
                if let date = concert.date {
                    Text(date.formatted(.dateTime.day()))
                        .font(Theme.serif(.title2, weight: .bold))
                    Text(date.formatted(.dateTime.month(.abbreviated).locale(Locale(identifier: "de_DE"))))
                        .font(.caption2.weight(.semibold))
                        .textCase(.uppercase)
                } else {
                    Image(systemName: "music.mic")
                        .font(.title3)
                }
            }
            .foregroundStyle(Theme.bordeaux)
            .frame(width: 48, height: 52)
            .background(Theme.bordeaux.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(concert.name)
                    .font(Theme.serif(.headline, weight: .semibold))
                    .foregroundStyle(Theme.ink)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(Theme.inkSecondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var subtitle: String {
        let count = "\(concert.orderedEntries.count) Lieder"
        guard let date = concert.date else { return count }
        return "\(Theme.shortDate(date)) · \(count)"
    }
}
