import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.modelContext) private var context
    @Environment(TonePlayer.self) private var tonePlayer

    @AppStorage(PlaybackSettings.toneDurationKey) private var toneDuration = PlaybackSettings.defaultToneDuration
    @AppStorage(PlaybackSettings.gapKey) private var gap = PlaybackSettings.defaultGap

    @Query private var songs: [Song]
    @Query private var concerts: [Concert]

    @State private var exportURL: URL?
    @State private var showImporter = false
    @State private var pendingImport: BackupFile?
    @State private var hasSafetyBackup = false
    @State private var errorMessage: String?
    @State private var infoMessage: String?

    var body: some View {
        Form {
            playbackSection
            backupSection
            infoSection
        }
        .paperBackground()
        .navigationTitle("Einstellungen")
        .onAppear { hasSafetyBackup = BackupService.hasSafetyBackup() }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                do {
                    pendingImport = try BackupService.load(from: url)
                } catch {
                    errorMessage = error.localizedDescription
                }
            case .failure(let error):
                errorMessage = error.localizedDescription
            }
        }
        .confirmationDialog(
            "Bibliothek ersetzen?",
            isPresented: Binding(get: { pendingImport != nil }, set: { if !$0 { pendingImport = nil } }),
            titleVisibility: .visible,
            presenting: pendingImport
        ) { file in
            Button("Ersetzen", role: .destructive) { runImport(file) }
        } message: { file in
            Text(importMessage(for: file))
        }
        .alert(
            "Fehler",
            isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
        .alert(
            "Erledigt",
            isPresented: Binding(get: { infoMessage != nil }, set: { if !$0 { infoMessage = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(infoMessage ?? "")
        }
    }

    // MARK: Abschnitte

    private var playbackSection: some View {
        Section("Wiedergabe") {
            VStack(alignment: .leading) {
                LabeledContent("Tondauer", value: secondsText(toneDuration, digits: 1))
                Slider(
                    value: $toneDuration,
                    in: PlaybackSettings.toneDurationRange,
                    step: PlaybackSettings.toneDurationStep)
            }
            VStack(alignment: .leading) {
                LabeledContent("Pause", value: secondsText(gap, digits: 2))
                Slider(value: $gap, in: PlaybackSettings.gapRange, step: PlaybackSettings.gapStep)
            }
            Button {
                tonePlayer.play([60, 64, 67], sourceID: "hoerprobe")
            } label: {
                Label("Hörprobe", systemImage: "play.fill")
            }
        }
        .listRowBackground(Theme.card)
    }

    private var backupSection: some View {
        Section {
            Button {
                createExport()
            } label: {
                Label("Sicherung erstellen", systemImage: "doc.badge.plus")
            }
            if let exportURL {
                ShareLink(item: exportURL) {
                    Label("Sicherung teilen", systemImage: "square.and.arrow.up")
                }
            }
            Button {
                showImporter = true
            } label: {
                Label("Importieren", systemImage: "square.and.arrow.down")
            }
            Button {
                undoImport()
            } label: {
                Label("Letzten Import rückgängig machen", systemImage: "arrow.uturn.backward")
            }
            .disabled(!hasSafetyBackup)
        } header: {
            Text("Sicherung")
        } footer: {
            Text(
                "Die Sicherung enthält alle Lieder, Konzerte und Noten. Ein Import ersetzt die gesamte Bibliothek; "
                    + "vorher wird automatisch eine Sicherung angelegt.")
        }
        .listRowBackground(Theme.card)
    }

    private var infoSection: some View {
        Section("Info") {
            LabeledContent("Version", value: appVersion)
            NavigationLink("Lizenzen") {
                LicensesView()
            }
        }
        .listRowBackground(Theme.card)
    }

    // MARK: Aktionen

    private func createExport() {
        do {
            exportURL = try BackupService.writeExport(context: context)
        } catch {
            errorMessage = "Sicherung fehlgeschlagen: \(error.localizedDescription)"
        }
    }

    private func runImport(_ file: BackupFile) {
        do {
            try BackupService.importReplacing(file, context: context)
            hasSafetyBackup = BackupService.hasSafetyBackup()
            infoMessage = "Bibliothek ersetzt: \(file.songs.count) Lieder, \(file.concerts.count) Konzerte."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func undoImport() {
        do {
            try BackupService.undoLastImport(context: context)
            hasSafetyBackup = BackupService.hasSafetyBackup()
            infoMessage = "Der letzte Import wurde rückgängig gemacht."
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: Texte

    private func importMessage(for file: BackupFile) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd.MM.yyyy"
        return "Die Datei vom \(formatter.string(from: file.exportedAt)) enthält \(file.songs.count) Lieder "
            + "und \(file.concerts.count) Konzerte. Deine aktuelle Bibliothek mit \(songs.count) Liedern "
            + "und \(concerts.count) Konzerten wird ersetzt."
    }

    private func secondsText(_ value: Double, digits: Int) -> String {
        value.formatted(.number.precision(.fractionLength(digits)).locale(Locale(identifier: "de_DE"))) + " s"
    }

    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "–"
    }
}

private struct LicensesView: View {
    private var text: String {
        guard let url = Bundle.main.url(forResource: "ThirdPartyLicenses", withExtension: "txt"),
            let content = try? String(contentsOf: url, encoding: .utf8)
        else {
            return "Lizenzdatei nicht gefunden."
        }
        return content
    }

    var body: some View {
        ScrollView {
            Text(text)
                .font(.footnote.monospaced())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background(Theme.paper)
        .navigationTitle("Lizenzen")
    }
}
