import SwiftData
import SwiftUI

/// Lokaler Entwurf; erst „Sichern" schreibt in das Modell.
struct SongDraft: Equatable {
    var title = ""
    var memo = ""
    var pitches: [Int] = []
    /// Neu gescannte Seiten (JPEG), noch nicht gespeichert.
    var newScans: [Data] = []
    /// Bestehende Seiten, die beim Sichern gelöscht werden.
    var removedPageIDs: Set<UUID> = []
}

struct SongEditView: View {
    /// `nil` = neues Lied anlegen.
    let song: Song?

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(TonePlayer.self) private var tonePlayer

    @State private var draft: SongDraft
    @State private var pickerTarget: PickerTarget?
    @State private var showScanner = false
    @State private var showPitchTap = false
    @State private var tappedPitches: [Int]?
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

    private var keptPages: [ScorePage] {
        (song?.sortedScorePages ?? []).filter { !draft.removedPageIDs.contains($0.id) }
    }

    /// Alle Seiten, die nach dem Sichern zum Lied gehören (bestehende und neu gescannte).
    private var allPageData: [Data] {
        keptPages.map(\.imageData) + draft.newScans
    }

    var body: some View {
        Form {
            Section("Titel") {
                TextField("Titel", text: $draft.title)
                    .font(Theme.serif(.title3, weight: .semibold))
            }
            .listRowBackground(Theme.card)

            Section("Notiz") {
                TextField("z. B. Tenor beginnt", text: $draft.memo, axis: .vertical)
                    .onChange(of: draft.memo) { _, newValue in
                        if newValue.count > Self.memoLimit {
                            draft.memo = String(newValue.prefix(Self.memoLimit))
                        }
                    }
            }
            .listRowBackground(Theme.card)

            pitchSection
            scoreSection
        }
        .paperBackground()
        .navigationTitle(song == nil ? "Neues Lied" : "Lied bearbeiten")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Abbrechen") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Sichern", action: save)
                    .fontWeight(.semibold)
                    .disabled(validationError != nil)
            }
        }
        .sheet(item: $pickerTarget) { target in
            PitchPicker(initialMidi: target.initialMidi) { midi in
                apply(midi, to: target)
            }
        }
        .fullScreenCover(isPresented: $showScanner) {
            DocumentScanner(
                onFinish: { images in
                    draft.newScans += images.compactMap(ImageCompressor.jpegData(from:))
                    showScanner = false
                },
                onCancel: { showScanner = false }
            )
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showPitchTap) {
            PitchTapView(pages: allPageData, maxCount: Song.maxPitches) { pitches in
                receiveTapped(pitches)
            }
        }
        .confirmationDialog(
            "Erkannte Töne übernehmen",
            isPresented: Binding(get: { tappedPitches != nil }, set: { if !$0 { tappedPitches = nil } }),
            titleVisibility: .visible,
            presenting: tappedPitches
        ) { pitches in
            Button("Bisherige Töne ersetzen") { draft.pitches = Array(pitches.prefix(Song.maxPitches)) }
            Button("Hinten anhängen") {
                draft.pitches = Array((draft.pitches + pitches).prefix(Song.maxPitches))
            }
        } message: { pitches in
            Text("\(NoteName.names(pitches)) – das Lied hat schon \(draft.pitches.count) Töne.")
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

    // MARK: Abschnitte

    private var pitchSection: some View {
        Section {
            ForEach(Array(draft.pitches.enumerated()), id: \.offset) { index, midi in
                Button {
                    pickerTarget = .edit(index: index, midi: midi)
                } label: {
                    HStack {
                        Text("\(index + 1).")
                            .monospacedDigit()
                            .foregroundStyle(Theme.gold)
                        Text(NoteName.name(midi: midi))
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .foregroundStyle(Theme.ink)
                        Spacer()
                        Image(systemName: "pencil")
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
            }
            .onMove { draft.pitches.move(fromOffsets: $0, toOffset: $1) }
            .onDelete { draft.pitches.remove(atOffsets: $0) }

            Button {
                pickerTarget = .add(midi: draft.pitches.last ?? Self.defaultPitch)
            } label: {
                Label("Ton hinzufügen", systemImage: "plus.circle.fill")
            }
            .disabled(draft.pitches.count >= Song.maxPitches)
        } header: {
            HStack {
                Text("Anfangstöne")
                Spacer()
                PlayButton(pitches: draft.pitches, sourceID: "edit")
            }
        } footer: {
            if let validationError {
                Text(validationError.message)
            } else {
                Text("Tippen zum Ändern, Wischen zum Löschen. Halten und ziehen zum Umsortieren.")
            }
        }
        .listRowBackground(Theme.card)
    }

    private var scoreSection: some View {
        Section {
            if !keptPages.isEmpty || !draft.newScans.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(keptPages) { page in
                            pageThumbnail(data: page.imageData) {
                                draft.removedPageIDs.insert(page.id)
                            }
                        }
                        ForEach(Array(draft.newScans.enumerated()), id: \.offset) { index, data in
                            pageThumbnail(data: data) {
                                draft.newScans.remove(at: index)
                            }
                        }
                    }
                    .padding(.vertical, 6)
                }
            }
            if !allPageData.isEmpty {
                Button {
                    showPitchTap = true
                } label: {
                    Label("Töne im Scan antippen", systemImage: "hand.tap")
                }
            }
            if DocumentScanner.isAvailable {
                Button {
                    showScanner = true
                } label: {
                    Label("Noten scannen", systemImage: "doc.viewfinder")
                }
            } else {
                Text("Der Scanner ist auf diesem Gerät nicht verfügbar.")
                    .font(.footnote)
                    .foregroundStyle(Theme.inkSecondary)
            }
        } header: {
            Text("Noten")
        } footer: {
            Text(
                "Neue Seiten kommen ans Ende. Mit „Töne im Scan antippen“ übernimmst du "
                    + "Anfangstöne direkt aus den Noten."
            )
        }
        .listRowBackground(Theme.card)
    }

    private func pageThumbnail(data: Data, onDelete: @escaping () -> Void) -> some View {
        ScoreThumbnail(data: data, height: 130)
            .frame(width: 96)
            .overlay(alignment: .topTrailing) {
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title3)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Theme.bordeaux)
                }
                .buttonStyle(.borderless)
                .offset(x: 6, y: -6)
                .accessibilityLabel("Seite entfernen")
            }
    }

    // MARK: Aktionen

    private func receiveTapped(_ pitches: [Int]) {
        guard !pitches.isEmpty else { return }
        if draft.pitches.isEmpty {
            draft.pitches = Array(pitches.prefix(Song.maxPitches))
        } else {
            tappedPitches = pitches
        }
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
        let target: Song
        if let song {
            song.title = title
            song.memo = draft.memo
            song.pitches = draft.pitches
            target = song
        } else {
            target = Song(title: title, memo: draft.memo, pitches: draft.pitches)
            context.insert(target)
        }
        for page in target.sortedScorePages where draft.removedPageIDs.contains(page.id) {
            context.delete(page)
        }
        for data in draft.newScans {
            target.addScorePage(data, in: context)
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
