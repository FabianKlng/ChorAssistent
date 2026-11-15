import AVFoundation
import Observation

enum AudioError: Error, Equatable {
    case unavailable

    var message: String { "Ton nicht verfügbar – App neu starten" }
}

/// Spielt Tonfolgen über einen Sampler mit der mitgelieferten Klavier-SoundFont.
@MainActor
@Observable
final class TonePlayer {
    private(set) var isPlaying = false
    private(set) var currentSourceID: String?
    private(set) var lastError: AudioError?

    @ObservationIgnored private var engine = AVAudioEngine()
    @ObservationIgnored private var sampler = AVAudioUnitSampler()
    @ObservationIgnored private var soundBankLoaded = false
    @ObservationIgnored private var playTask: Task<Void, Never>?
    @ObservationIgnored private var generation = 0
    @ObservationIgnored private var soundingNotes: Set<UInt8> = []
    @ObservationIgnored private var observers: [NSObjectProtocol] = []
    @ObservationIgnored private var isSetUp = false

    // MARK: Einrichtung

    /// Einmal beim App-Start. Mehrfache Aufrufe tun nichts, damit sich die
    /// Beobachter nicht stapeln.
    func setUp() {
        guard !isSetUp else { return }
        isSetUp = true
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
        } catch {
            lastError = .unavailable
        }
        buildGraph()
        ensureRunning()
        observeSystemEvents()
    }

    /// Der eine Weg zur Wiederherstellung: Sitzung aktivieren, Engine starten.
    func ensureRunning() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            if !engine.isRunning {
                engine.prepare()
                try engine.start()
            }
            lastError = soundBankLoaded ? nil : .unavailable
        } catch {
            lastError = .unavailable
        }
    }

    private func buildGraph() {
        engine.stop()
        let newEngine = AVAudioEngine()
        let newSampler = AVAudioUnitSampler()
        newEngine.attach(newSampler)
        newEngine.connect(newSampler, to: newEngine.mainMixerNode, format: nil)
        engine = newEngine
        sampler = newSampler
        soundBankLoaded = false

        guard let url = Bundle.main.url(forResource: "Piano", withExtension: "sf2") else {
            lastError = .unavailable
            return
        }
        do {
            try newSampler.loadSoundBankInstrument(
                at: url,
                program: 0,
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB)
            )
            soundBankLoaded = true
        } catch {
            lastError = .unavailable
        }
    }

    private func rebuild() {
        stop()
        buildGraph()
        ensureRunning()
    }

    private func observeSystemEvents() {
        let center = NotificationCenter.default
        // Beobachter laufen auf der Main-Queue; Werte aus userInfo werden vor dem
        // Wechsel in den MainActor-Kontext als Sendable-Werte ausgelesen.
        observers.append(
            center.addObserver(forName: AVAudioSession.interruptionNotification, object: nil, queue: .main) {
                [weak self] note in
                let rawType = note.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
                MainActor.assumeIsolated {
                    guard let self, let rawType, let type = AVAudioSession.InterruptionType(rawValue: rawType)
                    else { return }
                    switch type {
                    case .began:
                        self.stop()
                    case .ended:
                        self.ensureRunning()
                    @unknown default:
                        self.ensureRunning()
                    }
                }
            })
        for name in [AVAudioSession.routeChangeNotification, .AVAudioEngineConfigurationChange] {
            observers.append(
                center.addObserver(forName: name, object: nil, queue: .main) { [weak self] _ in
                    MainActor.assumeIsolated { self?.ensureRunning() }
                })
        }
        observers.append(
            center.addObserver(forName: AVAudioSession.mediaServicesWereResetNotification, object: nil, queue: .main) {
                [weak self] _ in
                MainActor.assumeIsolated { self?.rebuild() }
            })
    }

    // MARK: Abspielen

    /// Spielt eine Tonfolge. Ein neuer Aufruf bricht die laufende Folge ab.
    func play(
        _ pitches: [Int],
        sourceID: String,
        toneDurationMs: Int = PlaybackSettings.toneDurationMs,
        gapMs: Int = PlaybackSettings.gapMs
    ) {
        ensureRunning()
        guard lastError == nil, !pitches.isEmpty else { return }

        stop()
        generation += 1
        let myGeneration = generation
        currentSourceID = sourceID
        isPlaying = true

        let events = PlaybackSchedule.events(pitches: pitches, toneDurationMs: toneDurationMs, gapMs: gapMs)
        playTask = Task { [weak self] in
            let clock = ContinuousClock()
            let start = clock.now
            for event in events {
                // Absolute Zeitpunkte, damit sich keine Verzögerung aufsummiert.
                try? await clock.sleep(until: start.advanced(by: .milliseconds(event.timeMs)), tolerance: nil)
                guard let self, !Task.isCancelled, self.generation == myGeneration else { return }
                self.perform(event)
            }
            guard let self, self.generation == myGeneration else { return }
            self.isPlaying = false
            self.currentSourceID = nil
        }
    }

    /// Kurzes Anspielen eines einzelnen Tons im Auswahlrad.
    func preview(_ midi: Int) {
        play([midi], sourceID: "preview", toneDurationMs: 500, gapMs: 0)
    }

    func stop() {
        playTask?.cancel()
        playTask = nil
        generation += 1
        for note in soundingNotes {
            sampler.stopNote(note, onChannel: 0)
        }
        // „All Notes Off" als Absicherung.
        sampler.sendController(123, withValue: 0, onChannel: 0)
        soundingNotes.removeAll()
        isPlaying = false
        currentSourceID = nil
    }

    private func perform(_ event: NoteEvent) {
        let note = UInt8(clamping: event.midi)
        switch event.kind {
        case .start:
            sampler.startNote(note, withVelocity: 127, onChannel: 0)
            soundingNotes.insert(note)
        case .stop:
            sampler.stopNote(note, onChannel: 0)
            soundingNotes.remove(note)
        }
    }
}
