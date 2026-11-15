import SwiftData
import SwiftUI

struct ConcertListView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Concert.createdAt, order: .reverse) private var concerts: [Concert]

    @State private var showNewConcert = false
    @State private var newName = ""
    @State private var concertToDelete: Concert?

    var body: some View {
        List {
            SignatureStatusView()

            ForEach(concerts) { concert in
                NavigationLink {
                    ConcertEditView(concert: concert)
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(concert.name)
                        Text("\(concert.orderedEntries.count) Lieder")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete { offsets in
                concertToDelete = offsets.first.map { concerts[$0] }
            }
        }
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
