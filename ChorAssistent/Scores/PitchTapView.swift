import SwiftUI
import UIKit

/// Anfangstöne durch Antippen der Notenköpfe im Scan bestimmen.
/// Die App findet die Notenlinien selbst; Schlüssel und Vorzeichen stellt man ein.
struct PitchTapView: View {
    let pages: [Data]
    let maxCount: Int
    let onDone: ([Int]) -> Void

    @Environment(\.dismiss) private var dismiss
    @Environment(TonePlayer.self) private var tonePlayer

    @State private var pageIndex = 0
    @State private var image: UIImage?
    @State private var gray: GrayImage?
    @State private var clef: Clef = .treble
    @State private var keySignature = 0
    @State private var detection: StaffDetection?
    @State private var adjustment = 0
    @State private var collected: [Int] = []
    @State private var notFound = false

    private var detectedMidi: Int? {
        detection.map { StaffPitch.midi(step: $0.step, clef: clef, keySignature: keySignature) + adjustment }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                controls
                ZStack {
                    Color.black
                    if let image {
                        TappableScoreImage(image: image, highlight: detection) { point in
                            handleTap(at: point)
                        }
                    } else {
                        ProgressView().tint(.white)
                    }
                }
                resultPanel
            }
            .background(Theme.paper)
            .navigationTitle("Töne antippen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        onDone(collected)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(collected.isEmpty)
                }
            }
            .task(id: pageIndex) {
                await loadPage()
            }
            .onChange(of: clef) { _, _ in previewDetected() }
            .onChange(of: keySignature) { _, _ in previewDetected() }
        }
    }

    // MARK: Teile

    private var controls: some View {
        VStack(spacing: 10) {
            Picker("Schlüssel", selection: $clef) {
                ForEach(Clef.allCases) { clef in
                    Text("\(clef.symbol) \(clef.label)").tag(clef)
                }
            }
            .pickerStyle(.segmented)

            HStack {
                Menu {
                    Picker("Vorzeichen", selection: $keySignature) {
                        ForEach(Array(StaffPitch.keySignatureRange.reversed()), id: \.self) { value in
                            Text(StaffPitch.keySignatureLabel(value)).tag(value)
                        }
                    }
                } label: {
                    Label(StaffPitch.keySignatureLabel(keySignature), systemImage: "number")
                        .font(.subheadline.weight(.semibold))
                        .lineLimit(1)
                }
                Spacer()
                if pages.count > 1 {
                    Stepper("Seite \(pageIndex + 1)/\(pages.count)", value: $pageIndex, in: 0...(pages.count - 1))
                        .font(.subheadline)
                        .fixedSize()
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Theme.card)
    }

    @ViewBuilder
    private var resultPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let midi = detectedMidi {
                let inRange = Song.pitchRange.contains(midi)
                HStack(spacing: 12) {
                    Text(NoteName.name(midi: midi))
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(inRange ? Theme.bordeaux : .red)
                        .frame(minWidth: 90, alignment: .leading)
                    Button("−½") { adjust(-1) }
                        .buttonStyle(.bordered)
                    Button("+½") { adjust(1) }
                        .buttonStyle(.bordered)
                    Button {
                        tonePlayer.preview(midi)
                    } label: {
                        Image(systemName: "speaker.wave.2.fill")
                    }
                    .buttonStyle(.bordered)
                    Spacer(minLength: 0)
                }
                Button {
                    collected.append(midi)
                    detection = nil
                    adjustment = 0
                } label: {
                    Label("Übernehmen", systemImage: "checkmark")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!inRange || collected.count >= maxCount)
                if !inRange {
                    Text("Außerhalb von C2–C6. Schlüssel prüfen.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } else {
                Text(
                    notFound
                        ? "Keine Notenlinien gefunden. Heranzoomen und genau auf den Notenkopf tippen."
                        : "Tippe auf den ersten Notenkopf einer Stimme. Schlüssel und Vorzeichen oben einstellen."
                )
                .font(.subheadline)
                .foregroundStyle(notFound ? .red : Theme.inkSecondary)
            }

            HStack(spacing: 8) {
                Text("Übernommen:")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Theme.inkSecondary)
                if collected.isEmpty {
                    Text("noch keine")
                        .font(.caption)
                        .foregroundStyle(Theme.inkSecondary)
                } else {
                    ToneChips(pitches: collected)
                    Spacer(minLength: 0)
                    Button {
                        collected.removeLast()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .accessibilityLabel("Letzten Ton entfernen")
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card)
    }

    // MARK: Aktionen

    private func loadPage() async {
        detection = nil
        notFound = false
        image = nil
        gray = nil
        guard pages.indices.contains(pageIndex) else { return }
        let data = pages[pageIndex]
        let loaded = await Task.detached(priority: .userInitiated) { () -> (UIImage, GrayImage)? in
            guard let image = UIImage(data: data), let cgImage = image.cgImage,
                let gray = GrayImage(cgImage: cgImage)
            else { return nil }
            return (image, gray)
        }.value
        image = loaded?.0
        gray = loaded?.1
    }

    private func handleTap(at point: CGPoint) {
        guard let gray else { return }
        adjustment = 0
        detection = StaffImageAnalyzer.detect(in: gray, x: point.x, y: point.y)
        notFound = detection == nil
        previewDetected()
    }

    private func adjust(_ semitones: Int) {
        adjustment += semitones
        previewDetected()
    }

    private func previewDetected() {
        if let midi = detectedMidi, Song.pitchRange.contains(midi) {
            tonePlayer.preview(midi)
        }
    }
}

// MARK: Tippbares Zoom-Bild

/// Zoombares Bild; ein Tipp liefert die Position in Bildpixeln.
/// Erkannte Notenlinien und die Tipp-Stelle werden eingezeichnet.
struct TappableScoreImage: UIViewRepresentable {
    let image: UIImage
    let highlight: StaffDetection?
    let onTap: @MainActor (CGPoint) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 6
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = context.coordinator

        let imageView = StaffOverlayImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            imageView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
        ])

        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        scrollView.addGestureRecognizer(tap)

        context.coordinator.imageView = imageView
        context.coordinator.onTap = onTap
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.onTap = onTap
        guard let imageView = context.coordinator.imageView else { return }
        if imageView.image !== image {
            imageView.image = image
            scrollView.setZoomScale(1, animated: false)
        }
        imageView.highlight = highlight
    }

    @MainActor
    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var imageView: StaffOverlayImageView?
        var onTap: (@MainActor (CGPoint) -> Void)?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
            guard let imageView, let point = imageView.imagePoint(for: recognizer.location(in: imageView)) else {
                return
            }
            onTap?(point)
        }
    }
}

