import AVFoundation
import Observation

/// Zeigt im Konzertmodus das Ausgabegerät und warnt bei niedriger Lautstärke.
@MainActor
@Observable
final class AudioRouteMonitor {
    private(set) var outputName = ""
    private(set) var isVolumeLow = false

    @ObservationIgnored private var volumeObservation: NSKeyValueObservation?
    @ObservationIgnored private var routeObserver: NSObjectProtocol?

    static let lowVolumeThreshold: Float = 0.3

    func start() {
        let session = AVAudioSession.sharedInstance()
        updateRoute()

        let monitor = self
        volumeObservation = session.observe(\.outputVolume, options: [.initial, .new]) { session, _ in
            let volume = session.outputVolume
            Task { @MainActor in
                monitor.isVolumeLow = volume < AudioRouteMonitor.lowVolumeThreshold
            }
        }
        routeObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification, object: nil, queue: .main
        ) { [weak self] _ in
            MainActor.assumeIsolated { self?.updateRoute() }
        }
    }

    func stop() {
        volumeObservation?.invalidate()
        volumeObservation = nil
        if let routeObserver {
            NotificationCenter.default.removeObserver(routeObserver)
        }
        routeObserver = nil
    }

    private func updateRoute() {
        let port = AVAudioSession.sharedInstance().currentRoute.outputs.first?.portType
        outputName = Self.displayName(for: port)
    }

    static func displayName(for port: AVAudioSession.Port?) -> String {
        switch port {
        case .builtInSpeaker?:
            return "iPhone-Lautsprecher"
        case .headphones?, .bluetoothHFP?:
            return "Kopfhörer"
        case .bluetoothA2DP?, .bluetoothLE?:
            return "Bluetooth"
        case .airPlay?:
            return "AirPlay"
        default:
            return "Anderes Gerät"
        }
    }
}
