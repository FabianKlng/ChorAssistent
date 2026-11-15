import SwiftData
import SwiftUI

/// Startseite: nächstes Konzert, zuletzt angelegte Lieder, Signatur.
struct HomeView: View {
    @Environment(\.signatureExpiry) private var signatureExpiry
    @Query private var concerts: [Concert]
    @Query(sort: \Song.createdAt, order: .reverse) private var songs: [Song]

    @State private var playingConcert: Concert?

    private var nextConcert: Concert? {
        Concert.next(from: concerts, now: .now)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                if signatureExpiry != nil {
                    SignatureStatusView()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .card(padding: 14)
                }

                SectionHeader("Nächstes Konzert")
                nextConcertCard

                SectionHeader("Zuletzt angelegt")
                recentSongs
            }
            .padding()
        }
        .background(Theme.paper)
        .navigationTitle("ChorAssistent")
        .fullScreenCover(item: $playingConcert) { concert in
            ConcertPlayerView(concert: concert)
        }
    }

    // MARK: Teile

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Theme.bordeaux, Theme.bordeaux.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            StaffLines()
                .stroke(Theme.gold.opacity(0.35), lineWidth: 1)
                .frame(height: 44)
                .padding(.horizontal, -4)
                .offset(y: -58)
            Image(systemName: "music.note")
                .font(.system(size: 72, weight: .light))
                .foregroundStyle(Theme.gold.opacity(0.55))
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(20)
            VStack(alignment: .leading, spacing: 6) {
                Text("Bereit für den ersten Ton?")
                    .font(Theme.serif(.title2, weight: .bold))
                Text("\(songs.count) Lieder · \(concerts.count) Konzerte")
                    .font(.subheadline)
                    .opacity(0.85)
            }
            .foregroundStyle(Theme.onAccent)
            .padding(20)
        }
        .frame(height: 170)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Theme.bordeaux.opacity(0.3), radius: 14, y: 6)
    }

    @ViewBuilder
    private var nextConcertCard: some View {
        if let concert = nextConcert {
            let entries = concert.orderedEntries
            VStack(alignment: .leading, spacing: 12) {
                Text(concert.name)
                    .font(Theme.serif(.title2, weight: .bold))
                    .foregroundStyle(Theme.ink)
                if let date = concert.date {
                    Label(Theme.longDate(date), systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(Theme.inkSecondary)
                }
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(Array(entries.prefix(3).enumerated()), id: \.element.id) { index, entry in
                        HStack(spacing: 8) {
                            Text("\(index + 1).")
                                .monospacedDigit()
                                .foregroundStyle(Theme.gold)
                            Text(entry.song?.title ?? "")
                                .foregroundStyle(Theme.ink)
                        }
                        .font(Theme.serif(.body))
                    }
                    if entries.count > 3 {
                        Text("… und \(entries.count - 3) weitere")
                            .font(.footnote)
                            .foregroundStyle(Theme.inkSecondary)
                    }
                }
                HStack {
                    NavigationLink {
                        ConcertEditView(concert: concert)
                    } label: {
                        Text("Bearbeiten")
                    }
                    Spacer()
                    Button {
                        playingConcert = concert
                    } label: {
                        Label("Konzert starten", systemImage: "play.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(entries.isEmpty)
                }
                .padding(.top, 4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        } else {
            HintCard(
                systemImage: "calendar.badge.plus",
                title: "Kein anstehendes Konzert",
                message: "Lege im Reiter „Konzerte“ eine Liedfolge an und gib ihr ein Datum."
            )
        }
    }

    @ViewBuilder
    private var recentSongs: some View {
        if songs.isEmpty {
            HintCard(
                systemImage: "music.note",
                title: "Noch keine Lieder",
                message: "Im Reiter „Lieder“ legst du Lieder mit ihren Anfangstönen und Noten an."
            )
        } else {
            VStack(spacing: 12) {
                ForEach(songs.prefix(5)) { song in
                    NavigationLink {
                        SongDetailView(song: song)
                    } label: {
                        SongRowContent(song: song)
                            .card(padding: 14)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
