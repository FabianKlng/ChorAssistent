import SwiftUI

struct RootTabView: View {
    @Environment(\.signatureExpiry) private var signatureExpiry
    @State private var didCheckSignature = false
    @State private var signatureWarning: String?

    var body: some View {
        TabView {
            NavigationStack { HomeView() }
                .tabItem { Label("Start", systemImage: "music.note.house") }
            NavigationStack { SongListView() }
                .tabItem { Label("Lieder", systemImage: "music.note.list") }
            NavigationStack { ConcertListView() }
                .tabItem { Label("Konzerte", systemImage: "music.mic") }
            NavigationStack { SettingsView() }
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
        }
        .tint(Theme.bordeaux)
        .audioErrorBanner()
        .onAppear(perform: checkSignatureOnce)
        .alert(
            "Signatur läuft bald ab",
            isPresented: Binding(get: { signatureWarning != nil }, set: { if !$0 { signatureWarning = nil } })
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(signatureWarning ?? "")
        }
    }

    private func checkSignatureOnce() {
        guard !didCheckSignature else { return }
        didCheckSignature = true
        guard let signatureExpiry else { return }
        let days = ProvisioningInfo.daysRemaining(until: signatureExpiry, now: .now)
        if days < SignatureStatus.warningThreshold {
            signatureWarning = SignatureStatus.text(days: days)
        }
    }
}
