import CoreGraphics
import Foundation

/// Graustufenbild als Byte-Array (0 = schwarz, 255 = weiß), Zeile 0 = oben.
struct GrayImage: Sendable {
    let width: Int
    let height: Int
    let pixels: [UInt8]

    init?(cgImage: CGImage) {
        let w = cgImage.width
        let h = cgImage.height
        guard w > 0, h > 0 else { return nil }
        var buffer = [UInt8](repeating: 255, count: w * h)
        let drawn = buffer.withUnsafeMutableBytes { raw -> Bool in
            guard
                let context = CGContext(
                    data: raw.baseAddress, width: w, height: h, bitsPerComponent: 8, bytesPerRow: w,
                    space: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGImageAlphaInfo.none.rawValue)
            else { return false }
            context.interpolationQuality = .none
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: w, height: h))
            return true
        }
        guard drawn else { return nil }
        width = w
        height = h
        pixels = buffer
    }
}

/// Ergebnis eines Tipps: gefundenes Notensystem und Position darin.
struct StaffDetection: Equatable, Sendable {
    /// y-Werte der fünf Linien in Bildpixeln, von oben nach unten.
    let lines: [Double]
    /// 0 = unterste Linie, positiv = höher.
    let step: Int
    /// Tipp-Position in Bildpixeln.
    let x: Double
    let y: Double

    var spacing: Double { (lines[4] - lines[0]) / 4 }
}

/// Findet die Notenlinien rund um einen Tipp.
/// Gemessen wird links und rechts der Tipp-Stelle, damit der Notenkopf selbst nicht als Linie zählt.
enum StaffImageAnalyzer {
    static let darkThreshold: UInt8 = 150
    static let minLineRatio = 0.45

    static func detect(in image: GrayImage, x: Double, y: Double) -> StaffDetection? {
        let width = image.width
        let height = image.height
        let centerX = Int(x)
        let centerY = Int(y)
        guard (0..<width).contains(centerX), (0..<height).contains(centerY) else { return nil }

        let exclusion = max(12, width / 50)
        let side = max(60, width / 8)
        let columns = clampedRange(centerX - exclusion - side, centerX - exclusion, limit: width)
            + clampedRange(centerX + exclusion, centerX + exclusion + side, limit: width)
        guard columns.count >= 20 else { return nil }

        let reach = max(150, height / 10)
        let top = max(0, centerY - reach)
        let bottom = min(height - 1, centerY + reach)

        var darkness: [Double] = []
        darkness.reserveCapacity(bottom - top + 1)
        for row in top...bottom {
            let base = row * width
            var dark = 0
            for column in columns where image.pixels[base + column] < darkThreshold {
                dark += 1
            }
            darkness.append(Double(dark) / Double(columns.count))
        }

        let lines = StaffDetector.lineCenters(rowDarkness: darkness, minRatio: minLineRatio)
            .map { $0 + Double(top) }
        guard let staff = StaffDetector.staff(in: lines, near: y) else { return nil }
        return StaffDetection(lines: staff, step: StaffPitch.step(forY: y, staff: staff), x: x, y: y)
    }

    private static func clampedRange(_ lower: Int, _ upper: Int, limit: Int) -> [Int] {
        let low = max(0, lower)
        let high = min(limit, upper)
        guard low < high else { return [] }
        return Array(low..<high)
    }
}
