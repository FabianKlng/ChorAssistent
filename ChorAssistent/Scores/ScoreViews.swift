import SwiftUI
import UIKit

// MARK: Vorschaubild

/// Kleines Vorschaubild einer Notenseite; wird im Hintergrund verkleinert.
struct ScoreThumbnail: View {
    let data: Data
    var height: CGFloat = 150

    @State private var image: UIImage?

    var body: some View {
        ZStack {
            Theme.card
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ProgressView()
            }
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Theme.staffLine, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
        .task(id: data) {
            image = await UIImage(data: data)?.byPreparingThumbnail(ofSize: CGSize(width: 400, height: 560))
        }
    }
}

// MARK: Vollbild-Ansicht

/// Zeigt alle Notenseiten eines Lieds im Vollbild; Zoom per Pinch oder Doppeltipp.
struct ScoreViewer: View {
    let pages: [ScorePage]

    @Environment(\.dismiss) private var dismiss
    @State private var index: Int

    init(pages: [ScorePage], startIndex: Int) {
        self.pages = pages
        _index = State(initialValue: min(max(startIndex, 0), max(pages.count - 1, 0)))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            TabView(selection: $index) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { offset, page in
                    ScorePageImage(data: page.imageData)
                        .tag(offset)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea(edges: .bottom)

            HStack {
                Text("Seite \(index + 1) von \(pages.count)")
                    .font(Theme.serif(.subheadline, weight: .semibold))
                Spacer()
                Button("Fertig") { dismiss() }
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial.opacity(0.6))
        }
        .preferredColorScheme(.dark)
    }
}

private struct ScorePageImage: View {
    let data: Data
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                ZoomableImage(image: image)
            } else {
                ProgressView().tint(.white)
            }
        }
        .task(id: data) {
            image = UIImage(data: data)
        }
    }
}

// MARK: Zoom

/// Bild in einer UIScrollView: Pinch-Zoom bis 5×, Doppeltipp schaltet zwischen 1× und 2,5×.
struct ZoomableImage: UIViewRepresentable {
    let image: UIImage

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
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

        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTap.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTap)

        context.coordinator.imageView = imageView
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.imageView?.image = image
    }

    @MainActor
    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var imageView: UIImageView?

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            imageView
        }

        @objc func handleDoubleTap(_ recognizer: UITapGestureRecognizer) {
            guard let scrollView = recognizer.view as? UIScrollView else { return }
            let target: CGFloat = scrollView.zoomScale > 1 ? 1 : 2.5
            scrollView.setZoomScale(target, animated: true)
        }
    }
}