/// Bildansicht, die das erkannte Notensystem und die Tipp-Stelle einzeichnet.
final class StaffOverlayImageView: UIImageView {
    var highlight: StaffDetection? {
        didSet { setNeedsLayout() }
    }

    private let staffLayer = CAShapeLayer()
    private let markerLayer = CAShapeLayer()

    override init(image: UIImage?) {
        super.init(image: image)
        contentMode = .scaleAspectFit
        staffLayer.strokeColor = UIColor(hex: 0xD9B467).withAlphaComponent(0.85).cgColor
        staffLayer.fillColor = nil
        staffLayer.lineWidth = 2
        markerLayer.strokeColor = UIColor(hex: 0x7B1E2C).cgColor
        markerLayer.fillColor = UIColor(hex: 0x7B1E2C).withAlphaComponent(0.25).cgColor
        markerLayer.lineWidth = 2
        layer.addSublayer(staffLayer)
        layer.addSublayer(markerLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) wird nicht verwendet")
    }

    /// Bereich, in dem das Bild bei `.scaleAspectFit` liegt.
    private var imageRect: CGRect {
        guard let image, image.size.width > 0, image.size.height > 0, bounds.width > 0 else { return .zero }
        let scale = min(bounds.width / image.size.width, bounds.height / image.size.height)
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)
        return CGRect(
            x: (bounds.width - size.width) / 2, y: (bounds.height - size.height) / 2,
            width: size.width, height: size.height)
    }

    /// Bildpixel pro Punkt in dieser Ansicht.
    private var pixelsPerPoint: CGFloat {
        guard let image, imageRect.width > 0 else { return 1 }
        return image.size.width * image.scale / imageRect.width
    }

    func imagePoint(for viewPoint: CGPoint) -> CGPoint? {
        let rect = imageRect
        guard rect.contains(viewPoint) else { return nil }
        return CGPoint(
            x: (viewPoint.x - rect.minX) * pixelsPerPoint,
            y: (viewPoint.y - rect.minY) * pixelsPerPoint)
    }

    private func viewPoint(x: Double, y: Double) -> CGPoint {
        let rect = imageRect
        return CGPoint(x: rect.minX + x / pixelsPerPoint, y: rect.minY + y / pixelsPerPoint)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        staffLayer.frame = bounds
        markerLayer.frame = bounds
        redraw()
        CATransaction.commit()
    }

    private func redraw() {
        guard let highlight else {
            staffLayer.path = nil
            markerLayer.path = nil
            return
        }
        let rect = imageRect
        let staffPath = UIBezierPath()
        for line in highlight.lines {
            let y = viewPoint(x: 0, y: line).y
            staffPath.move(to: CGPoint(x: rect.minX, y: y))
            staffPath.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        staffLayer.path = staffPath.cgPath

        let center = viewPoint(x: highlight.x, y: highlight.y)
        let radius = max(6, highlight.spacing / pixelsPerPoint * 0.8)
        markerLayer.path =
            UIBezierPath(
                ovalIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            ).cgPath
    }
}
