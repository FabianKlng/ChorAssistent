import SwiftData
import SwiftUI

/// Lokaler Entwurf; erst „Sichern" schreibt in das Modell.
struct SongDraft: Equatable {
    var title = ""
    var memo = ""
    var pitches: [Int] = []
}

struct SongEditView: View {
    /// `nil` = neues Lied anlegen.
    let song: Song?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(TonePlayer.self) private var tonePlayer

    @State private var draft: SongDraft
    @State private var pickerTarget: PickerTarget?
    @State private var errorMessage: String?

    static let memoLimit = 200
    static let defaultPitch = 69  // A4

    init(song: Song?) {
        self.song = song
        _draft = State(
            initialValue: song.map { SongDraft(title: $0.title, memo: $0.memo, pitches: $0.pitches) } ?? SongDraft())
    }

    private var validationError: SongValidationError? {
        Song.validate(title: draft.title, pitches: draft.pitches)
    }

    var body: some View {
        Form {
            Section("Titel") {
                TextField("Titel", text: $draft.title)
            }
            Section("Notiz") {
                TextField("z. B. Tenor beginnt", text: $draft.memo, axis: .vertical)
                    .onChange(of: draft.memo) { _, newValue in
                        if newValue.count > Self.memoLimit {
                            draft.memo = String(newValue.prefix(Self.memoLimit))
                        }
                    }
            }
            Section {
                ForEach(Array(draft.pitches.enumerated()), id: \.offset) { index, midi in
                    Button {
                        pickerTarget = .edit(index: index, midi: midi)
                    } label: {
                        Text(NoteName.name(midi: midi))
                            .foregroundStyle(.primary)
                    }
                }
                .onMove { draft.pitches.move(fromOffsets: $0, toOffset: $1) }
                .onDelete { draft.pitches.remove(atOffsets: $0) }

                Button {
                    pickerTarget = .add(midi: draft.pitches.last ?? Self.defaultPitch)
                } label: {
                    Label("Ton hinzufügen", systemImage: "plus")
                }
                .disabled(draft.pitches.count >= Song.maxPitches)
            } header: {
                HStack {
                    Text("Töne")
                    Spacer()
                    PlayButton(pitches: draft.pitches, sourceID: "edit")
                }
            } footer: {
                if let validationError {
                    Text(validationError.message)
                }
            }
        }
        .navigationTitle(song == nil ? "Neues Lied" : "Lied bearbeiten")
        .toolbar {
            if song == nil {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Sichern", action: save)
                    .disabled(validationError != nil)
            }
            ToolbarItem(placement: .bottomBar) {
                EditButton()
            }
        }
        .sheet(item: $pickerTarget) { target in
            PitchPicker(initialMidi: target.initialMidi) { midi in
                apply(midi, to: target)
            }
        }
        .alert(
            "Fehler",
            isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .onDisappear { tonePlayer.stop() }
    }

    private func apply(_ midi: Int, to target: PickerTarget) {
        switch target {
        case .add:
            if draft.pitches.count < Song.maxPitches {
                draft.pitches.append(midi)
            }
        case .edit(let index, _):
            if draft.pitches.indices.contains(index) {
                draft.pitches[index] = midi
            }
        }
    }

    private func save() {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let song {
            song.title = title
            song.memo = draft.memo
            song.pitches = draft.pitches
        } else {
            context.insert(Song(title: title, memo: draft.memo, pitches: draft.pitches))
        }
        do {
            try context.save()
            dismiss()
        } catch {
            errorMessage = "Speichern fehlgeschlagen: \(error.localizedDescription)"
        }
    }
}

private enum PickerTarget: Identifiable {
    case add(midi: Int)
    case edit(index: Int, midi: Int)

    var id: String {
        switch self {
        case .add: return "add"
        case .edit(let index, _): return "edit-\(index)"
        }
    }

    var initialMidi: Int {
        switch self {
        case .add(let midi), .edit(_, let midi): return midi
        }
    }
}
