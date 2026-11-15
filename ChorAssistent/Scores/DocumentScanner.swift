import SwiftUI
import VisionKit

/// Der Dokumentenscanner von iOS (Kantenerkennung, Entzerrung, mehrere Seiten).
struct DocumentScanner: UIViewControllerRepresentable {
    let onFinish: @MainActor ([UIImage]) -> Void
    let onCancel: @MainActor () -> Void

    /// Auf dem Simulator und auf Geräten ohne Kamera nicht verfügbar.
    static var isAvailable: Bool { VNDocumentCameraViewController.isSupported }

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish, onCancel: onCancel)
    }

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let controller = VNDocumentCameraViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: VNDocumentCameraViewController, context: Context) {}

    final class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        private let onFinish: @MainActor ([UIImage]) -> Void
        private let onCancel: @MainActor () -> Void

        init(onFinish: @escaping @MainActor ([UIImage]) -> Void, onCancel: @escaping @MainActor () -> Void) {
            self.onFinish = onFinish
            self.onCancel = onCancel
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan
        ) {
            // Der Scanner ruft seine Delegate-Methoden auf dem Main-Thread auf.
            MainActor.assumeIsolated {
                let images = (0..<scan.pageCount).map { scan.imageOfPage(at: $0) }
                onFinish(images)
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            MainActor.assumeIsolated { onCancel() }
        }

        func documentCameraViewController(
            _ controller: VNDocumentCameraViewController, didFailWithError error: Error
        ) {
            MainActor.assumeIsolated { onCancel() }
        }
    }
}
