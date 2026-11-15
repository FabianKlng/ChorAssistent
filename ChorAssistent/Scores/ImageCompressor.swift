import UIKit

/// Verkleinert gescannte Seiten und speichert sie als JPEG.
enum ImageCompressor {
    static let maxDimension: CGFloat = 2000
    static let quality: CGFloat = 0.7

    /// Zielgröße mit längster Kante höchstens `maxDimension`; kleinere Bilder bleiben unverändert.
    static func targetSize(for size: CGSize, maxDimension: CGFloat = maxDimension) -> CGSize {
        let longest = max(size.width, size.height)
        guard longest > maxDimension, longest > 0 else { return size }
        let scale = maxDimension / longest
        return CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())
    }

    static func jpegData(from image: UIImage) -> Data? {
        let pixelSize = CGSize(width: image.size.width * image.scale, height: image.size.height * image.scale)
        let target = targetSize(for: pixelSize)
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: target, format: format)
        let resized = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: target))
        }
        return resized.jpegData(compressionQuality: quality)
    }
}
