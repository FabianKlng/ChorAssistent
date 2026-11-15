import SwiftData
import SwiftUI

@main
struct ChorAssistentApp: App {
    @State private var tonePlayer: TonePlayer
    @Environment(\.scenePhase) private var scenePhase

    private let containerResult: Result<ModelContainer, Error>
    private let signatureExpiry: Date?

    init() {
        PlaybackSettings.registerDefaults()
        Theme.applyAppearance()

        let player = TonePlayer()
        player.setUp()
        _tonePlayer = State(initialValue: player)

        containerResult = Result {
            try ModelContainer(for: Song.self, Concert.self, ConcertEntry.self, ScorePage.self)
        }
        signatureExpiry = ProvisioningInfo.expirationDate()
    }

    var body: some Scene {
        WindowGroup {
            switch containerResult {
            case .success(let container):
                RootTabView()
                    .modelContainer(container)
                    .environment(tonePlayer)
                    .environment(\.signatureExpiry, signatureExpiry)
            case .failure(let error):
                StartupErrorView(message: error.localizedDescription)
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .active:
                tonePlayer.ensureRunning()
            case .background:
                tonePlayer.stop()
            default:
                break
            }
        }
    }
}
